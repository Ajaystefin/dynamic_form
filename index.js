require('dotenv').config();

const { fetchProjects, fetchAllProjectIssues } = require('./fetcher');
const { fetchAllProjectHotspots } = require('./hotspotFetcher');
const { createCsvStream, exportToJson } = require('./exporter');
const {
  loadCheckpoint,
  createCheckpoint,
  clearCheckpoint,
  saveCheckpoint,
} = require('./checkpoint');

const SONAR_TOKEN    = process.env.SONAR_TOKEN;
const SONAR_ORG_KEY  = process.env.SONAR_ORG_KEY;
const EXPORT_FORMAT  = (process.env.EXPORT_FORMAT || 'csv').toLowerCase();
const PROJECT_KEYS   = process.env.PROJECT_KEYS
  ? process.env.PROJECT_KEYS.split(',').map(s => s.trim()).filter(Boolean)
  : [];

// Pass --fresh flag to ignore any existing checkpoint and start over
const FORCE_FRESH = process.argv.includes('--fresh');

async function main() {
  if (!SONAR_TOKEN || !SONAR_ORG_KEY) {
    console.error('❌ Missing SONAR_TOKEN or SONAR_ORG_KEY in .env file');
    process.exit(1);
  }

  // ── Resolve project list ───────────────────────────────────────────────────
  let keysToExport = PROJECT_KEYS;

  if (keysToExport.length === 0) {
    const projects = await fetchProjects(SONAR_ORG_KEY, SONAR_TOKEN);
    if (projects.length === 0) {
      console.log('⚠️  No projects found or failed to fetch projects.');
      return;
    }
    keysToExport = projects.map(p => p.key);
    console.log(`✅ Found ${keysToExport.length} projects.`);
  } else {
    console.log(`🎯 Using provided project keys: ${keysToExport.join(', ')}`);
  }

  // ── Checkpoint / Resume ────────────────────────────────────────────────────
  if (FORCE_FRESH) {
    clearCheckpoint();
    console.log('🆕 Starting fresh (--fresh flag detected).');
  }

  let checkpoint = loadCheckpoint();

  // If checkpoint is for a different project, start fresh automatically
  if (checkpoint && !keysToExport.includes(checkpoint.projectKey)) {
    console.warn(`⚠️  Checkpoint is for project "${checkpoint.projectKey}" but we are now exporting "${keysToExport[0]}". Starting fresh.`);
    clearCheckpoint();
    checkpoint = null;
  }

  if (!checkpoint) {
    checkpoint = createCheckpoint(keysToExport[0]);
  }

  // ── Output files ──────────────────────────────────────────────────────────
  const timestamp = new Date().toISOString().split('T')[0];
  const issuesFile   = `sonar-issues-${timestamp}.csv`;
  const hotspotsFile = `sonar-hotspots-${timestamp}.csv`;

  const issueStream   = createCsvStream(issuesFile);
  const hotspotStream = createCsvStream(hotspotsFile);

  // Shared dedup sets across all projects
  const seenIssues   = new Set();
  const seenHotspots = new Set();

  let totalIssues   = 0;
  let totalHotspots = 0;

  // ── Fetch loop ─────────────────────────────────────────────────────────────
  for (const projectKey of keysToExport) {
    console.log(`\n${'─'.repeat(60)}`);
    console.log(`🚀 Project: ${projectKey}`);
    console.log(`${'─'.repeat(60)}`);

    const beforeIssues   = seenIssues.size;
    const beforeHotspots = seenHotspots.size;

    await fetchAllProjectIssues(projectKey, SONAR_TOKEN, seenIssues, issueStream, checkpoint);
    await fetchAllProjectHotspots(projectKey, SONAR_TOKEN, seenHotspots, hotspotStream, checkpoint);

    const newIssues   = seenIssues.size - beforeIssues;
    const newHotspots = seenHotspots.size - beforeHotspots;

    totalIssues   += newIssues;
    totalHotspots += newHotspots;

    checkpoint.counts = { issues: seenIssues.size, hotspots: seenHotspots.size };
    saveCheckpoint(checkpoint);

    console.log(`\n  📦 ${projectKey}: ${newIssues} issues + ${newHotspots} hotspots fetched.`);
  }

  // ── Close streams ──────────────────────────────────────────────────────────
  await issueStream.end();
  await hotspotStream.end();

  // ── Final summary ──────────────────────────────────────────────────────────
  console.log(`\n${'═'.repeat(60)}`);
  console.log(`📊  FINAL SUMMARY`);
  console.log(`${'═'.repeat(60)}`);
  console.log(`  Standard Issues:   ${totalIssues.toLocaleString()}`);
  console.log(`  Security Hotspots: ${totalHotspots.toLocaleString()}`);
  console.log(`  Total:             ${(totalIssues + totalHotspots).toLocaleString()}`);
  console.log(`  Output files:`);
  console.log(`    📄 ${issuesFile}`);
  console.log(`    🔥 ${hotspotsFile}`);

  if (checkpoint.failedBuckets && checkpoint.failedBuckets.length > 0) {
    console.log(`\n  ⚠️  ${checkpoint.failedBuckets.length} bucket(s) failed and were skipped:`);
    checkpoint.failedBuckets.forEach(b => console.log(`     - ${b}`));
    console.log(`  ℹ️  Re-run the script to retry failed buckets automatically (checkpoint will resume).`);
  } else {
    // All done cleanly — remove checkpoint
    clearCheckpoint();
    console.log(`\n  ✅ Export complete. Checkpoint cleared.`);
  }
}

main().catch(err => {
  console.error('\n❌ Fatal error:', err.message);
  console.log('ℹ️  Run the script again to resume from the last checkpoint.');
  process.exit(1);
});
