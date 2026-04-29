"use client";

import { ThemeProvider, useAppTheme } from "@/context/ThemeContext";
import { EuiProvider } from "@elastic/eui";

interface Props {
  readonly children: React.ReactNode;
}

function EuiThemeWrapper({ children }: Props) {
  const { colorMode } = useAppTheme();
  return <EuiProvider colorMode={colorMode}>{children}</EuiProvider>;
}

export default function RootLayoutClient({ children }: Props) {
  return (
    <html lang="en">
      <body >
        <ThemeProvider>
          <EuiThemeWrapper>{children}</EuiThemeWrapper>
        </ThemeProvider>
      </body>
    </html>
  );
}
