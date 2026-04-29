"use client";

import React from "react";
import {
  EuiFlexGroup,
  EuiFlexItem,
  EuiStat,
  EuiButton,
  EuiBadge,
  EuiIcon,
  EuiText,
  EuiSpacer,
  EuiTitle,
  EuiPanel,
  useEuiTheme,
} from "@elastic/eui";
import { getThemeStyles } from "@/styles/themeStyles";

const Analytics: React.FC<any> = ({ setStep, exportStats, setProjects, setSelectedKeys, setExportStats }) => {
  const { euiTheme } = useEuiTheme();
  const themeStyles = getThemeStyles(euiTheme);

  const getSeverityColor = (severity: string): string => {
    switch (severity.toUpperCase()) {
      case "BLOCKER":
        return "danger";
      case "CRITICAL":
        return "warning";
      case "MAJOR":
        return "accent";
      case "MINOR":
        return "primary";
      case "INFO":
        return "hollow";
      default:
        return "subdued";
    }
  };

  const severityIcons: Record<string, string> = {
    BLOCKER: "securitySignalDetected",
    CRITICAL: "errorFilled",
    MAJOR: "warningFilled",
    MINOR: "warning",
    INFO: "iInCircle",
  };

  const severityData = ["BLOCKER", "CRITICAL", "MAJOR", "MINOR", "INFO"].map((severity) => ({
    severity,
    count: exportStats.severityBreakdown?.[severity] ?? 0,
    color: getSeverityColor(severity),
    icon: severityIcons[severity],
  }));

  const getColorValue = (colorName: string): string => {
    switch (colorName) {
      case "danger":
        return euiTheme.colors.danger;
      case "warning":
        return euiTheme.colors.warning;
      case "accent":
        return euiTheme.colors.accent;
      case "primary":
        return euiTheme.colors.primary;
      case "success":
        return euiTheme.colors.success;
      default:
        return euiTheme.colors.primary;
    }
  };

  const totalIssues = exportStats.totalIssues ?? 0;

  return (
    <EuiFlexGroup direction="column" alignItems="center" gutterSize="s">
      <EuiFlexItem grow={false}>
        <EuiFlexGroup alignItems="center" gutterSize="none" justifyContent="center">
          <EuiFlexItem grow={false}>
            <EuiTitle size="s">
              <h3 style={{ margin: 0, color: euiTheme.colors.success }}>Analysis Complete</h3>
            </EuiTitle>
          </EuiFlexItem>
        </EuiFlexGroup>
      </EuiFlexItem>
      <EuiSpacer size="s" />
      <EuiFlexGroup justifyContent="center" gutterSize="m" style={{ width: "100%" }}>
        <EuiFlexItem>
          <EuiPanel paddingSize="s" color="danger" style={{ textAlign: "center" }}>
            <EuiStat title={totalIssues} description="Issues" titleColor="danger" titleSize="l" textAlign="center" />
          </EuiPanel>
        </EuiFlexItem>
      </EuiFlexGroup>
      <EuiSpacer size="s" />

      <EuiFlexItem style={{ width: "100%" }}>
        <EuiText size="s" style={{ textAlign: "center", marginBottom: 8 }}>
          <strong>Severity Distribution</strong>
        </EuiText>

        <EuiSpacer size="s" />
        <EuiFlexGroup gutterSize="xs" justifyContent="center" wrap>
          {severityData
            .filter((item) => item.count > 0)
            .map((item) => (
              <EuiFlexItem key={item.severity} grow={false}>
                <EuiPanel
                  paddingSize="s"
                  style={{
                    textAlign: "center",
                    minWidth: "80px",
                    background: `${getColorValue(item.color)}10`,
                  }}
                >
                  <EuiIcon type={item.icon} color={item.color} size="m" />
                  <EuiText size="xs" style={{ margin: "4px 0 2px 0" }}>
                    <strong>{item.count}</strong>
                  </EuiText>
                  <EuiBadge color={item.color} style={{ fontSize: "10px" }}>
                    {item.severity}
                  </EuiBadge>
                </EuiPanel>
              </EuiFlexItem>
            ))}
        </EuiFlexGroup>
      </EuiFlexItem>

      <EuiSpacer size="s" />

      <EuiFlexGroup justifyContent="center" gutterSize="s">
        <EuiFlexItem grow={false}>
          <EuiButton size="s" iconType="arrowLeft" onClick={() => setStep("list")} style={themeStyles.buttonSecondary}>
            New Report
          </EuiButton>
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiButton
            size="s"
            iconType="refresh"
            color="primary"
            fill
            onClick={() => {
              setStep("auth");
              setProjects([]);
              setSelectedKeys([]);
              setExportStats(null);
            }}
            style={themeStyles.button}
          >
            New Connection
          </EuiButton>
        </EuiFlexItem>
      </EuiFlexGroup>
    </EuiFlexGroup>
  );
};

export default Analytics;
