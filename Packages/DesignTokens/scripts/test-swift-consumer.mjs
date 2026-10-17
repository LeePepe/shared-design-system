// Disposable local-path consumer for the nested Swift package.
import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, cpSync, readFileSync, writeFileSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';

const root = fileURLToPath(new URL('../', import.meta.url));
const dir = mkdtempSync(join(process.env.TOKENS_EVIDENCE_DIR || tmpdir(), 'tokens-swift-'));
const receipt = {packagePath: root, directory: dir, commands: [], documents: {}};
console.log(`Swift evidence: ${dir}`);
function run(command, args, cwd = root, env = process.env) {
  const result = spawnSync(command, args, {cwd, env, encoding: 'utf8', timeout: 180000});
  const log = `${receipt.commands.length + 1}.log`;
  writeFileSync(join(dir, log), `${result.stdout ?? ''}\n${result.stderr ?? ''}`);
  receipt.commands.push({command, args, cwd, exit: result.status, log});
  assert.equal(result.status, 0, `${command} ${args.join(' ')}: ${result.error ?? ''}\n${result.stdout}\n${result.stderr}`);
  return result.stdout;
}
try {
  const consumer = join(dir, 'consumer');
  cpSync(join(root, 'examples/data/swift'), consumer, {recursive: true});
  const env = {...process.env, TOKENS_PACKAGE_PATH: root};
  run('swift', ['package', '--package-path', consumer, 'resolve'], consumer, env);
  const registry = JSON.parse(readFileSync(join(root, 'ai/registry.json')));
  const pkg = JSON.parse(readFileSync(join(root, 'package.json')));
  assert.equal(pkg.version, '0.2.0');
  assert.equal(registry.package.version, pkg.version);
  assert.equal(registry.package.swiftProduct, 'DesignTokens');
  for (const file of Object.values(registry.documents)) {
    const bytes = readFileSync(join(root, file));
    receipt.documents[file] = createHash('sha256').update(bytes).digest('hex');
  }
  run('swift', ['build', '--package-path', consumer], consumer, env);
  receipt.example = run('swift', ['run', '--package-path', consumer, 'TokenExample'], consumer, env).trim();
  assert.match(receipt.example, /PASS Swift data:/);
  receipt.ok = true;
  console.log(`${receipt.example}\nPASS local nested package; verified ${Object.keys(receipt.documents).length} contract documents`);
} finally {
  writeFileSync(join(dir, 'receipt.json'), JSON.stringify(receipt, null, 2) + '\n');
}
