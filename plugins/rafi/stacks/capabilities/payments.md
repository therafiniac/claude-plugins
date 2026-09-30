# Capability: Payments
Kind: capability
Ask when: the project takes money: one-off purchases, subscriptions, or donations.
Default: customers mainly in India (UPI, cards, net banking) → razorpay. Otherwise → stripe. If you want the provider to handle global sales tax and VAT as merchant of record → paddle.
Verified: September 2026. Re-verify the chosen option in its official docs before scaffolding.

## Options
| Option | Status | Pick when | Works with | Cost |
|---|---|---|---|---|
| stripe | adopt | Default for most countries. Checkout, subscriptions, invoices. You handle tax registration yourself (Stripe Tax helps calculate) | nextjs, react-express, astro (on-demand routes) | per-transaction fees |
| razorpay | adopt | Customers mainly in India: UPI, cards, net banking, wallets | nextjs, react-express, astro (on-demand routes) | per-transaction fees |
| paddle | trial | Merchant of record: Paddle sells to the customer and handles sales tax and VAT worldwide | nextjs, react-express, astro (on-demand routes) | higher per-transaction fee that includes tax handling |
| stripe-managed-payments | trial | Stripe's own merchant-of-record product. It was in public preview in early 2026; confirm availability for your country | same as stripe | merchant-of-record fee |
| lemon-squeezy | hold | Do not start new projects on it. Still running after Stripe's 2024 acquisition, but its team is building Stripe Managed Payments and plans a migration path there | — | — |

## Option: stripe
Setup: `stripe` on the server; Stripe Checkout (hosted) or the Payment Element on the client. Env: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, and the publishable key for the client. Products and prices are created in Stripe and referenced by ID.
Conventions:
- The server creates the Checkout Session from a price ID.
- Fulfill from `checkout.session.completed` and `invoice.paid` webhooks.
Security checks (added to security-audit):
- The webhook verifies its signature with `stripe.webhooks.constructEvent` on the raw request body (§15).
Sources: https://docs.stripe.com/payments/checkout, https://docs.stripe.com/webhooks

## Option: razorpay
Setup: `razorpay` Node SDK on the server; Razorpay Checkout script on the client. Env: `RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`.
Conventions:
- Create an order with the Orders API on the server for every payment, and pass its `order_id` to Checkout.
- After Checkout, verify the returned signature on the server: HMAC-SHA256 of `order_id + "|" + payment_id` with the key secret. Only then mark the order paid.
- Also handle `payment.captured` and `order.paid` webhooks, in case the browser never returns.
Security checks (added to security-audit):
- The checkout signature is verified on the server before fulfillment (§13).
- Webhooks are verified with `validateWebhookSignature` on the raw, unparsed body and the webhook secret (§15).
Sources: https://razorpay.com/docs/payments/server-integration/nodejs/integration-steps/, https://razorpay.com/docs/webhooks/validate-test/

## Option: paddle
Setup: Paddle Billing with Paddle.js on the client and the server SDK for webhooks. Products and prices are defined in Paddle.
Security checks (added to security-audit):
- Webhooks verify Paddle's signature on the raw body (§15).
Sources: https://developer.paddle.com

## Option: stripe-managed-payments
Setup: `stripe` on the server and Stripe Checkout, configured for Managed Payments as described in Stripe's docs for your account. Env: `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`, and the publishable key for the client. Confirm country availability and the fee before choosing it.
Conventions:
- Fulfill from `checkout.session.completed` and `invoice.paid` webhooks.
Security checks (added to security-audit):
- The webhook verifies its signature with `stripe.webhooks.constructEvent` on the raw request body (§15).
Sources: https://docs.stripe.com

## Shared
Conventions:
- Prices live in the provider and are referenced by ID. The client never sends an amount.
- Fulfill only from a verified webhook or server-side verification, never from the browser's redirect to a success page.
- Webhook handling is idempotent: store processed event or payment IDs and skip repeats.
- Store the provider's customer and payment or subscription IDs on your records. Use test-mode keys outside production.
Security checks (added to security-audit):
- Amounts are decided on the server (§13).
- Secret keys and webhook secrets are server-only env vars; only publishable keys or key IDs reach the browser (§5).
- Card data never touches your server; use the provider's hosted checkout or embedded fields (§11).
- Access to paid features checks payment or subscription status on the server on every request (§3).
Performance checks (added to performance-audit):
- The provider's checkout script loads only on pages that take payment.
