import { notFound } from "next/navigation";
import { DemoStore } from "@/components/DemoStore";
import { categoriesList } from "@/lib/demo-data";
export function generateStaticParams(){return categoriesList.map(name=>({slug:name.toLowerCase()}))}
export default async function CategoryPage({params}:{params:Promise<{slug:string}>}){const {slug}=await params;const category=categoriesList.find(name=>name.toLowerCase()===slug);if(!category)notFound();return <DemoStore view="shop" section={category}/>}
