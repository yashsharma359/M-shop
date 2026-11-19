create extension if not exists pgcrypto;

create type public.user_role as enum ('customer','admin');
create type public.product_status as enum ('draft','active','archived');
create type public.order_status as enum ('pending','confirmed','processing','shipped','out_for_delivery','delivered','cancelled','returned','refunded');
create type public.payment_status as enum ('pending','authorized','paid','failed','refunded');

create or replace function public.set_updated_at() returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  phone text,
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.addresses (
  id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
  label text, recipient_name text not null, phone text not null, line1 text not null, line2 text,
  city text not null, state text not null, postal_code text not null, country text not null default 'IN', is_default boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create unique index addresses_one_default_per_user on public.addresses(user_id) where is_default;
create table public.categories (
  id uuid primary key default gen_random_uuid(), parent_id uuid references public.categories(id) on delete set null,
  name text not null, slug text not null unique, description text, image_url text, sort_order integer not null default 0,
  is_active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.products (
  id uuid primary key default gen_random_uuid(), category_id uuid references public.categories(id) on delete set null,
  name text not null, slug text not null unique, subtitle text, description text, brand text,
  price numeric(12,2) not null check(price >= 0), compare_at_price numeric(12,2) check(compare_at_price is null or compare_at_price >= price),
  status public.product_status not null default 'draft', specifications jsonb not null default '{}',
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index products_status_category on public.products(status,category_id);
create index products_name_search on public.products using gin(to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(description,'')));
create table public.product_images (
  id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null, alt_text text, sort_order integer not null default 0, is_primary boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index product_images_product on public.product_images(product_id,sort_order);
create unique index product_one_primary_image on public.product_images(product_id) where is_primary;
create table public.product_variants (
  id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
  sku text unique, name text not null, options jsonb not null default '{}', price_delta numeric(12,2) not null default 0,
  is_active boolean not null default true, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.inventory (
  variant_id uuid primary key references public.product_variants(id) on delete cascade,
  quantity integer not null default 0 check(quantity >= 0), reserved integer not null default 0 check(reserved >= 0 and reserved <= quantity),
  updated_at timestamptz not null default now()
);
create table public.carts (
  id uuid primary key default gen_random_uuid(), user_id uuid not null unique references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.cart_items (
  id uuid primary key default gen_random_uuid(), cart_id uuid not null references public.carts(id) on delete cascade,
  variant_id uuid not null references public.product_variants(id) on delete cascade, quantity integer not null check(quantity > 0),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(cart_id,variant_id)
);
create table public.wishlists (
  id uuid primary key default gen_random_uuid(), user_id uuid not null unique references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.wishlist_items (
  id uuid primary key default gen_random_uuid(), wishlist_id uuid not null references public.wishlists(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(wishlist_id,product_id)
);
create table public.orders (
  id uuid primary key default gen_random_uuid(), order_number text not null unique default ('MS-' || upper(substr(encode(gen_random_bytes(8),'hex'),1,12))),
  user_id uuid not null references public.profiles(id), status public.order_status not null default 'pending',
  subtotal numeric(12,2) not null check(subtotal >= 0), shipping_amount numeric(12,2) not null default 0 check(shipping_amount >= 0),
  discount_amount numeric(12,2) not null default 0 check(discount_amount >= 0), total numeric(12,2) not null check(total >= 0),
  currency char(3) not null default 'INR', address_snapshot jsonb not null, notes text,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create index orders_user_date on public.orders(user_id,created_at desc);
create table public.order_items (
  id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null, variant_id uuid references public.product_variants(id) on delete set null,
  product_name text not null, sku text, variant_options jsonb not null default '{}', unit_price numeric(12,2) not null check(unit_price >= 0),
  quantity integer not null check(quantity > 0), created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.payments (
  id uuid primary key default gen_random_uuid(), order_id uuid not null references public.orders(id) on delete cascade,
  provider text not null default 'razorpay', provider_order_id text unique, provider_payment_id text unique,
  amount numeric(12,2) not null check(amount >= 0), status public.payment_status not null default 'pending', method text,
  idempotency_key text unique, verified_at timestamptz, raw_event jsonb,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.coupons (
  id uuid primary key default gen_random_uuid(), code text not null unique, discount_percent numeric(5,2) check(discount_percent > 0 and discount_percent <= 100),
  discount_amount numeric(12,2) check(discount_amount is null or discount_amount >= 0), minimum_amount numeric(12,2) not null default 0,
  starts_at timestamptz, expires_at timestamptz, usage_limit integer check(usage_limit is null or usage_limit > 0),
  redeemed_count integer not null default 0 check(redeemed_count >= 0), is_active boolean not null default true,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
  check ((discount_percent is not null)::int + (discount_amount is not null)::int = 1)
);
create table public.coupon_redemptions (
  id uuid primary key default gen_random_uuid(), coupon_id uuid not null references public.coupons(id),
  user_id uuid not null references public.profiles(id), order_id uuid not null unique references public.orders(id),
  created_at timestamptz not null default now(), unique(coupon_id,user_id,order_id)
);
create table public.reviews (
  id uuid primary key default gen_random_uuid(), product_id uuid not null references public.products(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade, order_item_id uuid references public.order_items(id) on delete set null,
  rating smallint not null check(rating between 1 and 5), title text, body text, is_approved boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(product_id,user_id)
);
create table public.banners (
  id uuid primary key default gen_random_uuid(), title text not null, image_url text, href text,
  starts_at timestamptz, ends_at timestamptz, sort_order integer not null default 0, is_active boolean not null default false,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.shipments (
  id uuid primary key default gen_random_uuid(), order_id uuid not null unique references public.orders(id) on delete cascade,
  carrier text, tracking_number text, tracking_url text, shipped_at timestamptz, delivered_at timestamptz,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table public.contact_messages (
  id uuid primary key default gen_random_uuid(), name text not null, email text not null, subject text, message text not null,
  status text not null default 'new' check(status in ('new','in_progress','resolved','spam')),
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- Roles are assigned by trusted administrators only. The client cannot elevate itself.
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = public as $$
begin insert into public.profiles(id,email,full_name) values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name','')); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

do $$ declare t text; begin
  foreach t in array array['profiles','addresses','categories','products','product_images','product_variants','inventory','carts','cart_items','wishlists','wishlist_items','orders','order_items','payments','coupons','coupon_redemptions','reviews','banners','shipments','contact_messages'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('create policy "admin full access" on public.%I for all to authenticated using (public.is_admin()) with check (public.is_admin())',t);
  end loop;
end $$;

create policy "profile owner read" on public.profiles for select to authenticated using (id=auth.uid() or public.is_admin());
create policy "profile owner update" on public.profiles for update to authenticated using (id=auth.uid() or public.is_admin()) with check (id=auth.uid() or public.is_admin());
create or replace function public.prevent_customer_role_change() returns trigger language plpgsql security definer set search_path=public as $$
begin if old.role is distinct from new.role and not public.is_admin() then raise exception 'Only an administrator can change account roles'; end if; return new; end; $$;
create trigger protect_profile_role before update on public.profiles for each row execute function public.prevent_customer_role_change();
create policy "address owner access" on public.addresses for all to authenticated using (user_id=auth.uid() or public.is_admin()) with check (user_id=auth.uid() or public.is_admin());
create policy "cart owner access" on public.carts for all to authenticated using (user_id=auth.uid() or public.is_admin()) with check (user_id=auth.uid() or public.is_admin());
create policy "cart item owner access" on public.cart_items for all to authenticated using (exists(select 1 from public.carts c where c.id=cart_id and c.user_id=auth.uid()) or public.is_admin()) with check (exists(select 1 from public.carts c where c.id=cart_id and c.user_id=auth.uid()) or public.is_admin());
create policy "wishlist owner access" on public.wishlists for all to authenticated using (user_id=auth.uid() or public.is_admin()) with check (user_id=auth.uid() or public.is_admin());
create policy "wishlist item owner access" on public.wishlist_items for all to authenticated using (exists(select 1 from public.wishlists w where w.id=wishlist_id and w.user_id=auth.uid()) or public.is_admin()) with check (exists(select 1 from public.wishlists w where w.id=wishlist_id and w.user_id=auth.uid()) or public.is_admin());
create policy "order owner read" on public.orders for select to authenticated using (user_id=auth.uid() or public.is_admin());
create policy "order item owner read" on public.order_items for select to authenticated using (exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()) or public.is_admin());
create policy "payment owner read" on public.payments for select to authenticated using (exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()) or public.is_admin());
create policy "redemption owner read" on public.coupon_redemptions for select to authenticated using (user_id=auth.uid() or public.is_admin());
create policy "review owner insert" on public.reviews for insert to authenticated with check (user_id=auth.uid() and not is_approved);

create policy "published catalog readable" on public.categories for select to anon, authenticated using (is_active);
create policy "active products readable" on public.products for select to anon, authenticated using (status = 'active');
create policy "active product images readable" on public.product_images for select to anon, authenticated using (exists(select 1 from public.products p where p.id=product_id and p.status='active'));
create policy "active variants readable" on public.product_variants for select to anon, authenticated using (is_active and exists(select 1 from public.products p where p.id=product_id and p.status='active'));
create policy "inventory readable" on public.inventory for select to anon, authenticated using (true);
create policy "approved reviews readable" on public.reviews for select to anon, authenticated using (is_approved or user_id=auth.uid() or public.is_admin());
create policy "active banners readable" on public.banners for select to anon, authenticated using (is_active and (starts_at is null or starts_at <= now()) and (ends_at is null or ends_at >= now()));

do $$ declare t text; begin
  foreach t in array array['profiles','addresses','categories','products','product_images','product_variants','carts','cart_items','wishlists','wishlist_items','orders','order_items','payments','coupons','reviews','banners','shipments','contact_messages'] loop
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',t);
  end loop;
end $$;
