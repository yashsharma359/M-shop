import { createClient } from "@/lib/supabase/server";

export type Product = { id: string; slug: string; name: string; subtitle: string | null; price: number; image: string | null; category: string | null };
type ProductRow = { id: string; slug: string; name: string; subtitle: string | null; price: number | string; product_images: { image_url: string; is_primary: boolean }[] | null; categories: { name: string } | { name: string }[] | null };

export async function getFeaturedProducts(): Promise<{ products: Product[]; configured: boolean }> {
  if (!process.env.NEXT_PUBLIC_SUPABASE_URL || !process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY) return { products: [], configured: false };
  try {
    const supabase = await createClient();
    const { data, error } = await supabase.from("products").select("id,slug,name,subtitle,price,product_images(image_url,is_primary),categories(name)").eq("status", "active").order("created_at", { ascending: false }).limit(8);
    if (error) return { products: [], configured: true };
    const rows = (data || []) as unknown as ProductRow[];
    return { configured: true, products: rows.map((p) => ({ id: p.id, slug: p.slug, name: p.name, subtitle: p.subtitle, price: Number(p.price), image: p.product_images?.find((i) => i.is_primary)?.image_url || p.product_images?.[0]?.image_url || null, category: (Array.isArray(p.categories) ? p.categories[0]?.name : p.categories?.name) || null })) };
  } catch { return { products: [], configured: true }; }
}
