const axios = require('axios');
const { markBucketComplete, markBucketFailed, isBucketComplete, buildBucketId } = require('./checkpoint');

const SONAR_URL = (process.env.SONAR_URL || 'https://sonarcloud.io').replace(/\/$/, '');
const PAGE_SIZE = 500;
const MAX_ISSUES_PER_SEARCH = 10000;

// Severity and type dimensions to slice by — matched to what your API version supports
const DIMENSIONS = [
  { param: 'severities', values: ['BLOCKER', 'CRITICAL', 'MAJOR', 'MINOR', 'INFO'] },
  { param: 'types',      values: ['CODE_SMELL', 'BUG', 'VULNERABILITY'] },
  { param: 'statuses',   values: ['OPEN', 'CONFIRMED', 'REOPENED', 'RESOLVED', 'CLOSED'] },
];

// ─── Reusable HTTP client ────────────────────────────────────────────────────

async function apiCallWithRetry(url, token) {
  const RETRY_DELAYS = [500, 1000, 2000, 4000]; // exponential backoff
  let attempt = 0;

  while (true) {
    try {
      await new Promise(r => setTimeout(r, 200)); // enforced 200ms between all calls
      return await axios.get(url, {
        headers: { Authorization: `Basic ${Buffer.from(`${token}:`).toString('base64')}` },
        timeout: 30000,
      });
    } catch (error) {
      const status = error.response && error.response.status;

      if (status === 429) {
        const wait = 2000 * (attempt + 1);
        console.warn(`    ⚠️  Rate limited (429). Waiting ${wait}ms...`);
        await new Promise(r => setTimeout(r, wait));
        attempt++;
        continue;
      }

      if (status === 400) {
        // 400 = invalid parameter for this Sonar version — skip gracefully
        const detail = error.response.data ? JSON.stringify(error.response.data) : '';
        console.warn(`    ⚠️  400 Bad Request (unsupported param). Skipping. Details: ${detail}`);
        const err = new Error(`400 Bad Request: ${detail}`);
        err.isBadRequest = true;
        throw err;
      }

      if (status === 404) {
        console.error(`    🔴 404 Not Found. Check URL: ${url}`);
        throw error;
      }

      // Network / 5xx errors — retry with backoff
      if (attempt < RETRY_DELAYS.length) {
        const wait = RETRY_DELAYS[attempt];
        console.warn(`    ⚠️  Request failed (${status || error.code}). Retrying in ${wait}ms... (attempt ${attempt + 1})`);
        await new Promise(r => setTimeout(r, wait));
        attempt++;
        continue;
      }

      throw error;
    }
  }
}

// ─── Projects ────────────────────────────────────────────────────────────────

async function fetchProjects(orgKey, token) {
  try {
    console.log(`📡 Fetching projects for organization: ${orgKey}`);
    const res = await apiCallWithRetry(
      `${SONAR_URL}/api/components/search?organization=${orgKey}&qualifiers=TRK&ps=500`,
      token
    );
    const projects = res.data.components || [];
    console.log(`✅ Found ${projects.length} projects.`);
    return projects;
  } catch (error) {
    const msg = error.response ? JSON.stringify(error.response.data) : error.message;
    console.error(`❌ Error fetching projects:`, msg);
    return [];
  }
}

// ─── Issue count peek ────────────────────────────────────────────────────────

async function getTotalIssuesCount(projectKey, token, filters) {
  const params = new URLSearchParams({ componentKeys: projectKey, ps: '1', p: '1', ...filters });
  try {
    const res = await apiCallWithRetry(`${SONAR_URL}/api/issues/search?${params}`, token);
    const total = res.data.total || 0;
    console.log(`    👀 Peek | ${total} issues | Filters: ${JSON.stringify(filters)}`);
    return total;
  } catch (error) {
    if (error.isBadRequest) return -1; // signal to skip this bucket
    console.error(`    ❌ Error peeking count for filters ${JSON.stringify(filters)}:`, error.message);
    return 0;
  }
}

// ─── Page-by-page downloader ─────────────────────────────────────────────────

async function fetchAllPages(projectKey, token, filters, seenIssues, issueStream, checkpoint) {
  const maxPages = Math.ceil(MAX_ISSUES_PER_SEARCH / PAGE_SIZE);
  const params = new URLSearchParams({ componentKeys: projectKey, ps: String(PAGE_SIZE), ...filters });

  for (let page = 1; page <= maxPages; page++) {
    params.set('p', String(page));
    console.log(`    📡 Page ${page} | Filters: ${JSON.stringify(filters)}`);
    try {
      const res = await apiCallWithRetry(`${SONAR_URL}/api/issues/search?${params}`, token);
      const issues = res.data.issues || [];
      if (issues.length === 0) break;

      for (const issue of issues) {
        if (!seenIssues.has(issue.key)) {
          seenIssues.add(issue.key);
          issueStream.write(issue);
        }
      }

      if (issues.length < PAGE_SIZE) break;
    } catch (error) {
      if (error.isBadRequest) { console.warn(`    ⚠️  Skipping page ${page} due to 400.`); break; }
      console.error(`    ❌ Error on page ${page}:`, error.message);
      break;
    }
  }
}

// ─── Core recursive engine ───────────────────────────────────────────────────

async function fetchIssuesRecursively(projectKey, token, filters, dimensionIndex, seenIssues, issueStream, checkpoint) {
  const bucketId = buildBucketId('issues', { component: projectKey, ...filters });

  if (isBucketComplete(checkpoint, bucketId)) {
    console.log(`  ⏭️  Skipping (already done): ${bucketId}`);
    return;
  }

  const total = await getTotalIssuesCount(projectKey, token, filters);

  if (total === -1) {
    // 400 Bad Request — this filter combo isn't supported, skip it
    markBucketFailed(checkpoint, bucketId, '400 Bad Request — unsupported filter');
    return;
  }

  if (total === 0) return;

  // ── Base case: safe bucket ──────────────────────────────────────────────────
  if (total <= MAX_ISSUES_PER_SEARCH) {
    console.log(`  🎯 Bucket ${total} issues (Safe). Downloading...`);
    try {
      await fetchAllPages(projectKey, token, filters, seenIssues, issueStream, checkpoint);
      markBucketComplete(checkpoint, bucketId, total);
    } catch (err) {
      markBucketFailed(checkpoint, bucketId, err.message);
    }
    return;
  }

  console.log(`  ⚠️  Bucket ${total} issues (Exceeds 10k). Segmenting deeper...`);

  // ── Dimension slicing (Severity → Type → Status) ───────────────────────────
  if (dimensionIndex < DIMENSIONS.length) {
    const dim = DIMENSIONS[dimensionIndex];
    for (const val of dim.values) {
      await fetchIssuesRecursively(
        projectKey, token,
        { ...filters, [dim.param]: val },
        dimensionIndex + 1,
        seenIssues, issueStream, checkpoint
      );
    }
    return;
  }

  // ── Spatial recursion: traverse the component (folder/file) tree ────────────
  console.log(`  📂 Exhausted dimensions. Fetching component tree for: ${projectKey}`);
  const children = await fetchComponentTree(projectKey, token);

  if (children.length === 0) {
    console.warn(`  🚨 No children found but bucket > 10k. Downloading (will truncate at 10k).`);
    try {
      await fetchAllPages(projectKey, token, filters, seenIssues, issueStream, checkpoint);
      markBucketComplete(checkpoint, bucketId, total);
    } catch (err) {
      markBucketFailed(checkpoint, bucketId, err.message);
    }
    return;
  }

  for (const child of children) {
    await fetchIssuesRecursively(
      child.key, token,
      filters,
      dimensionIndex, // keep same index so spatial can recurse again if needed
      seenIssues, issueStream, checkpoint
    );
  }
}

async function fetchComponentTree(componentKey, token) {
  const children = [];
  let page = 1;
  while (true) {
    try {
      const res = await apiCallWithRetry(
        `${SONAR_URL}/api/components/tree?component=${componentKey}&ps=500&p=${page}`,
        token
      );
      const comps = res.data.components || [];
      for (const c of comps) children.push(c);
      if (comps.length < 500) break;
      page++;
    } catch (e) {
      console.error(`    ❌ Error fetching component tree for ${componentKey}:`, e.message);
      break;
    }
  }
  return children;
}

// ─── Public entry points ─────────────────────────────────────────────────────

async function fetchAllProjectIssues(projectKey, token, seenIssues, issueStream, checkpoint) {
  console.log(`\n📋 ISSUES FETCH: ${projectKey}`);
  await fetchIssuesRecursively(projectKey, token, {}, 0, seenIssues, issueStream, checkpoint);
}

module.exports = {
  fetchProjects,
  fetchAllProjectIssues,
  apiCallWithRetry,
};
