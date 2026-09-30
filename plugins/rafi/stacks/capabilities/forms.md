# Capability: Forms
Kind: capability
Ask when: anonymous visitors submit a form: contact, enquiry, lead, or newsletter signup. Login forms belong to auth, checkout to payments.
Default: frameworks with server routes (nextjs, react-express, astro with an adapter) → server-endpoint + turnstile, delivered through the email capability. Static output (astro static, react-spa) → web3forms.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| server-endpoint | adopt | The project already has server routes. Full control, no third party holds the submissions | nextjs, react-express, astro (on-demand routes) | free; needs the email capability to deliver |
| turnstile | adopt | Add-on for any public form. Spam protection without image puzzles | any | free |
| web3forms | adopt | Static site with no server. Hosted endpoint emails you each submission | any | free tier with a monthly cap; paid plans |
| formspree | trial | Static site that needs more than email delivery: integrations, a submissions dashboard, file uploads on paid plans | any | free tier with a monthly cap; paid plans |

## Option: server-endpoint
Setup: one handler per form. nextjs → a server action in `features/<name>/actions`. astro → an Astro Action on a route with `export const prerender = false` (needs an adapter). react-express → a POST route in `apps/api`. Shared Zod schema for the fields.
Conventions:
- Order: validate (Zod) → verify Turnstile → rate limit → deliver (email capability) → return a typed result the form renders.
- Include a honeypot field that humans never see; reject submissions that fill it.
- The form works without JavaScript where the framework allows (progressive enhancement), and shows the same errors either way.
Security checks (added to security-audit):
- Every field is validated server-side for type, length, and format. Client validation is only a convenience (§4).
- User input never goes into email headers (To, From, Subject) unescaped. Use the visitor's address only as a validated Reply-To (§4).
- The endpoint is rate limited per IP (§13).
Sources: https://nextjs.org/docs/app/guides/forms, https://docs.astro.build/en/guides/actions/

## Option: turnstile
Setup: create a widget in the Cloudflare dashboard to get a site key (public) and a secret key (server-only). Render the widget in the form; it adds a `cf-turnstile-response` token to the submission. On the server, POST `secret`, `response`, and optionally `remoteip` to `https://challenges.cloudflare.com/turnstile/v0/siteverify` and reject unless `success` is true.
Conventions:
- Verify on the server on every submission. A token is single-use and expires after 5 minutes, so show a clear retry message on failure.
- With a hosted form service, use Turnstile only if that service verifies it for you on your plan. Otherwise use the service's built-in protection.
Security checks (added to security-audit):
- Server-side siteverify is present on every protected endpoint. A client-side widget alone protects nothing (§13).
- The secret key is a server-only env var (§5).
- Check `hostname` (and `action`, if set) in the siteverify response (§13).
Accessibility checks (added to accessibility-audit):
- Use the managed or invisible mode, so the form does not rely on a visual puzzle (§2, §3).
Sources: https://developers.cloudflare.com/turnstile/get-started/client-side-rendering/, https://developers.cloudflare.com/turnstile/get-started/server-side-validation/

## Option: web3forms
Setup: create an access key for your receiving address. The form posts to the Web3Forms endpoint with the key in a hidden `access_key` field. Built-in spam protection: honeypot and hCaptcha on the free tier; check whether Turnstile is included on your plan.
Conventions:
- The access key is public by design. It only lets people send to your inbox, so enable the service's spam protection.
- Submit with `fetch` and render your own success and error states, rather than redirecting to the service's page.
Security checks (added to security-audit):
- Spam protection (honeypot plus a challenge) is enabled (§13).
- The privacy notice names the service as a processor of form data (§11).
Sources: https://docs.web3forms.com

## Option: formspree
Setup: create a form in Formspree to get its endpoint. The form posts there, or uses Formspree's JS library for `fetch` submission. Check the current free-tier limits and which challenge providers your plan supports.
Conventions:
- Submit with `fetch` and render your own success and error states, rather than redirecting to the service's page.
Security checks (added to security-audit):
- Spam protection (honeypot plus a challenge) is enabled (§13).
- The privacy notice names the service as a processor of form data (§11).
Sources: https://help.formspree.io

## Shared
Security checks (added to security-audit):
- Submissions are not logged with their contents or personal data (§8, §11).
Accessibility checks (added to accessibility-audit):
- Every field has a visible `<label>`, errors are linked with `aria-describedby`, and the first error receives focus on submit (§3, §5).
- Success and failure messages are announced (`role="status"` or `role="alert"`) (§4).
- Fields use the right `type` and `autocomplete` values (`email`, `name`, `tel`) (§3).
- The whole form, including any challenge widget, is operable by keyboard (§2).
