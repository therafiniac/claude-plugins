# Framework profile: WordPress (PHP)
Kind: framework. Use for client and freelance sites and content sites on WordPress, where you write a custom block theme and/or a custom plugin. WordPress manages its own MySQL or MariaDB database, so choose database: none in bootstrap. Sites built mainly with a page builder (Elementor and similar) are out of scope: use this profile only for the custom code around them.
Verified against: WordPress 7.0 (released May 2026, per third-party reports), September 2026. The security and coding-standard rules follow the WordPress Plugin Handbook and Coding Standards. Minimum versions come from third-party reports: PHP 7.4 minimum with 8.3+ recommended, and MySQL 8.0 minimum. Check the current requirements on wordpress.org and with the host before choosing versions.

## Stack
WordPress with a block theme (`theme.json`, `templates/`, `parts/`, `patterns/`) and/or a custom plugin. PHP 8.3 or newer. Composer for PHP tooling. Node for build and test tooling (`@wordpress/scripts`, `@wordpress/env`, Playwright). Default hosting: shared or managed WordPress hosting (for example Hostinger). The local environment `wp-env` needs Docker.

## Scaffold contract
- The repo holds only custom code: `wp-content/themes/<slug>/` and/or `wp-content/plugins/<slug>/`. Never commit WordPress core, other people's plugins, `wp-content/uploads/`, `vendor/`, or `wp-config.php`. Add these to `.gitignore`.
- Local environment: `.wp-env.json` at the repo root, and `pnpm dev` runs `wp-env start`.
- PHP tooling (Composer dev dependencies): `wp-coding-standards/wpcs` with `dealerdirect/phpcodesniffer-composer-installer`, `phpstan/phpstan` with `szepeviktor/phpstan-wordpress`, `phpunit/phpunit` with `yoast/phpunit-polyfills`. Configuration: `phpcs.xml.dist`, `phpstan.neon.dist`, `phpunit.xml.dist`.
- Scripts in `package.json` (they call Composer where needed, so the standard names still work): `dev` (`wp-env start`), `build` (`wp-scripts build` if there is JavaScript or CSS to build, otherwise a command that exits 0), `typecheck` (`composer run phpstan`), `lint` (`composer run phpcs`, plus `wp-scripts lint-js` if there is JavaScript), `test` (PHPUnit inside the wp-env tests container), `check` (typecheck + lint + test), `test:e2e` (`playwright test` with `@wordpress/e2e-test-utils-playwright`), `lighthouse` (`lhci autorun`).
- Overrides to the standard bootstrap list: no Vitest (PHPUnit for PHP, `wp-scripts test-unit-js` for JavaScript). No Zod env module: configuration is constants in `wp-config.php`, which stays out of git. `.env.example` documents the constants and deployment variables the site needs. No health endpoint. ESLint comes from `@wordpress/eslint-plugin` through `wp-scripts lint-js`.

### `.wp-env.json`
```json
{
  "core": null,
  "phpVersion": "8.3",
  "themes": ["./wp-content/themes/<slug>"],
  "plugins": ["./wp-content/plugins/<slug>"],
  "config": {
    "WP_DEBUG": true,
    "WP_DEBUG_LOG": true,
    "SCRIPT_DEBUG": true
  }
}
```
`"core": null` uses the latest WordPress. wp-env serves the site at `http://localhost:8888` and the tests site at `http://localhost:8889`.

### `phpcs.xml.dist`
```xml
<?xml version="1.0"?>
<ruleset name="Project">
  <file>wp-content</file>
  <exclude-pattern>*/vendor/*</exclude-pattern>
  <exclude-pattern>*/node_modules/*</exclude-pattern>
  <exclude-pattern>*/build/*</exclude-pattern>
  <arg name="extensions" value="php"/>
  <arg value="ps"/>
  <config name="minimum_wp_version" value="6.6"/>
  <rule ref="WordPress"/>
  <rule ref="WordPress.WP.I18n">
    <properties>
      <property name="text_domain" type="array">
        <element value="<slug>"/>
      </property>
    </properties>
  </rule>
</ruleset>
```
Set `minimum_wp_version` to the project's real minimum.

### `phpstan.neon.dist`
```neon
includes:
    - vendor/szepeviktor/phpstan-wordpress/extension.neon
parameters:
    level: 5
    paths:
        - wp-content/themes
        - wp-content/plugins
    excludePaths:
        - */vendor/*
        - */node_modules/*
```
Start at level 5 and raise it as the code allows.

## Conventions
- New sites use a block theme. Use a classic PHP theme only when the client requires it.
- Functionality goes in a plugin, not in `functions.php`, so it survives a theme change. The theme handles presentation.
- Prefix everything (functions, classes, hooks, options, script handles) with the project slug, or use namespaces. The text domain equals the slug, and every user-facing string is translatable (`__()`, `esc_html__()`).
- Use core APIs before custom code: Settings API, REST API, `WP_Query`, `register_block_type`, `wp_enqueue_script` and `wp_enqueue_style`, transients and the object cache. Prefer post types, taxonomies, and meta over custom tables. Custom tables use `dbDelta` with a versioned upgrade routine.
- Every PHP file that only declares functions or classes starts with `defined( 'ABSPATH' ) || exit;`.
- Enqueue scripts and styles only on the pages that need them, with a version for cache busting. Use `strategy => 'defer'` where compatible.
- Never edit WordPress core or third-party plugin or theme files. Use hooks, filters, or a child theme.
- Give editors patterns and locked templates instead of free-form layout.
- Secrets live in `wp-config.php` or the host's environment, never in theme or plugin code or in git.
- `.claude/format-cmd` holds `vendor/bin/phpcbf -q`, so edited PHP files are auto-fixed to the coding standard.

## Security checks (added to security-audit)
- Every admin action, AJAX handler, REST route, and form handler checks `current_user_can()` for the specific capability it needs (§3).
- State-changing requests verify a nonce (`check_admin_referer`, `check_ajax_referer`, or the REST `X-WP-Nonce`) in addition to the capability check (§6).
- Sanitize on input (`sanitize_text_field`, `sanitize_email`, `absint`, `wp_kses_post`) and escape on output, as late as possible (`esc_html`, `esc_attr`, `esc_url`, `esc_js`, `wp_kses`) (§4, §12).
- Any SQL that contains a variable goes through `$wpdb->prepare()`. `LIKE` values use `$wpdb->esc_like()`. Never interpolate input into a query (§4).
- Every `register_rest_route` has a real `permission_callback`. `__return_true` is allowed only for genuinely public data. Arguments are validated and sanitized through `args` callbacks (§3, §6).
- File uploads use `wp_handle_upload`, restrict MIME types, and check with `wp_check_filetype_and_ext` (§7).
- No `eval`, no `extract()` on user data, and no `unserialize()` of user input (use JSON) (§4).
- Salts are unique. `DISALLOW_FILE_EDIT` is true. `WP_DEBUG_DISPLAY` is false in production. `wp-config.php` is not readable from the web (§5, §10).
- Administrators use two-factor authentication. Roles follow least privilege. Login attempts are rate-limited. XML-RPC is disabled if unused. User enumeration through the REST API and author archives is limited (§1, §10).
- Plugins and themes come from the official directory or vendors you trust. No nulled or pirated code. Unused plugins are removed. Core and plugin updates follow a weekly routine or auto-updates, and vulnerability advisories are watched (§9).
- Backups run on a schedule and a restore has been tested (§10).

## SEO checks (added to seo-audit)
- Permalinks use "Post name". "Discourage search engines from indexing this site" is off in production and on in staging.
- Exactly one SEO plugin (Yoast SEO, Rank Math, or SEOPress) provides titles, descriptions, Open Graph, and structured data. Core sitemaps live at `/wp-sitemap.xml`, and an SEO plugin's sitemap replaces them, so run only one.
- Classic themes declare `add_theme_support( 'title-tag' )`. Block themes get the title from core.
- Canonicals are correct on paginated archives, filtered URLs, and comment-reply URLs.
- A written `noindex` policy exists for search results, tag, author, date, and attachment pages.
- Structured data is generated once (plugin or theme, not both) and validated.
- Changed slugs create 301 redirects (redirect plugin or server rules).
- Images have descriptive `alt` text and are sized to their display size.
- Custom post types set `has_archive` and `rewrite` deliberately. Rewrite rules are flushed on activation only, never on every request.

## Performance checks (added to performance-audit)
- Page caching is on (host cache or one caching plugin) and verified through response headers for logged-out visitors.
- A persistent object cache (Redis or Memcached) is used on dynamic or busy sites.
- Every active plugin is justified. Measure with Query Monitor and remove plugins that load assets sitewide.
- `WP_Query` uses a bounded `posts_per_page` (never `-1` on large sets), `no_found_rows => true` when pagination is not needed, and `fields => 'ids'` when only IDs are needed. There are no unindexed `meta_query` filters on large tables. Expensive results are cached in transients.
- The autoloaded options total in `wp_options` stays small.
- Images use intentional sizes (`add_image_size`) with `srcset` intact. The LCP image is not lazy-loaded and has `fetchpriority="high"`. Large media uses a CDN.
- Scripts and styles are enqueued conditionally. Non-critical JavaScript is deferred. Avoid front-end jQuery dependence where possible.
- Fonts are self-hosted and subsetted, with `font-display: swap`.
- Busy sites use a real system cron (`DISABLE_WP_CRON`) and scheduled events are audited.
- Slow queries reported by Query Monitor get `EXPLAIN`, and custom tables have indexes.
- Measure Lighthouse on a production-like host, never on wp-env with debug on.

## Accessibility checks (added to accessibility-audit)
- The theme is accessibility-ready: skip link, visible focus, keyboard-operable menus, landmarks, one `<h1>`, headings in order.
- Palette contrast is checked in `theme.json` for every color pairing and both style variations.
- Editor content: images have alt text, patterns use semantic blocks, and headings are not used for styling.
- Contact-form plugins are checked on their rendered output: visible labels, accessible errors.
- Custom blocks have keyboard support and correct ARIA, tested in the editor and on the front end.
- `e2e/a11y.spec.ts` covers the home page, single post, archive, search, 404, and contact form.

## Adaptation notes (differences from the Node and pnpm template)
- `.claude/format-cmd`: first line `vendor/bin/phpcbf -q`. The formatter hook then runs it on each edited file. JavaScript files are still formatted by lint-staged at commit time.
- The Stop hook keeps using `pnpm -s typecheck`, which runs PHPStan through Composer. No `.claude/typecheck-cmd` is needed.
- `.github/workflows/ci.yml`: before the pnpm steps add `shivammathur/setup-php` (PHP 8.3) and `composer install`. Docker is preinstalled on GitHub's Ubuntu runners, so wp-env works there.
- `.github/workflows/e2e.yml` and `lighthouse.yml`: run `pnpm dev` (wp-env start) before the tests and set the base URL to `http://localhost:8888`.
- `.gitignore`: add `wp-config.php`, `wp-content/uploads/`, and `vendor/`.
- `.lintstagedrc.json`: add `"*.php": "vendor/bin/phpcbf -q"`.
- Deployment: upload only the custom theme and plugin (SFTP, rsync, or the host's Git deploy from a GitHub Action). Never deploy `wp-config.php`, uploads, or core.

## Sources
- Minimum-version and 7.0 release reports: https://mysites.guru/blog/wordpress-7-requirements/ and https://wp-umbrella.com/blog/wordpress-7-0-release-status-and-timeline/ (third-party; confirm on wordpress.org)
- WordPress Developer Resources: Plugin Handbook (Security), Coding Standards, `@wordpress/env`, `@wordpress/scripts`, and the Block Editor Handbook. Re-verify current details there before relying on them.
