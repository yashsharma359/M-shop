import Link from "next/link";
const copy: Record<string,{title:string;body:string}> = {
  about:{title:"A little more considered.",body:"M Shop is a growing edit of useful, enduring pieces chosen for how they work — and how they make you feel. We believe good everyday design should be thoughtful, useful, and made to last."},
  contact:{title:"We’re here to help.",body:"For questions about an order or the collection, write to hello@mshop.example. Please include your order number when asking about an existing purchase."},
  shipping:{title:"Shipping & returns",body:"Delivery options, timelines, and return eligibility will be shown at checkout once fulfillment settings are configured. For help, contact our team before returning an item."},
  privacy:{title:"Privacy, plainly stated.",body:"Account and order information is used to provide the services you request. This site should be deployed with a published privacy notice tailored to your business, retention practices, and applicable law."},
};
export function generateStaticParams(){return Object.keys(copy).map((slug)=>({slug}));}
export default async function InfoPage({params}:{params:Promise<{slug:string}>}){const {slug}=await params;const page=copy[slug];if(!page)return <main className="shop-page"><h1>Page not found</h1><Link href="/">Return home</Link></main>;return <main className="info-page"><span className="eyebrow">M SHOP · INFORMATION</span><h1>{page.title}</h1><p>{page.body}</p>{slug==='contact'&&<a className="button button-dark" href="mailto:hello@mshop.example">Email the team</a>}</main>}
