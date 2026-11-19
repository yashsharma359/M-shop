# M Shop

Professional single-vendor e-commerce application built with Next.js App Router, TypeScript, Tailwind CSS, Supabase, Razorpay, and Resend.

## Current state

This repository starts as an empty folder. The initial scaffold and implementation plan are being established. Live catalog, authentication, payments, email, and admin operations require the external credentials listed in `.env.example` and the Supabase migration to be applied. The storefront must not claim a payment, order, or notification succeeded until the server verifies it.

## Development

Requires Node.js 20+ and npm. Install dependencies with `npm install`, copy `.env.example` to `.env.local`, then run `npm run dev`. No dependencies are vendored in this initial scaffold.

## Project map

- `app/` — App Router pages, route handlers, and styles
- `components/` — reusable storefront and dashboard UI
- `lib/` — server and browser integrations, validation, and helpers
- `supabase/migrations/` — schema, constraints, indexes, and RLS policies
- `docs/IMPLEMENTATION_PLAN.md` — phase plan, dependencies, and completion criteria

## Setup notes

1. Create a Supabase project and apply the SQL files in `supabase/migrations/` in order.
2. Configure auth redirect URLs and private product image storage.
3. Set server-only Supabase service role, Razorpay, and Resend secrets in the deployment environment. Never prefix secrets with `NEXT_PUBLIC_`.
4. Configure Razorpay webhooks to the documented API route and verify with Razorpay test credentials before enabling live mode.
5. Promote an administrator through a trusted database operation; never allow a customer to set their own role.
6. Deploy to Vercel after build and security checks pass.

## Important

The application intentionally does not seed fake products, fabricate payment success, or report external services as connected. Until credentials are present, integration-dependent flows should explain the setup requirement and remain unavailable.
