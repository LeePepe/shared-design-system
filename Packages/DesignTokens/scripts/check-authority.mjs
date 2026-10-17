import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const authorities = [
  'Packages/DesignTokens/tokens/colors.json',
  'Packages/DesignTokens/tokens/styles.json',
];

export function checkAuthority(paths) {
  const candidates = paths.filter(path =>
    /(^|\/)tokens\/(colors|styles)\.json$/.test(path)
  ).sort();
  assert.deepEqual(candidates, authorities,
    `alternate semantic data authority: expected ${authorities.join(', ')}, found ${candidates.join(', ')}`);
  return candidates;
}

export function trackedPaths() {
  const top = spawnSync('git', ['rev-parse', '--show-toplevel'], {cwd: root, encoding: 'utf8'});
  assert.equal(top.status, 0, top.stderr);
  const result = spawnSync('git', ['ls-files'], {cwd: top.stdout.trim(), encoding: 'utf8'});
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim().split('\n').filter(Boolean);
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const checked = checkAuthority(trackedPaths());
  console.log(`Checked ${checked.length} editable semantic data authorities`);
}
