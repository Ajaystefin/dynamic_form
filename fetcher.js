const axios = require('axios');

const PAGE_SIZE = 500;
const MAX_ISSUES_PER_SEARCH = 10000;
const SEVERITIES = ["BLOCKER", "CRITICAL", "MAJOR", "MINOR", "INFO"];
const TYPES = ["CODE_SMELL", "BUG", "VULNERABILITY", "SECURITY_HOTSPOT"];
const STATUSES = ["OPEN", "CONFIRMED", "REOPENED", "RESOLVED", "CLOSED"];

async function fetchProjects(orgKey, token) {
  try {
    const res = await axios.get(
      `https://sonarcloud.io/api/components/search?organization=${orgKey}&qualifiers=TRK`,
      {
        headers: {
          Authorization: `Basic ${Buffer.from(`${token}:`).toString('base64')}`,
        },
      }
    );
    return res.data.components || [];
  } catch (error) {
    console.error("Error fetching projects:", error.message);
    return [];
  }
}

async function fetchIssuesWithFilter(projectKey, token, filters = {}) {
  const issues = [];
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
      params.set('p', page.toString());

      const response = await axios.get(`https://sonarcloud.io/api/issues/search?${params.toString()}`, {
        headers: {
          Authorization: `Basic ${Buffer.from(`${token}:`).toString('base64')}`,
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
    } catch (error) {
      if (error.response && error.response.status === 429) {
        console.warn('Rate limited. Waiting 2 seconds...');
        await new Promise((resolve) => setTimeout(resolve, 2000));
        continue;
      }
      console.error(`Error fetching issues for ${projectKey}:`, error.message);
      hasMorePages = false;
    }
  }

  return issues;
}

async function fetchIssuesByDateRange(projectKey, token, filters, seenIssues, startDate) {
  const results = [];
  const now = new Date();
  const stepDays = 30;

  for (let d = new Date(startDate); d < now; d.setDate(d.getDate() + stepDays)) {
    const from = d.toISOString().split("T")[0];
    const to = new Date(d);
    to.setDate(d.getDate() + stepDays);
    const toStr = to.toISOString().split("T")[0];

    console.log(`  ⏱ Fetching from ${from} to ${toStr}...`);

    const issues = await fetchIssuesWithFilter(projectKey, token, {
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
}

async function fetchAllProjectIssues(projectKey, token) {
  const projectIssues = [];
  const seenIssues = new Set();

  for (const severity of SEVERITIES) {
    console.log(`  📊 Fetching issues with severity: ${severity}`);
    const issues = await fetchIssuesWithFilter(projectKey, token, { severities: severity });

    if (issues.length >= MAX_ISSUES_PER_SEARCH) {
      const dates = issues
        .map((i) => new Date(i.creationDate))
        .filter(Boolean)
        .sort((a, b) => a.getTime() - b.getTime());

      const minDate = dates[0];
      console.warn(`  ⚠️ Severity ${severity} reached 10k. Segmenting from ${minDate.toISOString().split("T")[0]}`);

      const segmented = await fetchIssuesByDateRange(projectKey, token, { severities: severity }, seenIssues, minDate);
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

  for (const type of TYPES) {
    const issues = await fetchIssuesWithFilter(projectKey, token, { types: type });
    for (const issue of issues) {
      if (!seenIssues.has(issue.key)) {
        seenIssues.add(issue.key);
        projectIssues.push(issue);
      }
    }
  }

  for (const status of STATUSES) {
    const issues = await fetchIssuesWithFilter(projectKey, token, { statuses: status });
    for (const issue of issues) {
      if (!seenIssues.has(issue.key)) {
        seenIssues.add(issue.key);
        projectIssues.push(issue);
      }
    }
  }

  if (projectIssues.length >= 40000) {
    for (const severity of SEVERITIES) {
      for (const type of TYPES) {
        const issues = await fetchIssuesWithFilter(projectKey, token, { severities: severity, types: type });
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
}

module.exports = {
  fetchProjects,
  fetchAllProjectIssues
};
