const fs = require('fs');
const path = require('path');

const CHECKPOINT_FILE = path.resolve('sonar-export-checkpoint.json');

function loadCheckpoint() {
  if (fs.existsSync(CHECKPOINT_FILE)) {
    try {
      const data = JSON.parse(fs.readFileSync(CHECKPOINT_FILE, 'utf8'));
      console.log(`♻️  Checkpoint found (started: ${data.startedAt}). Resuming...`);
      console.log(`   ✅ Already completed: ${data.completedBuckets.length} buckets`);
      if (data.failedBuckets && data.failedBuckets.length > 0) {
        console.log(`   ⚠️  Previously failed: ${data.failedBuckets.length} buckets (will retry)`);
      }
      return data;
    } catch (e) {
      console.warn('⚠️  Checkpoint file is corrupt. Starting fresh.');
    }
  }
  return null;
}

function createCheckpoint(projectKey) {
  const checkpoint = {
    projectKey,
    startedAt: new Date().toISOString(),
    completedBuckets: [],
    failedBuckets: [],
    counts: { issues: 0, hotspots: 0 }
  };
  saveCheckpoint(checkpoint);
  return checkpoint;
}

function saveCheckpoint(checkpoint) {
  fs.writeFileSync(CHECKPOINT_FILE, JSON.stringify(checkpoint, null, 2));
}

function markBucketComplete(checkpoint, bucketId, count) {
  if (!checkpoint.completedBuckets.includes(bucketId)) {
    checkpoint.completedBuckets.push(bucketId);
  }
  // Remove from failed if it was retried successfully
  checkpoint.failedBuckets = checkpoint.failedBuckets.filter(b => b !== bucketId);
  saveCheckpoint(checkpoint);
}

function markBucketFailed(checkpoint, bucketId, errorMsg) {
  if (!checkpoint.failedBuckets.includes(bucketId)) {
    checkpoint.failedBuckets.push(bucketId);
  }
  console.warn(`  💾 Marked bucket as FAILED in checkpoint: ${bucketId} | Reason: ${errorMsg}`);
  saveCheckpoint(checkpoint);
}

function isBucketComplete(checkpoint, bucketId) {
  return checkpoint && checkpoint.completedBuckets.includes(bucketId);
}

function clearCheckpoint() {
  if (fs.existsSync(CHECKPOINT_FILE)) {
    fs.unlinkSync(CHECKPOINT_FILE);
    console.log('🗑️  Checkpoint file cleared.');
  }
}

function buildBucketId(type, filters) {
  // Build a stable, unique string ID from the fetch type and its filters
  const filterStr = Object.entries(filters)
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${k}=${v}`)
    .join('::');
  return `${type}::${filterStr || 'all'}`;
}

module.exports = {
  loadCheckpoint,
  createCheckpoint,
  saveCheckpoint,
  markBucketComplete,
  markBucketFailed,
  isBucketComplete,
  clearCheckpoint,
  buildBucketId,
};
