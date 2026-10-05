import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "พร้อม — Demo",
  description: "โครงระบบทดสอบ local",
};
export default function Layout({ children }: { children: ReactNode }) {
  return (
    <html lang="th">
      <body>{children}</body>
    </html>
  );
}
