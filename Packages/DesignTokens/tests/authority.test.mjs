import test from 'node:test';
import assert from 'node:assert/strict';
import {checkAuthority, trackedPaths} from '../scripts/check-authority.mjs';

test('only the canonical color and style sources are tracked authorities', () => {
  assert.deepEqual(checkAuthority(trackedPaths()), [
    'Packages/DesignTokens/tokens/colors.json',
    'Packages/DesignTokens/tokens/styles.json',
  ]);
});

for (const duplicate of [
  'tokens/colors.json',
  'tokens/styles.json',
  'Sources/tokens/colors.json',
  'Tests/Fixtures/tokens/styles.json',
  'Packages/Other/tokens/colors.json',
]) {
  test(`duplicate authority is rejected: ${duplicate}`, () => {
    assert.throws(
      () => checkAuthority([...trackedPaths(), duplicate]),
      /alternate semantic data authority/
    );
  });
}
