"use client";
import { useState } from "react";
import { ArrowRight } from "lucide-react";
export function NewsletterForm(){const [sent,setSent]=useState(false);return <><form onSubmit={e=>{e.preventDefault();setSent(true)}}><label className="sr-only" htmlFor="email">Email address</label><input id="email" type="email" placeholder="Your email address" required/><button type="submit" aria-label="Subscribe"><ArrowRight size={17}/></button></form><small>{sent?"You’re on the list — thank you.":"By subscribing, you agree to our privacy policy."}</small></>}
