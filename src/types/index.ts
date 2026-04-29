export interface Project {
  key: string;
  name: string;
}

export interface Toast {
  id: string;
  title: string;
  text?: string;
  color?: "success" | "danger" | "warning" | "primary";
  iconType?: string;
}

export type ExportFormats = "json" | "csv" | "pdf";

export interface ExportStats {
  totalIssues: number;
  projectCount: number;
  severityBreakdown: Record<string, number>;
}

export interface Params {
  token: string;
  selectedKeys: string[];
  exportFormat: ExportFormats;
  exportProgress: number;
  setExportStats: (s: ExportStats) => void;
  setExportProgress: (n: number) => void;
  addToast: (t: any) => void;
  setStep: (s: any) => void;
  setLoading: (b: boolean) => void;
}

export interface FetchProjectsParams {
  orgKey: string;
  token: string;
  addToast?: (toast: {
    title: string;
    text: string;
    color: "success" | "warning" | "danger";
    iconType: string;
  }) => void;
}