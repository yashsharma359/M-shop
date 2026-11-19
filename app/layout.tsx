import type { Metadata } from "next";
import "./globals.css";
import "./extra.css";
import "./demo.css";

export const metadata: Metadata = {
  title: { default: "M Shop — Considered essentials", template: "%s | M Shop" },
  description: "Discover well made essentials for everyday living at M Shop.",
  metadataBase: new URL(process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"),
  openGraph: { title: "M Shop", description: "Considered essentials for everyday living.", type: "website" },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="en"><body>{children}</body></html>;
}
