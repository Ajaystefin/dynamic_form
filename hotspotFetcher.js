const { apiCallWithRetry } = require('./fetcher');
const { markBucketComplete, markBucketFailed, isBucketComplete, buildBucketId } = require('./checkpoint');

const SONAR_URL = (process.env.SONAR_URL || 'https://sonarcloud.io').replace(/\/$/, '');
const PAGE_SIZE = 500;
const MAX_PER_SEARCH = 10000;

// Hotspot statuses supported by the /api/hotspots/search endpoint
const HOTSPOT_STATUSES = ['TO_REVIEW', 'REVIEWED'];
const HOTSPOT_RESOLUTIONS = ['FIXED', 'SAFE', 'ACKNOWLEDGED'];

// ─── Count peek ───────────────────────────────────────────────────────────────

async function getTotalHotspotsCount(projectKey, token, filters) {
  const params = new URLSearchParams({ projectKey, ps: '1', p: '1', ...filters });
  try {
    const res = await apiCallWithRetry(`${SONAR_URL}/api/hotspots/search?${params}`, token);
    const total = res.data.paging ? res.data.paging.total : 0;
    console.log(`    👀 Hotspot Peek | ${total} hotspots | Filters: ${JSON.stringify(filters)}`);
    return total;
  } catch (error) {
    if (error.isBadRequest) return -1;
    console.error(`    ❌ Error peeking hotspot count:`, error.message);
    return 0;
  }
}

// ─── Page-by-page hotspot downloader ─────────────────────────────────────────

async function fetchHotspotPages(projectKey, token, filters, seenKeys, hotspotStream) {
  const maxPages = Math.ceil(MAX_PER_SEARCH / PAGE_SIZE);
  const params = new URLSearchParams({ projectKey, ps: String(PAGE_SIZE), ...filters });

  for (let page = 1; page <= maxPages; page++) {
    params.set('p', String(page));
    console.log(`    📡 Hotspot Page ${page} | Filters: ${JSON.stringify(filters)}`);
    try {
      const res = await apiCallWithRetry(`${SONAR_URL}/api/hotspots/search?${params}`, token);
      const hotspots = res.data.hotspots || [];
      if (hotspots.length === 0) break;

      for (const hs of hotspots) {
        if (!seenKeys.has(hs.key)) {
          seenKeys.add(hs.key);
          // Normalize hotspot fields to match the issues CSV column layout
          hotspotStream.write({
            key: hs.key,
            project: hs.project,
            type: 'SECURITY_HOTSPOT',
            severity: hs.vulnerabilityProbability || '',
            status: hs.status || '',
            resolution: hs.resolution || '',
            message: hs.message || '',
            component: hs.component,
            creationDate: hs.creationDate || '',
            updateDate: hs.updateDate || '',
            securityCategory: hs.securityCategory || '',
            rule: hs.ruleKey || '',
          });
        }
      }

      if (hotspots.length < PAGE_SIZE) break;
    } catch (error) {
      if (error.isBadRequest) { console.warn(`    ⚠️  Skipping hotspot page ${page} (400).`); break; }
      console.error(`    ❌ Error on hotspot page ${page}:`, error.message);
      break;
    }
  }
}

// ─── Recursive hotspot segmentation ─────────────────────────────────────────

async function fetchHotspotsRecursively(projectKey, token, filters, depth, seenKeys, hotspotStream, checkpoint) {
  const bucketId = buildBucketId('hotspots', { component: projectKey, ...filters });

  if (isBucketComplete(checkpoint, bucketId)) {
    console.log(`  ⏭️  Skipping hotspot bucket (already done): ${bucketId}`);
    return;
  }

  const total = await getTotalHotspotsCount(projectKey, token, filters);

  if (total === -1 || total === 0) return;

  // ── Safe bucket — download directly ──────────────────────────────────────
  if (total <= MAX_PER_SEARCH) {
    console.log(`  🎯 Hotspot bucket ${total} (Safe). Downloading...`);
    try {
      await fetchHotspotPages(projectKey, token, filters, seenKeys, hotspotStream);
      markBucketComplete(checkpoint, bucketId, total);
    } catch (err) {
      markBucketFailed(checkpoint, bucketId, err.message);
    }
    return;
  }

  console.log(`  ⚠️  Hotspot bucket ${total} (Exceeds 10k). Segmenting...`);

  // ── Depth 0: split by status ──────────────────────────────────────────────
  if (depth === 0) {
    for (const status of HOTSPOT_STATUSES) {
      await fetchHotspotsRecursively(projectKey, token, { ...filters, status }, depth + 1, seenKeys, hotspotStream, checkpoint);
    }
    return;
  }

  // ── Depth 1: split by resolution (only valid for REVIEWED status) ─────────
  if (depth === 1 && filters.status === 'REVIEWED') {
    for (const resolution of HOTSPOT_RESOLUTIONS) {
      await fetchHotspotsRecursively(projectKey, token, { ...filters, resolution }, depth + 1, seenKeys, hotspotStream, checkpoint);
    }
    return;
  }

  // ── Spatial recursion: traverse component tree ───────────────────────────
  console.log(`  📂 Hotspot bucket still > 10k. Fetching component tree for: ${projectKey}`);
  const children = [];
  let page = 1;
  while (true) {
    try {
      const res = await apiCallWithRetry(
        `${SONAR_URL}/api/components/tree?component=${projectKey}&ps=500&p=${page}`,
        token
      );
      const comps = res.data.components || [];
      for (const c of comps) children.push(c);
      if (comps.length < 500) break;
      page++;
    } catch (e) {
      console.error(`    ❌ Error fetching component tree:`, e.message);
      break;
    }
  }

  if (children.length === 0) {
    console.warn(`  🚨 No children found. Downloading hotspot bucket (may truncate at 10k).`);
    try {
      await fetchHotspotPages(projectKey, token, filters, seenKeys, hotspotStream);
      markBucketComplete(checkpoint, bucketId, total);
    } catch (err) {
      markBucketFailed(checkpoint, bucketId, err.message);
    }
    return;
  }

  for (const child of children) {
    await fetchHotspotsRecursively(child.key, token, filters, depth, seenKeys, hotspotStream, checkpoint);
  }
}

// ─── Public entry point ───────────────────────────────────────────────────────

async function fetchAllProjectHotspots(projectKey, token, seenKeys, hotspotStream, checkpoint) {
  console.log(`\n🔥 HOTSPOTS FETCH: ${projectKey}`);
  await fetchHotspotsRecursively(projectKey, token, {}, 0, seenKeys, hotspotStream, checkpoint);
}

module.exports = { fetchAllProjectHotspots };
