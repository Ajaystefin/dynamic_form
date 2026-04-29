"use client";

import React, { createContext, useContext, useEffect, useState, useMemo } from "react";
import { EuiProvider, EuiThemeModifications } from "@elastic/eui";

export type ColorMode = "light" | "dark";

interface ThemeContextProps {
  colorMode: ColorMode;
  setColorMode: (mode: ColorMode) => void;
  customTheme: EuiThemeModifications;
}

const ThemeContext = createContext<ThemeContextProps>({
  colorMode: "dark",
  setColorMode: () => {},
  customTheme: {},
});

const customTheme: EuiThemeModifications = {
  colors: {
    DARK: {
      primary: "#089c3b",
      success: "#3da751",
      accent: "#5bb366",
      warning: "#ffc107",
      accentSecondary: "#17a2b8",
      danger: "#dc3545",
      body: "#141414",
      backgroundBasePlain: "#1a1a1a",
      backgroundBaseSubdued: "#2a2a2a",
      backgroundBaseDisabled: "#333333",
      backgroundBaseRisk: "#1f1f1f",
      text: "#ffffff",
      textAccent: "#ffffff",
      textSubdued: "#cccccc",
      textDisabled: "#888888",
      lightShade: "#1e1e1e",
      mediumShade: "#2d2d2d",
      darkShade: "#383838",
      fullShade: "#ffffff",
      borderBaseAccent: "#444444",
      borderBaseSubdued: "#333333",
      borderBasePlain: "#555555",
      shadow: "rgba(0, 0, 0, 0.3)",
    },
    LIGHT: {
      primary: "#089c3b",
      success: "#3da751",
      accent: "#5bb366",
      warning: "#ffc107",
      accentSecondary: "#17a2b8",
      danger: "#dc3545",

      body: "#ffffff",
      backgroundBasePlain: "#f5f5f5",
      backgroundBaseSubdued: "#eeeeee",
      backgroundBaseDisabled: "#e0e0e0",
      backgroundBaseRisk: "#fafafa",

      text: "#141414",
      textAccent: "#141414",
      textSubdued: "#666666",
      textDisabled: "#aaaaaa",

      lightShade: "#ffffff",
      mediumShade: "#cccccc",
      darkShade: "#999999",
      fullShade: "#000000",

      borderBaseAccent: "#dddddd",
      borderBaseSubdued: "#e0e0e0",
      borderBasePlain: "#cccccc",

      shadow: "rgba(0, 0, 0, 0.1)",
    },
  },
  font: {
    family: "Inter, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
    weight: {
      light: 300,
      regular: 400,
      medium: 500,
      semiBold: 600,
      bold: 700,
    },
  },
  size: {
    xs: "4px",
    s: "8px",
    m: "12px",
    base: "16px",
    l: "24px",
    xl: "32px",
    xxl: "40px",
  },
  border: {
    width: {
      thin: "1px",
      thick: "2px",
    },
    radius: {
      small: "4px",
      medium: "8px",
    },
  },
};

export const ThemeProvider = ({ children }: { children: React.ReactNode }) => {
  const [colorMode, setColorMode] = useState<ColorMode>("dark");

  useEffect(() => {
    // Verifica se estamos no cliente antes de acessar window
    if (typeof window !== "undefined") {
      // Primeiro, tenta recuperar a preferência salva
      const savedMode = localStorage.getItem("theme-mode") as ColorMode;

      if (savedMode && (savedMode === "light" || savedMode === "dark")) {
        setColorMode(savedMode);
      } else {
        // Se não há preferência salva, usa a do sistema
        const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
        setColorMode(prefersDark ? "dark" : "light");
      }
    }
  }, []);

  // Salva a preferência do usuário no localStorage
  useEffect(() => {
    if (typeof window !== "undefined") {
      localStorage.setItem("theme-mode", colorMode);
    }
  }, [colorMode]);

  const value = useMemo(() => ({ colorMode, setColorMode, customTheme }), [colorMode]);

  return (
    <ThemeContext.Provider value={value}>
      <EuiProvider colorMode={colorMode} modify={customTheme}>
        {children}
      </EuiProvider>
    </ThemeContext.Provider>
  );
};

export const useAppTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error("useAppTheme must be used within a ThemeProvider");
  }
  return context;
};
