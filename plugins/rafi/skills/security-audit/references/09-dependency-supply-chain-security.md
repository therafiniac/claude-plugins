## 9. Dependency & Supply Chain Security

Maps to: OWASP Top 10 A06:2021 (Vulnerable and Outdated Components), NIST
SSDF PW.4.

- [ ] Dependency vulnerability scanning runs regularly (`npm audit`,
      `pip-audit`, Dependabot/Renovate, Snyk, or equivalent for the
      language ecosystem in use) — ideally gated in CI, not just run
      manually and forgotten.
- [ ] No dependency is pinned to a known-vulnerable version without an
      explicit, documented reason and a tracked follow-up to upgrade.
- [ ] After a security upgrade, the production build is re-run and the
      site smoke-tested — patch releases can regress (a fixed version may
      fail to build; pin the newest version that both builds and audits
      clean).
- [ ] Unmaintained/abandoned packages (no updates in years, single
      maintainer with no activity) are flagged, especially for
      security-relevant functionality (auth, crypto, parsing) — prefer a
      well-maintained alternative or the language's own standard library
      where one exists.
- [ ] Lockfiles (`package-lock.json`, `poetry.lock`, etc.) are committed,
      so builds are reproducible and a compromised upstream package version
      can't silently get pulled in.
- [ ] Build/CI pipeline itself is a supply-chain surface: third-party
      GitHub Actions/CI plugins are pinned to a commit SHA (not a mutable
      tag) where practical, and have only the permissions they actually
      need.
- [ ] `npm install`/build scripts from third-party packages aren't blindly
      trusted — consider `--ignore-scripts` or an allowlist approach for
      untrusted/low-reputation packages, since a package's install script
      runs arbitrary code.

