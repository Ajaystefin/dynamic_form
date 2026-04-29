"use client";

import React from "react";
import { EuiFlexGroup, EuiFlexItem, EuiTitle, EuiText, EuiLoadingSpinner, EuiProgress } from "@elastic/eui";

const Exporting: React.FC<any> = ({ exportProgress }) => {
  return (
    <EuiFlexGroup direction="column" alignItems="center" gutterSize="m">
      <EuiFlexItem grow={false}>
        <EuiLoadingSpinner size="xl" />
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiTitle size="m">
          <h2>Generating your report...</h2>
        </EuiTitle>
        <EuiText color="subdued" size="s">
          <p>
            We are processing data from SonarQube. This process may take a few minutes depending on the
            complexity of the projects.
          </p>
        </EuiText>
      </EuiFlexItem>

      <EuiFlexItem grow={false} style={{ width: "100%" }}>
        <EuiProgress value={exportProgress} max={100} color="accent" label />
      </EuiFlexItem>

      <EuiFlexItem grow={false}>
        <EuiText size="xs" color="subdued">
          <p>
            Do not close this tab until the export is complete. You will be notified when the download is ready.
          </p>
        </EuiText>
      </EuiFlexItem>
    </EuiFlexGroup>
  );
};
export default Exporting;
