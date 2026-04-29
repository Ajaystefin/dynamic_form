const fs = require('fs');
const XLSX = require('xlsx');

function exportToJson(issues, filename = 'sonar-report.json') {
  fs.writeFileSync(filename, JSON.stringify(issues, null, 2));
  console.log(`✅ Successfully exported to ${filename}`);
}

function exportToCsv(issues, filename = 'sonar-report.xlsx') {
  const grouped = issues.reduce((acc, issue) => {
    const key = issue.project ?? "NoProject";
    acc[key] = acc[key] || [];
    acc[key].push(issue);
    return acc;
  }, {});

  const wb = XLSX.utils.book_new();
  const sheetNames = new Set();

  Object.entries(grouped).forEach(([projectKey, data]) => {
    const sheet = XLSX.utils.json_to_sheet(data);
    let name = projectKey.replace(/[:\\\\/?*[\\]]/g, "").slice(0, 31);
    const base = name;
    let count = 1;
    while (sheetNames.has(name)) {
      const suffix = `_${count++}`;
      name = `${base.slice(0, 31 - suffix.length)}${suffix}`;
    }
    sheetNames.add(name);
    XLSX.utils.book_append_sheet(wb, sheet, name);
  });

  XLSX.writeFile(wb, filename);
  console.log(`✅ Successfully exported to ${filename}`);
}

module.exports = {
  exportToJson,
  exportToCsv
};
