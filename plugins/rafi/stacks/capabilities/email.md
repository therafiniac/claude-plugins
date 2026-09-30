# Capability: Email
Kind: capability
Ask when: the app sends email: form submissions, sign-up verification, password reset, receipts, or notifications. Marketing newsletters are a different concern and are not covered here.
Default: resend. Choose postmark when transactional deliverability is critical, aws-ses at high volume.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| resend | adopt | Default. Simple API, templates as React components (React Email) | nextjs, react-express, astro (on-demand routes) | free tier with daily and monthly caps; paid plans |
| postmark | adopt | Deliverability of transactional mail matters most (password resets, receipts). Separate streams for transactional and broadcast mail | nextjs, react-express, astro (on-demand routes) | small free developer tier; paid by volume |
| aws-ses | trial | High volume where cost per email matters, and you already use AWS | nextjs, react-express, astro (on-demand routes) | pay per email; needs sandbox exit approval |
| smtp | trial | You must send through an existing mailbox or provider SMTP | nextjs, react-express, astro (on-demand routes) | depends on the provider |

## Option: resend
Setup: `resend` plus, if templates are in React, `react-email` components in `src/emails/`. Env: `RESEND_API_KEY`, and a verified sending domain.
Security checks (added to security-audit):
- Delivery webhooks (bounces, complaints), if used, verify their signature (§15).
Sources: https://resend.com/docs, https://react.email/docs

## Option: postmark
Setup: `postmark` client, a server token (`POSTMARK_SERVER_TOKEN`), a verified sender domain, and separate message streams for transactional and broadcast mail.
Conventions:
- Send transactional mail only through the transactional stream.
Security checks (added to security-audit):
- Bounce and delivery webhooks, if used, are protected (basic auth or a secret in the URL) and validated (§15).
Sources: https://postmarkapp.com/developer

## Option: aws-ses
Setup: `@aws-sdk/client-sesv2`, an IAM user or role allowed only to send from the verified identity, and production access requested (new accounts start in the sandbox).
Conventions:
- Handle bounces and complaints through SNS or event destinations, and stop sending to bounced addresses.
Security checks (added to security-audit):
- The IAM policy allows only `ses:SendEmail` for the verified identity (§10).
Sources: https://docs.aws.amazon.com/ses/

## Option: smtp
Setup: `nodemailer` with the provider's SMTP host, port 465 (TLS) or 587 (STARTTLS), and credentials in env vars.
Conventions:
- Reuse one transporter; do not open a connection per email.
Security checks (added to security-audit):
- TLS is required; plain-text SMTP is never used (§5).
Sources: https://nodemailer.com

## Shared
Conventions:
- One module `src/lib/email.ts` exposes `sendEmail(template, to, data)`. Nothing else imports the provider SDK, so switching providers touches one file.
- Send from a subdomain (for example `mail.example.com`) with SPF, DKIM, and DMARC set up before launch.
- Every template has a plain-text version.
Security checks (added to security-audit):
- API keys, tokens, and SMTP or AWS credentials are server-only env vars, never committed (§5).
- User-supplied values are escaped in HTML templates and never placed in headers unvalidated (§4, §12).
- Endpoints that trigger email are rate limited, so they cannot be used to spam (§13).
- Email bodies and recipient addresses are not written to application logs (§8, §11).
Performance checks (added to performance-audit):
- Bulk or non-critical sends run after the response or in a background job, not inside the request.
Accessibility checks (added to accessibility-audit):
- Templates set `lang`, use real headings and descriptive link text, give images `alt`, and work with images off (§1).
