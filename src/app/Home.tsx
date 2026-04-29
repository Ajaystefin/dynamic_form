"use client";

import React, { useState } from "react";
import { handleExport } from "@/services/handleExport";
import { fetchProjects } from "@/services/handleFetch";
import { getThemeStyles } from "@/styles/themeStyles";
import logo from "@/assets/logo_brand.png";
import {
  EuiPage,
  EuiSpacer,
  EuiFlexGroup,
  EuiFlexItem,
  EuiText,
  EuiGlobalToastList,
  EuiPanel,
  EuiCard,
  useEuiTheme,
} from "@elastic/eui";
import Auth from "./components/Auth";
import List from "./components/List";
import Formats from "./components/Formats";
import Exporting from "./components/Exporting";
import Analytics from "./components/Analytics";
import { Project, ExportFormats, ExportStats, Toast } from "@/types";

const Home: React.FC = () => {
  const { euiTheme } = useEuiTheme();
  const themeStyles = getThemeStyles(euiTheme);
  const [orgKey, setOrgKey] = useState("");
  const [token, setToken] = useState("");
  const [projects, setProjects] = useState<Project[]>([]);
  const [selectedKeys, setSelectedKeys] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [step, setStep] = useState<"auth" | "list" | "formats" | "exporting" | "done">("auth");
  const [toasts, setToasts] = useState<Toast[]>([]);
  const [exportFormat, setExportFormat] = useState<ExportFormats>("json");
  const [exportProgress, setExportProgress] = useState(0);
  const [exportStats, setExportStats] = useState<ExportStats | null>(null);

  const addToast = (toast: Omit<Toast, "id">) => {
    setToasts((prev) => [...prev, { ...toast, id: Date.now().toString() }]);
  };

  const removeToast = (removedToast: string) => {
    setToasts(toasts.filter((toast) => toast.id !== removedToast));
  };

  const handleFetch = async () => {
    setLoading(true);
    const result = await fetchProjects({
      orgKey,
      token,
      addToast,
    });

    if ("projects" in result) {
      setProjects(result.projects);
      setSelectedKeys(result.projects.map((p) => p.key));
      setStep("list");
    } else {
      console.error("Error:", result.error);
    }

    setLoading(false);
  };

  const handleExportWrapper = () => {
    handleExport({
      token,
      selectedKeys,
      exportFormat,
      exportProgress,
      setExportStats,
      setExportProgress,
      addToast,
      setStep,
      setLoading,
    });
  };

  return (
    <EuiPage paddingSize="l" restrictWidth={true} grow>
      <EuiFlexGroup justifyContent="center" alignItems="center" style={{ height: "100vh" }}>
        <EuiFlexItem grow={false}>
          <EuiCard style={themeStyles.card} title="" paddingSize="l" hasBorder={true}>
            <EuiFlexGroup direction="column" alignItems="center" gutterSize="m">
              <EuiFlexItem grow={false}>
                <img src={logo.src} alt="Sonar Exporter Logo" style={{ height: 60 }} />
              </EuiFlexItem>

              <EuiFlexItem grow={false}>
                <EuiText color="subdued" textAlign="center">
                  <p style={{ marginTop: 4 }}>Export SAST reports simply</p>
                </EuiText>
              </EuiFlexItem>
            </EuiFlexGroup>

            <EuiSpacer size="l" />

            <EuiPanel hasShadow={false} paddingSize="l" style={themeStyles.panel}>
              {step === "auth" && (
                <Auth
                  fetchProjects={handleFetch}
                  loading={loading}
                  orgKey={orgKey}
                  setOrgKey={setOrgKey}
                  setToken={setToken}
                  token={token}
                />
              )}

              {step === "list" && (
                <List
                  selectedKeys={selectedKeys}
                  setStep={setStep}
                  setSelectedKeys={setSelectedKeys}
                  projects={projects}
                  setProjects={setProjects}
                  token={token}
                />
              )}

              {step === "formats" && (
                <Formats
                  selectedKeys={selectedKeys}
                  loading={loading}
                  handleExport={handleExportWrapper}
                  exportFormat={exportFormat}
                  setExportFormat={setExportFormat}
                />
              )}

              {step === "exporting" && <Exporting exportProgress={exportProgress} />}

              {step === "done" && exportStats && (
                <Analytics
                  setStep={setStep}
                  exportStats={exportStats}
                  setProjects={setProjects}
                  setSelectedKeys={setSelectedKeys}
                  setExportStats={setExportStats}
                />
              )}
            </EuiPanel>
          </EuiCard>
        </EuiFlexItem>
      </EuiFlexGroup>

      <EuiGlobalToastList toasts={toasts} dismissToast={(toast) => removeToast(toast.id)} toastLifeTimeMs={6000} />
    </EuiPage>
  );
};

export default Home;
