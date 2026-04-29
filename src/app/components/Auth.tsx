"use client";

import React, { useState } from "react";
import {
  EuiForm,
  EuiFlexGroup,
  EuiFlexItem,
  EuiTitle,
  EuiButton,
  EuiFieldText,
  EuiFieldPassword,
  EuiPopover,
  EuiCode,
  EuiIcon,
  EuiText,
  EuiSpacer,
  EuiFormRow,
  useEuiTheme,
} from "@elastic/eui";
import { getThemeStyles } from "@/styles/themeStyles";

const Auth: React.FC<any> = ({ fetchProjects, loading, orgKey, setOrgKey, setToken, token }) => {
  const [isHelpPopoverOpen, setIsHelpPopoverOpen] = useState(false);
  const { euiTheme } = useEuiTheme();
  const themeStyles = getThemeStyles(euiTheme);
  const [isOrgFocused, setIsOrgFocused] = useState(false);
  const [isTokenFocused, setIsTokenFocused] = useState(false);

  return (
    <EuiForm component="form" style={themeStyles.form}>
      <EuiFlexGroup direction="column" alignItems="center" gutterSize="s">
        <EuiFlexItem grow={false}>
          <EuiIcon type="lock" size="xl" color={themeStyles.icons.color} />
        </EuiFlexItem>
        <EuiFlexItem grow={false}>
          <EuiTitle size="m">
            <h2 style={themeStyles.titleCenter}>Connect to SonarQube</h2>
          </EuiTitle>
        </EuiFlexItem>
      </EuiFlexGroup>

      <EuiSpacer size="xl" />

      <EuiFormRow label="Organization" helpText="Enter the organization key in SonarQube" fullWidth>
        <EuiFieldText
          value={orgKey}
          onChange={(e) => setOrgKey(e.target.value)}
          placeholder="e.g.: my-company"
          fullWidth
          style={{
            ...themeStyles.fieldInput,
            ...(isOrgFocused ? themeStyles.fieldInputFocus : {}),
          }}
          onFocus={() => setIsOrgFocused(true)}
          onBlur={() => setIsOrgFocused(false)}
        />
      </EuiFormRow>

      <EuiFormRow label="Authentication Token" helpText="Personal token generated in your SonarQube account" fullWidth> 
        <EuiFieldPassword
          value={token}
          type="dual"
          onChange={(e) => setToken(e.target.value)}
          placeholder="squ_..."
          fullWidth
          style={{
            ...themeStyles.fieldInput,
            ...(isTokenFocused ? themeStyles.fieldInputFocus : {}),
          }}
          onFocus={() => setIsTokenFocused(true)}
          onBlur={() => setIsTokenFocused(false)}
        />
      </EuiFormRow>

      <EuiSpacer size="m" />

      <EuiFlexGroup direction="columnReverse" alignItems="stretch" gutterSize="s">
        <EuiFlexItem grow={false}>
          <EuiButton
            style={themeStyles.button}
            onClick={fetchProjects}
            isLoading={loading}
            fill
            iconType="arrowRight"
            fullWidth
          >
            {loading ? "Connecting..." : "Connect to SonarQube"}
          </EuiButton>
        </EuiFlexItem>

        <EuiFlexItem grow={false}>
          <EuiPopover
            button={
              <EuiButton
                iconType="questionInCircle"
                style={themeStyles.buttonSecondary}
                color="primary"
                size="s"
                onClick={() => setIsHelpPopoverOpen(!isHelpPopoverOpen)}
                fullWidth
              >
                How to get your token?
              </EuiButton>
            }
            isOpen={isHelpPopoverOpen}
            closePopover={() => setIsHelpPopoverOpen(false)}
          >
            <div style={themeStyles.popover}>
              <EuiText size="s">
                <h4>Steps to generate the token:</h4>
                <ol style={{ paddingLeft: 16 }}>
                  <li>Access your SonarQube</li>
                  <li>
                    Go to <EuiCode>My Account → Security</EuiCode>
                  </li>
                  <li>Generate a new token</li>
                  <li>Paste in the field above</li>
                </ol>
                <EuiSpacer size="s" />
                <p>
                  <EuiIcon type="lock" size="s" /> Your token will not be stored.
                </p>
              </EuiText>
            </div>
          </EuiPopover>
        </EuiFlexItem>
      </EuiFlexGroup>
    </EuiForm>
  );
};

export default Auth;
