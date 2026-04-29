import type { Metadata } from "next";
import RootLayoutClient from "./layout-client";

export const metadata: Metadata = {
  title: "Sonar Exporter",
  description: "Export SonarQube data",
};

interface Props {
  readonly children: React.ReactNode;
}

export default function RootLayout({ children }: Props) {
  return <RootLayoutClient>{children}</RootLayoutClient>;
}
