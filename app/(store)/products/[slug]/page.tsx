import { notFound } from "next/navigation";
import { DemoStore } from "@/components/DemoStore";
import { demoProducts } from "@/lib/demo-data";
export function generateStaticParams(){return demoProducts.map(p=>({slug:p.slug}))}
export default async function ProductPage({params}:{params:Promise<{slug:string}>}){const {slug}=await params;const product=demoProducts.find(p=>p.slug===slug);if(!product)notFound();return <DemoStore view="product" product={product}/>}
