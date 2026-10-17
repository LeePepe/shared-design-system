import assert from 'node:assert/strict';
import {spawnSync} from 'node:child_process';
import {mkdtempSync, mkdirSync, writeFileSync} from 'node:fs';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const repositoryRoot = fileURLToPath(new URL('../../../', import.meta.url));
const evidenceRoot = process.env.TOKENS_EVIDENCE_DIR || join(repositoryRoot, '.build', 'evidence');
mkdirSync(evidenceRoot, {recursive: true});
const dir = mkdtempSync(join(evidenceRoot, 'tokens-swift-local-'));
const receipt = {packagePath: root, directory: dir, commands: []};
console.log(`Local Swift evidence: ${dir}`);

function run(command, args, cwd = dir) {
  const result = spawnSync(command, args, {cwd, encoding: 'utf8', timeout: 180000});
  const log = `${receipt.commands.length + 1}.log`;
  writeFileSync(join(dir, log), `${result.stdout ?? ''}\n${result.stderr ?? ''}`);
  receipt.commands.push({command, args, cwd, exit: result.status, log});
  assert.equal(result.status, 0, `${command} ${args.join(' ')}\n${result.stdout}\n${result.stderr}`);
  return result.stdout;
}

try {
  mkdirSync(join(dir, 'Sources', 'Consumer'), {recursive: true});
  writeFileSync(join(dir, 'Package.swift'), `// swift-tools-version: 6.0
import PackageDescription
let package = Package(
  name: "NestedDesignTokensConsumer",
  platforms: [.macOS(.v12)],
  dependencies: [.package(path: ${JSON.stringify(root)})],
  targets: [.executableTarget(name: "Consumer", dependencies: [
    .product(name: "DesignTokens", package: "DesignTokens")
  ])]
)
`);
  writeFileSync(join(dir, 'Sources', 'Consumer', 'main.swift'), `import DesignTokens
let color = try DesignTokens.color("product.text.primary", theme: .light)
let spacing = try StyleTokens.spacing("spacing.lg")
precondition(color.a == 1)
precondition(spacing == 16)
print("PASS nested local-path DesignTokens consumer")
`);
  run('swift', ['package', 'resolve']);
  run('swift', ['build']);
  receipt.output = run('swift', ['run', 'Consumer']).trim();
  assert.equal(receipt.output, 'PASS nested local-path DesignTokens consumer');
  receipt.ok = true;
  console.log(receipt.output);
} finally {
  writeFileSync(join(dir, 'receipt.json'), JSON.stringify(receipt, null, 2) + '\n');
}
