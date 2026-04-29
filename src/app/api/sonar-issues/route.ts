import { NextRequest, NextResponse } from "next/server";
import axios from "axios";

export async function POST(req: NextRequest) {
  const body = await req.json();
  const { token, selectedKeys } = body;

  if (!token || !Array.isArray(selectedKeys)) {
    return NextResponse.json({ error: "Invalid parameters" }, { status: 400 });
  }

  const allIssues: any[] = [];
  const PAGE_SIZE = 500;
  const MAX_ISSUES_PER_SEARCH = 10000;

  try {
    const severities = ["BLOCKER", "CRITICAL", "MAJOR", "MINOR", "INFO"];
    const types = ["CODE_SMELL", "BUG", "VULNERABILITY", "SECURITY_HOTSPOT"];
    const statuses = ["OPEN", "CONFIRMED", "REOPENED", "RESOLVED", "CLOSED"];

    const fetchIssuesWithFilter = async (projectKey: string, filters: any = {}) => {
      const issues: any[] = [];
      let page = 1;
      let hasMorePages = true;

      const params = new URLSearchParams({
        componentKeys: projectKey,
        ps: PAGE_SIZE.toString(),
        p: page.toString(),
        ...filters,
      });

      while (hasMorePages && issues.length < MAX_ISSUES_PER_SEARCH) {
        try {
          params.set("p", page.toString());

          const response = await axios.get(`https://sonarcloud.io/api/issues/search?${params.toString()}`, {
            headers: {
              Authorization: `Basic ${Buffer.from(`${token}:`).toString("base64")}`,
            },
            timeout: 30000,
          });

          const data = response.data;
          if (!data.issues || data.issues.length === 0) break;

          issues.push(...data.issues);

          if (data.issues.length < PAGE_SIZE || issues.length >= Math.min(data.total, MAX_ISSUES_PER_SEARCH)) {
            hasMorePages = false;
          } else {
            page++;
          }

          await new Promise((resolve) => setTimeout(resolve, 100));
        } catch (error: any) {
          if (error.response?.status === 429) {
            await new Promise((resolve) => setTimeout(resolve, 2000));
            continue;
          }
          hasMorePages = false;
        }
      }

      return issues;
    };

    const fetchIssuesByDateRange = async (
      projectKey: string,
      filters: any,
      seenIssues: Set<string>,
      startDate: Date
    ) => {
      const results: any[] = [];
      const now = new Date();
      const stepDays = 30;

      for (let d = new Date(startDate); d < now; d.setDate(d.getDate() + stepDays)) {
        const from = d.toISOString().split("T")[0];
        const to = new Date(d);
        to.setDate(d.getDate() + stepDays);
        const toStr = to.toISOString().split("T")[0];

        console.log(`⏱ Fetching from ${from} to ${toStr}...`);

        const issues = await fetchIssuesWithFilter(projectKey, {
          ...filters,
          createdAfter: from,
          createdBefore: toStr,
        });

        for (const issue of issues) {
          if (!seenIssues.has(issue.key)) {
            seenIssues.add(issue.key);
            results.push(issue);
          }
        }
      }

      return results;
    };

    const fetchAllProjectIssues = async (projectKey: string) => {
      const projectIssues: any[] = [];
      const seenIssues = new Set<string>();

      for (const severity of severities) {
        console.log(`\n📊 Fetching issues with severity: ${severity}`);
        const issues = await fetchIssuesWithFilter(projectKey, { severities: severity });

        if (issues.length >= MAX_ISSUES_PER_SEARCH) {
          // Extrair a data mais antiga das 10k
          const dates = issues
            .map((i) => new Date(i.creationDate))
            .filter(Boolean)
            .sort((a, b) => a.getTime() - b.getTime());

          const minDate = dates[0]; // mais antiga

          console.warn(
            `⚠️ Severity ${severity} reached 10k. Segmenting from ${minDate.toISOString().split("T")[0]}`
          );

          const segmented = await fetchIssuesByDateRange(projectKey, { severities: severity }, seenIssues, minDate);
          projectIssues.push(...segmented);
        } else {
          for (const issue of issues) {
            if (!seenIssues.has(issue.key)) {
              seenIssues.add(issue.key);
              projectIssues.push(issue);
            }
          }
        }
      }

      for (const type of types) {
        const issues = await fetchIssuesWithFilter(projectKey, { types: type });
        for (const issue of issues) {
          if (!seenIssues.has(issue.key)) {
            seenIssues.add(issue.key);
            projectIssues.push(issue);
          }
        }
      }

      for (const status of statuses) {
        const issues = await fetchIssuesWithFilter(projectKey, { statuses: status });
        for (const issue of issues) {
          if (!seenIssues.has(issue.key)) {
            seenIssues.add(issue.key);
            projectIssues.push(issue);
          }
        }
      }

      if (projectIssues.length >= 40000) {
        for (const severity of severities) {
          for (const type of types) {
            const issues = await fetchIssuesWithFilter(projectKey, { severities: severity, types: type });
            for (const issue of issues) {
              if (!seenIssues.has(issue.key)) {
                seenIssues.add(issue.key);
                projectIssues.push(issue);
              }
            }
          }
        }
      }

      return projectIssues;
    };

    for (const projectKey of selectedKeys) {
      const projectIssues = await fetchAllProjectIssues(projectKey);
      allIssues.push(...projectIssues);
    }

    return NextResponse.json({
      issues: allIssues,
      summary: {
        totalIssues: allIssues.length,
        projectsProcessed: selectedKeys.length,
        projects: selectedKeys.map((key) => ({
          key,
          issuesCount: allIssues.filter((issue) => issue.component?.startsWith(key)).length,
        })),
      },
    });
  } catch (error: any) {
    return NextResponse.json(
      {
        error: error.message,
        partialResults:
          allIssues.length > 0
            ? {
                issues: allIssues,
                count: allIssues.length,
              }
            : null,
      },
      { status: 500 }
    );
  }
}
