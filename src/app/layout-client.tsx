"use client";

import { ThemeProvider } from "@/context/ThemeContext";

interface Props {
  readonly children: React.ReactNode;
}


export default function RootLayoutClient({ children }: Props) {
  return (
    <html lang="en">
      <body >
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
