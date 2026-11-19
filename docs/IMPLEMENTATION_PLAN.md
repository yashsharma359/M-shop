# M Shop implementation plan

## Initial assessment

The supplied `M shop` directory was empty. No package manifest, source files, environment file, or project-specific instructions were present. Node.js is available in the current environment, but `npm` is not on PATH and network access is restricted, so dependency installation and a production build cannot currently be verified.

## Folder structure

```text
app/
  (store)/                 customer-facing routes
  admin/                   protected administration routes
  api/                     payment, webhook, and service endpoints
components/                shared UI and domain components
lib/                       Supabase, validation, business rules
supabase/migrations/       PostgreSQL schema and RLS
docs/                      implementation and operational notes
```

## Phases and acceptance criteria

1. **Foundation and design system** — app shell, responsive navigation, typography, tokens, error/loading/empty states. Pass: responsive pages render with keyboard-accessible controls.
2. **Database and catalog** — normalized tables, constraints, indexes, RLS, storage policies; catalog, filters, search, detail. Pass: customer reads only active catalog data; admin mutations are role checked.
3. **Auth and account** — Supabase auth, profile, addresses, password recovery, protected account routes. Pass: owner-only personal data enforced by RLS.
4. **Cart and checkout** — persisted cart, server-side stock and coupon validation, shipping calculation, atomic order reservation. Pass: concurrent checkout cannot oversell.
5. **Payments** — Razorpay order creation, signature verification, webhook verification, idempotency. Pass: only verified server-side events can mark payments paid.
6. **Admin** — metrics, product/category, order, inventory, coupon, customer, and content management. Pass: every admin endpoint and page checks trusted role server-side.
7. **Email and fulfillment** — Resend templates, order lifecycle, shipment tracking, returns/refunds. Pass: notifications follow verified state transitions and failures are observable/retryable.
8. **SEO, hardening, and release** — metadata, sitemap/robots, rate limits, headers, responsive QA, deployment guide. Pass: build/lint/security checks and integration tests pass with configured test services.

## Risks and dependencies

- Supabase project, Razorpay account/webhook secret, Resend API key/domain, and Vercel project are not supplied.
- SQL migrations and application wiring require validation against an actual Supabase project.
- Razorpay test mode credentials and webhook delivery are required to verify payment flows; production credentials must not be used in local testing.
- Current environment lacks npm, so install/build/test cannot be run until a package manager is available.

## Current progress

- **Phase 1: initial foundation complete.** Responsive visual system, storefront shell, SEO metadata, and product listing/detail views are present.
- **Phase 2: foundation started.** The first normalized schema migration covers the requested core entities and RLS policies; catalog reads are wired to Supabase. Filtering, pagination, seeded real inventory, storage policies, and live migration validation remain.
- **Cart: local prototype.** Product add, quantity adjustment, removal, and subtotal use browser local storage. Checkout is intentionally disabled until server-side inventory reservation, order creation, and verified payments exist.
- **Phases 3–8: pending.** Authentication flows, transactional checkout, Razorpay, full admin CRUD, Resend notifications, fulfillment, and configured-service acceptance checks remain.

## Validation run

- Dependencies installed from the npm registry into the project-local pnpm store.
- TypeScript check: `tsc --noEmit` passed.
- ESLint: `eslint app lib components` passed.
- Next.js production build compiled and passed TypeScript, then stopped during static prerender when the Windows sandbox denied a generated route-output directory (`EPERM`). This is an environment limitation; a clean production build remains unverified.
