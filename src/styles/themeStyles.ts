import { useEuiTheme } from "@elastic/eui";

export const getThemeStyles = (euiTheme: ReturnType<typeof useEuiTheme>["euiTheme"]) => ({
  icons: {
    success: "checkInCircleFilled",
    error: "cross",
    warning: "warning",
    info: "iInCircle",
    loading: "logoElastic",
    color: euiTheme.colors.primary,
  },

  fieldInput: {
    transition: "none",
    backgroundColor: euiTheme.colors.backgroundBaseRisk,
    color: euiTheme.colors.textAccent,
    border: `1px solid ${euiTheme.colors.borderBaseAccent}`,
    fontWeight: euiTheme.font.weight.medium,
    WebkitBoxShadow: `inset 0 0 0 1px ${euiTheme.colors.borderBaseAccent},inset 0 0 0 100vw ${euiTheme.colors.backgroundBaseRisk}`,
  },

  fieldInputFocus: {
    transition: "none",
    color: euiTheme.colors.textAccent,
    backgroundColor: euiTheme.colors.backgroundBaseRisk,
    border: `1px solid ${euiTheme.colors.borderBaseAccent}`,
    fontWeight: euiTheme.font.weight.medium,
    WebkitBoxShadow: `inset 0 0 0 1px ${euiTheme.colors.accent},inset 0 0 0 100vw ${euiTheme.colors.backgroundBaseRisk}`,
  },

  card: {
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    backgroundColor: euiTheme.colors.backgroundBaseRisk,
    borderRadius: euiTheme.size.base,
    padding: euiTheme.size.base,
    boxShadow: `0 2px 4px ${euiTheme.colors.shadow}`,
    transition: "all 0.2s ease",
    "&:hover": {
      boxShadow: `0 4px 8px ${euiTheme.colors.shadow}`,
    },
  },

  badge: {
    backgroundColor: euiTheme.colors.primary,
    color: euiTheme.colors.ghost,
    fontWeight: euiTheme.font.weight.bold,
    borderRadius: euiTheme.size.s,
    padding: `${euiTheme.size.xs} ${euiTheme.size.s}`,
    fontSize: euiTheme.size.m,
    display: "inline-block",
  },

  cardExport: {
    width: "100%",
    maxWidth: 400,
    margin: "auto",
    cursor: "pointer",
    borderRadius: euiTheme.size.base,
    transition: "all 0.3s ease",
    boxShadow: "none",
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseSubdued}`,
    backgroundColor: euiTheme.colors.backgroundBasePlain,
    "&:hover": {
      transform: "translateY(-2px)",
      boxShadow: `0 4px 12px ${euiTheme.colors.shadow}`,
      borderColor: euiTheme.colors.borderBaseAccent,
    },
  },

  progressContainer: {
    width: "100%",
    maxWidth: 480,
    padding: euiTheme.size.base,
    backgroundColor: euiTheme.colors.backgroundBaseSubdued,
    borderRadius: euiTheme.size.s,
  },

  iconBox: {
    backgroundColor: euiTheme.colors.backgroundBaseDisabled,
    selectedBg: `linear-gradient(135deg, ${euiTheme.colors.primary}, ${euiTheme.colors.success})`,
    padding: euiTheme.size.base,
    borderRadius: euiTheme.size.m,
    display: "flex",
    justifyContent: "center",
    alignItems: "center",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: euiTheme.colors.backgroundBaseSubdued,
    },
  },

  table: {
    border: "none",
    backgroundColor: "transparent !important",
    borderRadius: euiTheme.size.s,
    overflow: "hidden",
    "& thead": {
      backgroundColor: "transparent !important",
    },
    "& th": {
      borderBottom: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
      color: euiTheme.colors.textPrimary,
      fontWeight: euiTheme.font.weight.semiBold,
    },
    "& td": {
      borderBottom: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseSubdued}`,
      color: euiTheme.colors.textPrimary,
    },
    "& tr": {
      backgroundColor: euiTheme.colors.backgroundBasePlain,
    },
  },

  field: {
    backgroundColor: euiTheme.colors.backgroundBaseDisabled,
    borderColor: euiTheme.colors.borderBaseAccent,
    color: euiTheme.colors.textAccent,
    borderRadius: euiTheme.size.xs,
    padding: euiTheme.size.s,
    "&:focus": {
      borderColor: euiTheme.colors.primary,
      boxShadow: `0 0 0 2px ${euiTheme.colors.primary}33`,
    },
  },

  button: {
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    backgroundColor: euiTheme.colors.primary,
    color: euiTheme.colors.ghost,
    fontWeight: euiTheme.font.weight.medium,
    borderRadius: euiTheme.size.xs,
    padding: `${euiTheme.size.s} ${euiTheme.size.base}`,
    cursor: "pointer",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: euiTheme.colors.accent,
      transform: "translateY(-1px)",
    },
    "&:active": {
      transform: "translateY(0)",
    },
  },

  buttonSecondary: {
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    backgroundColor: "transparent",
    color: euiTheme.colors.textAccent,
    fontWeight: euiTheme.font.weight.medium,
    borderRadius: euiTheme.size.xs,
    padding: `${euiTheme.size.s} ${euiTheme.size.base}`,
    cursor: "pointer",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: euiTheme.colors.success,
      transform: "translateY(-1px)",
    },
    "&:active": {
      transform: "translateY(0)",
    },
  },

  buttonThirdy: {
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    backgroundColor: euiTheme.colors.accent,
    color: euiTheme.colors.textAccent,
    fontWeight: euiTheme.font.weight.medium,
    borderRadius: euiTheme.size.xs,
    padding: `${euiTheme.size.s} ${euiTheme.size.base}`,
    cursor: "pointer",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: euiTheme.colors.success,
      transform: "translateY(-1px)",
    },
    "&:active": {
      transform: "translateY(0)",
    },
  },

  buttonDelete: {
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    backgroundColor: euiTheme.colors.danger,
    color: euiTheme.colors.textAccent,
    fontWeight: euiTheme.font.weight.medium,
    borderRadius: euiTheme.size.xs,
    padding: `${euiTheme.size.s} ${euiTheme.size.base}`,
    cursor: "pointer",
    transition: "all 0.2s ease",
    "&:hover": {
      backgroundColor: euiTheme.colors.success,
      transform: "translateY(-1px)",
    },
    "&:active": {
      transform: "translateY(0)",
    },
  },

  stat: {
    backgroundColor: euiTheme.colors.backgroundBaseRisk,
    borderRadius: euiTheme.size.s,
    padding: euiTheme.size.base,
    minWidth: 120,
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseSubdued}`,
    title: {
      color: euiTheme.colors.success,
      fontWeight: euiTheme.font.weight.bold,
      fontSize: euiTheme.size.l,
      marginBottom: euiTheme.size.xs,
    },
    description: {
      color: euiTheme.colors.textSubdued,
      fontSize: euiTheme.size.m,
      fontWeight: euiTheme.font.weight.regular,
    },
  },

  timelineItem: {
    icon: {
      backgroundColor: euiTheme.colors.accent,
      color: euiTheme.colors.ghost,
      borderRadius: "50%",
      padding: euiTheme.size.s,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
    },
    verticalAlign: "center" as const,
    marginBottom: euiTheme.size.s,
    padding: euiTheme.size.s,
    borderLeft: `2px solid ${euiTheme.colors.borderBaseSubdued}`,
    "&:last-child": {
      borderLeft: "none",
    },
  },

  form: {
    maxWidth: 480,
    margin: "0 auto",
    padding: euiTheme.size.base,
    backgroundColor: euiTheme.colors.backgroundBasePlain,
    borderRadius: euiTheme.size.s,
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseSubdued}`,
  },

  popover: {
    width: 280,
    backgroundColor: euiTheme.colors.backgroundBasePlain,
  },

  titleCenter: {
    textAlign: "center" as const,
    color: euiTheme.colors.textAccent,
    fontWeight: euiTheme.font.weight.semiBold,
  },

  // Novos estilos adicionais
  container: {
    maxWidth: 1200,
    margin: "0 auto",
    padding: `0 ${euiTheme.size.base}`,
  },

  divider: {
    height: "1px",
    backgroundColor: euiTheme.colors.borderBaseSubdued,
    margin: `${euiTheme.size.base} 0`,
  },

  tooltip: {
    backgroundColor: euiTheme.colors.backgroundBasePlain,
    color: euiTheme.colors.textAccent,
    border: `${euiTheme.border.width.thin} solid ${euiTheme.colors.borderBaseAccent}`,
    borderRadius: euiTheme.size.xs,
    padding: euiTheme.size.s,
    fontSize: euiTheme.size.m,
    maxWidth: 250,
  },

  panel: {
    backgroundColor: euiTheme.colors.backgroundBaseRisk,
  },
});
