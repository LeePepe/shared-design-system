import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, mkdtempSync, writeFileSync, rmSync, existsSync, readdirSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {resolveStyles, styleCategories} from '../scripts/style-source.mjs';
import {renderStyles} from '../scripts/generate-styles.mjs';
import * as styles from '../dist/styles.js';
const source = () => JSON.parse(readFileSync(new URL('../tokens/styles.json', import.meta.url)));
const colors = () => JSON.parse(readFileSync(new URL('../tokens/colors.json', import.meta.url)));
const token = (s, prefix) => s.tokens.find(t => t.id.startsWith(prefix + '.'));

test('every generated category matches the authoritative resolved data and is immutable', () => {
  const resolved = resolveStyles(source(), colors());
  assert.deepEqual(JSON.parse(readFileSync(new URL('../dist/styles.resolved.json',import.meta.url))), resolved);
  assert.deepEqual(styles.styleTokenIDs, Object.keys(resolved.tokens));
  for (const category of styleCategories) {
    const ids = styles[category + 'IDs'];
    assert.ok(ids.length > 0);
    for (const id of ids) {
      const actual = styles[category](id);
      assert.deepEqual(actual, resolved.tokens[id], id);
      if (typeof actual === 'object') {
        assert.ok(Object.isFrozen(actual));
        assert.throws(() => actual[Object.keys(actual)[0]] = 0, TypeError);
      }
    }
    for (const invalid of ['missing', '__proto__', 'constructor', '', null, 1, {}, styles.styleTokenIDs.find(id => !id.startsWith(category + '.'))]) {
      assert.throws(() => styles[category](invalid), /unknown style token/);
    }
    assert.ok(Object.isFrozen(ids));
    assert.throws(() => ids.push('invalid'), TypeError);
  }
  assert.ok(Object.isFrozen(styles.styleUnits));
  assert.deepEqual(styles.styleUnits, {duration:'second',length:'logical-unit',weight:'css-weight'});
});

const mutations = {
  'unsupported schema': s => s.schemaVersion = '2.0.0',
  'wrong units': s => s.units.duration = 'millisecond',
  'duplicate identity': s => s.tokens.push(s.tokens[0]),
  'unknown category': s => s.tokens[0].id = 'unknown.small',
  'missing category': s => s.tokens = s.tokens.filter(t => !t.id.startsWith('border.')),
  'unknown field typo': s => s.tokens[0].valuee = 2,
  'missing provenance': s => delete s.tokens[0].provenance,
  'negative length': s => token(s,'spacing').value = -1,
  'nonfinite length': s => token(s,'dimension').value = Infinity,
  'NaN length': s => token(s,'dimension').value = NaN,
  'opacity overflow': s => token(s,'opacity').value = 1.01,
  'wrong scalar type': s => token(s,'duration').value = '300ms',
  'typography below zero': s => token(s,'typography').value.size = 0,
  'invalid weight': s => token(s,'typography').value.weight = 550,
  'invalid relative text role': s => token(s,'typography').value.relativeTo = 'Body',
  'invalid line height': s => token(s,'typography').value.lineHeight = 1,
  'nonfinite curve': s => token(s,'curve').value.y1 = Infinity,
  'curve x outside range': s => token(s,'curve').value.x2 = -0.1,
  'spring no response': s => token(s,'spring').value.response = 0,
  'spring invalid damping': s => token(s,'spring').value.dampingFraction = 1.1,
  'shadow invalid color': s => token(s,'shadow').value.colorToken = 'product.missing',
  'shadow negative radius': s => token(s,'shadow').value.radius = -1,
  'shadow literal color': s => token(s,'shadow').value.colorToken = '#000000'
};
for (const [name, mutate] of Object.entries(mutations)) test('style validation rejects ' + name, () => {
  const input = source(); mutate(input);
  assert.throws(() => resolveStyles(input, colors()), Error);
});
test('style generation is deterministic across token/property ordering', () => {
  const first = renderStyles(source(), colors());
  const input = source(); input.tokens.reverse();
  for (const item of input.tokens) if (typeof item.value === 'object') item.value = Object.fromEntries(Object.entries(item.value).reverse());
  assert.deepEqual(renderStyles(input, colors()), first);
  assert.deepEqual(Object.keys(first).sort(), ['Sources/DesignTokens/GeneratedStyles.swift','dist/styles.js','dist/styles.d.ts','dist/styles.resolved.json','dist/styles.css'].sort());
  for (const [relative, expected] of Object.entries(first)) assert.equal(readFileSync(new URL('../'+relative,import.meta.url),'utf8'), expected, relative);
});

test('Strata v0.2 geometry and web typography are emitted as CSS variables', () => {
  const css = readFileSync(new URL('../dist/styles.css', import.meta.url), 'utf8');
  for (const [id, value] of Object.entries({
    'spacing.xs': '4px', 'spacing.xxl': '32px', 'radius.control': '16px',
    'radius.card': '24px', 'radius.container': '32px', 'dimension.control.strata': '40px',
    'typography.strata.body-size': '14px', 'typography.strata.title-size': '32px',
    'typography.strata.section-size': '18px', 'typography.strata.meta-size': '12px',
    'duration.fast': '0.16s', 'stagger.tight': '0.016666666666666666s',
    'opacity.disabled': '0.45', 'curve.standard-x1': '0.2',
    'spring.standard-response': '0.4s', 'shadow.small-opacity': '0.08'
  })) assert.match(css, new RegExp(`--lp-${id.replaceAll('.', '-')}: ${value};`));
});
test('real generator detects each style artifact drift without repairing it', () => {
  const dir = mkdtempSync(join(tmpdir(),'styles-drift-'));
  const run = (...args) => spawnSync(process.execPath,['scripts/generate.mjs','--out',dir,...args],{encoding:'utf8'});
  try {
    assert.equal(run().status,0);
    assert.equal(run('--check').status,0);
    for (const [relative, expected] of Object.entries(renderStyles(source(), colors()))) {
      const path=join(dir,relative);
      writeFileSync(path,'intentional drift');
      const result=run('--check');
      assert.equal(result.status,1);
      assert.match(result.stderr,/generated drift/);
      assert.equal(readFileSync(path,'utf8'),'intentional drift');
      writeFileSync(path,expected);
    }
    assert.equal(run('--check').status,0);
  } finally { rmSync(dir,{recursive:true,force:true}); }
});
test('invalid style source fails before any generated output is written', () => {
  const dir = mkdtempSync(join(tmpdir(),'styles-invalid-'));
  try {
    const input=source(); token(input,'shadow').value.colorToken='product.missing';
    const file=join(dir,'invalid.json'); writeFileSync(file,JSON.stringify(input));
    const result=spawnSync(process.execPath,['scripts/generate.mjs','--styles-source',file,'--out',dir],{encoding:'utf8'});
    assert.equal(result.status,1);
    assert.match(result.stderr,/unknown shadow color/);
    assert.equal(existsSync(join(dir,'dist')),false);
  } finally { rmSync(dir,{recursive:true,force:true}); }
});

test('all shipped Swift sources stay platform-neutral data', () => {
  const directory = new URL('../Sources/DesignTokens/', import.meta.url);
  for (const file of readdirSync(directory).filter(name => name.endsWith('.swift'))) {
    assert.doesNotMatch(readFileSync(new URL(file,directory),'utf8'), /^\s*import\s+(?:SwiftUI|UIKit|AppKit)\b/m, file);
  }
});
