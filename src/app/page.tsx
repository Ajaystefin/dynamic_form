"use client";

import dynamic from "next/dynamic";
const Home = dynamic(() => import("./Home"), { ssr: false });
import '../styles/global.css';

export default function Page() {
  return <Home />;
}
