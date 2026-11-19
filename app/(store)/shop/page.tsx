import { Suspense } from "react";
import { DemoStore } from "@/components/DemoStore";
export default function ShopPage(){return <Suspense fallback={<main className="demo-page">Loading the collection…</main>}><DemoStore view="shop"/></Suspense>}
