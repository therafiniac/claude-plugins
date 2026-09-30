## 14. CI/CD & Deployment Security

Maps to: NIST SSDF PO/PS control families, SLSA framework principles.

- [ ] CI/CD secrets (deploy keys, cloud credentials) are stored in the
      CI platform's secret store, never in the repo or in plaintext
      pipeline config.
- [ ] Production deployment requires review/approval (branch protection,
      required PR review) — no direct unreviewed push to a branch that
      auto-deploys to production.
- [ ] The build pipeline itself runs security checks (dependency scan,
      secret scan, and ideally SAST — static analysis) as a gate, not just
      as an optional/manual step.
- [ ] Rollback capability exists and is tested — a bad deploy (including a
      security regression) can be reverted quickly.
- [ ] Infrastructure-as-code (Terraform, CloudFormation, etc.), if used,
      is itself scanned for misconfiguration (public S3 buckets, overly
      permissive security groups/firewall rules) before apply.

