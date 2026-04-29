const fs = require('fs');

// ─── CSV helpers ──────────────────────────────────────────────────────────────

function escapeCsvValue(value) {
  if (value === null || value === undefined) return '';
  const str = String(value);
  if (str.includes(',') || str.includes('"') || str.includes('\n') || str.includes('\r')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
}

const PREFERRED_HEADERS = [
  'key', 'project', 'type', 'severity', 'status', 'resolution',
  'message', 'component', 'creationDate', 'updateDate', 'rule', 'securityCategory'
];

// ─── Streaming CSV writer ─────────────────────────────────────────────────────

/**
 * Creates a streaming CSV writer. Returns an object with:
 *   .write(issue)  — appends one row immediately to disk
 *   .end()         — flushes and closes the stream
 *   .count         — number of rows written so far
 */
function createCsvStream(filename, extraHeaders = []) {
  // Build the ordered header list: preferred first, then extras
  const headers = [...new Set([...PREFERRED_HEADERS, ...extraHeaders])];
  let headerWritten = false;
  let count = 0;

  const fileStream = fs.createWriteStream(filename, { flags: 'a' }); // append mode for resume safety

  // Write the header row once per fresh file (check if file is empty)
  const isNew = !fs.existsSync(filename) || fs.statSync(filename).size === 0;
  if (isNew) {
    fileStream.write(headers.map(escapeCsvValue).join(',') + '\n');
  }

  function write(record) {
    // Discover any new keys in this record and add them to headers (for first-run header writes only)
    const row = headers.map(h => {
      let val = record[h];
      if (typeof val === 'object' && val !== null) val = JSON.stringify(val);
      return escapeCsvValue(val);
    });
    fileStream.write(row.join(',') + '\n');
    count++;
  }

  function end() {
    return new Promise((resolve, reject) => {
      fileStream.end();
      fileStream.on('finish', () => {
        console.log(`✅ Stream closed. ${count} rows written to ${filename}`);
        resolve(count);
      });
      fileStream.on('error', reject);
    });
  }

  return { write, end, get count() { return count; } };
}

// ─── Legacy helpers (kept for compatibility) ──────────────────────────────────

function exportToJson(issues, filename = 'sonar-report.json') {
  fs.writeFileSync(filename, JSON.stringify(issues, null, 2));
  console.log(`✅ Exported ${issues.length} records to ${filename}`);
}

module.exports = {
  createCsvStream,
  exportToJson,
};
