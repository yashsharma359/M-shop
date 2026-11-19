import Link from "next/link";
import { demoOrders } from "@/lib/demo-data";
export default function OrdersPage(){return <main className="demo-page"><span className="eyebrow">YOUR ACCOUNT</span><h1 className="demo-page-heading">Order history.</h1><p className="demo-intro">A preview of recent M Shop orders.</p>{demoOrders.slice(0,5).map(o=><article className="demo-admin-row" key={o.id}><strong>{o.id}</strong><span>{o.date}</span><span>{o.status}</span><Link href="/account/orders">View details</Link></article>)}</main>}
