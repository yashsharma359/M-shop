import Link from "next/link";
import { ArrowDownRight, ArrowRight, ArrowUpRight, Sparkles } from "lucide-react";
import { demoProducts } from "@/lib/demo-data";
import { NewsletterForm } from "@/components/NewsletterForm";

export default async function HomePage() {
  const products = demoProducts.slice(0, 8);
  return <main>
    <section className="hero"><div className="hero-copy"><span className="eyebrow"><Sparkles size={14}/> THE EVERYDAY EDITION · NO. 01</span><h1>Everyday,<br/><em>reimagined.</em></h1><p>Objects that earn their place in your everyday. Thoughtful design, made to last.</p><Link className="button button-dark" href="/shop">Explore the collection <ArrowRight size={16}/></Link><div className="hero-note"><span className="note-line"/> Independently selected, always considered</div></div><div className="hero-art" aria-label="Minimal still life of home objects"><div className="art-sun"/><div className="art-vase vase-one"/><div className="art-vase vase-two"/><div className="art-book book-one"/><div className="art-book book-two"/><div className="art-caption">STILL LIFE NO. 04 <span>OBJECTS IN BALANCE</span></div><div className="art-index">01 / 04</div></div><a className="scroll-cue" href="#collection"><span>SCROLL TO DISCOVER</span><ArrowDownRight size={16}/></a></section>
    <section className="promise-strip"><span>01 — Made with intention</span><span>02 — Quality over quantity</span><span>03 — A little more considered</span></section>
    <section className="section collection" id="collection"><div className="section-heading"><div><span className="eyebrow">A GOOD PLACE TO START</span><h2>The collection</h2></div><Link className="text-link" href="/shop">View everything <ArrowUpRight size={15}/></Link></div>
      <div className="product-grid">{products.map((product) => <Link className="product-card" href={`/products/${product.slug}`} key={product.id}><div className="product-image" style={{backgroundImage:`url(${product.image})`}}><span>{product.category}</span></div><div className="product-info"><div><h3>{product.name}</h3><p>{product.subtitle}</p></div><strong>₹{product.price.toLocaleString("en-IN")}</strong></div></Link>)}</div>
    </section>
    <section className="editorial" id="story"><div className="editorial-art"><span>THE ART OF LESS,</span><span>DONE BETTER.</span><small>FIELD NOTES · 001</small></div><div className="editorial-copy"><span className="eyebrow">A NOTE ON HOW WE CHOOSE</span><h2>Less, but<br/><em>more meaningful.</em></h2><p>We believe the things around us should make daily life feel a little more considered. M Shop is a growing edit of useful, enduring pieces chosen for how they work — and how they make you feel.</p><Link className="text-link" href="/about">A little more about us <ArrowUpRight size={15}/></Link></div></section>
    <section className="newsletter" id="journal"><span className="eyebrow">A LETTER, EVERY SO OFTEN</span><h2>Good things in your inbox.</h2><p>New finds, thoughtful notes, and the occasional good idea.</p><NewsletterForm/></section>
  </main>;
}
