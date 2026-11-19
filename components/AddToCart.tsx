"use client";

import { useState } from "react";
import { ShoppingBag } from "lucide-react";
import { CART_STORAGE_KEY, type CartLine } from "@/lib/cart-types";

export function AddToCart({ item, disabled }: { item: Omit<CartLine,"quantity">; disabled: boolean }) {
  const [added,setAdded]=useState(false);
  function add(){try{const current=JSON.parse(localStorage.getItem(CART_STORAGE_KEY)||"[]") as CartLine[];const exists=current.find((line)=>line.variantId===item.variantId);const next=exists?current.map((line)=>line.variantId===item.variantId?{...line,quantity:line.quantity+1}:line):[...current,{...item,quantity:1}];localStorage.setItem(CART_STORAGE_KEY,JSON.stringify(next));setAdded(true);window.setTimeout(()=>setAdded(false),1800);}catch{setAdded(false);}}
  return <button className="button button-dark" disabled={disabled} onClick={add}><ShoppingBag size={15}/>{added?"Added to bag":"Add to bag"}</button>;
}
