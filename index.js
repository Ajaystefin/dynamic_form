require('dotenv').config();
const { fetchProjects, fetchAllProjectIssues } = require('./fetcher');
const { exportToJson, exportToCsv } = require('./exporter');

const SONAR_TOKEN = process.env.SONAR_TOKEN;
const SONAR_ORG_KEY = process.env.SONAR_ORG_KEY;
const EXPORT_FORMAT = process.env.EXPORT_FORMAT || 'json';
const PROJECT_KEYS = process.env.PROJECT_KEYS ? process.env.PROJECT_KEYS.split(',').map(s => s.trim()) : [];

async function main() {
  if (!SONAR_TOKEN || !SONAR_ORG_KEY) {
    console.error("❌ Missing SONAR_TOKEN or SONAR_ORG_KEY in .env file");
    process.exit(1);
  }

  let keysToExport = PROJECT_KEYS;

  if (keysToExport.length === 0) {
    console.log(`🔍 Fetching projects for organization: ${SONAR_ORG_KEY}`);
    const projects = await fetchProjects(SONAR_ORG_KEY, SONAR_TOKEN);
    if (projects.length === 0) {
      console.log("⚠️ No projects found or failed to fetch projects.");
      return;
    }
    keysToExport = projects.map(p => p.key);
    console.log(`✅ Found ${keysToExport.length} projects.`);
  } else {
    console.log(`🎯 Using provided project keys: ${keysToExport.join(', ')}`);
  }

  const allIssues = [];

  for (const projectKey of keysToExport) {
    console.log(`\n🚀 Fetching issues for project: ${projectKey}`);
    const projectIssues = await fetchAllProjectIssues(projectKey, SONAR_TOKEN);
    console.log(`✅ Fetched ${projectIssues.length} issues for ${projectKey}`);
    allIssues.push(...projectIssues);
  }

  console.log(`\n📊 Total issues fetched across all projects: ${allIssues.length}`);

  if (allIssues.length > 0) {
    const timestamp = new Date().toISOString().split("T")[0];
    if (EXPORT_FORMAT === 'csv' || EXPORT_FORMAT === 'xlsx') {
      exportToCsv(allIssues, `sonar-report-${timestamp}.xlsx`);
    } else {
      exportToJson(allIssues, `sonar-report-${timestamp}.json`);
    }
  } else {
    console.log("🤷‍♂️ No issues found to export.");
  }
}

main().catch(console.error);
