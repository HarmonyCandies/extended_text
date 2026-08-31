/**
 * Host tests for the ColorUtils leftover: numberTo2DColor / decimalTo2DColor
 * used (hex & 0xff000000) !== 0 so a zero high byte looked like 24-bit RGB.
 *
 * Default is still 24-bit RGB when value <= 0xffffff (documented 0xffffff).
 * In JS/ArkTS 0x00FF0000 === 0xFF0000, so alpha=0 needs explicit bitLength=32.
 *
 * ArkGraphics2D cannot run here. numberTo2DColor is extracted in packedColor.ts
 * (no ArkUI imports) so these tests run on the host.
 *
 * Run: node --experimental-strip-types --test extended_text/src/test/host/color_utils.test.ts
 */
import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  decimalTo2DColor,
  numberTo2DColor,
  packedResourceColorTo2DColor,
} from '../../main/ets/packedColor.ts';

const here = path.dirname(fileURLToPath(import.meta.url));
const utilsPath = path.resolve(here, '../../main/ets/Utils.ets');
const packedPath = path.resolve(here, '../../main/ets/packedColor.ts');

describe('ColorUtils leftover: RGB default + explicit ARGB bitLength', () => {
  it('numberTo2DColor(0xffffff).alpha === 255 (documented RGB)', () => {
    const color = numberTo2DColor(0xffffff);
    assert.equal(color.alpha, 255);
    assert.equal(color.red, 255);
    assert.equal(color.green, 255);
    assert.equal(color.blue, 255);
  });

  it('numberTo2DColor(0xffff0000).alpha === 255', () => {
    const color = numberTo2DColor(0xffff0000);
    assert.equal(color.alpha, 255);
    assert.equal(color.red, 255);
    assert.equal(color.green, 0);
    assert.equal(color.blue, 0);
  });

  it('numberTo2DColor(0x80FF0000).alpha === 128', () => {
    const color = numberTo2DColor(0x80FF0000);
    assert.equal(color.alpha, 128);
    assert.equal(color.red, 255);
    assert.equal(color.green, 0);
    assert.equal(color.blue, 0);
  });

  it('numberTo2DColor(0x00FF0000, 32).alpha === 0 (explicit ARGB)', () => {
    const color = numberTo2DColor(0x00FF0000, 32);
    assert.equal(color.alpha, 0);
    assert.equal(color.red, 255);
    assert.equal(color.green, 0);
    assert.equal(color.blue, 0);
  });

  it('decimalTo2DColor and packedResourceColorTo2DColor share the 24-default', () => {
    assert.equal(decimalTo2DColor(0xffffff).alpha, 255);
    assert.equal(decimalTo2DColor(0xffff0000).alpha, 255);
    assert.equal(decimalTo2DColor(0x80FF0000).alpha, 128);
    assert.equal(decimalTo2DColor(0x00FF0000, 32).alpha, 0);
    assert.equal(packedResourceColorTo2DColor(0xffffff).alpha, 255);
    assert.equal(packedResourceColorTo2DColor(0x80FF0000).alpha, 128);
    assert.equal(packedResourceColorTo2DColor(0x00FF0000, 32).alpha, 0);
  });

  it('source: leftover hasAlpha / !== 0 / > 0xffffff polarity gone; unsigned >>> used', () => {
    const utils = fs.readFileSync(utilsPath, 'utf8');
    const packed = fs.readFileSync(packedPath, 'utf8');

    assert.doesNotMatch(utils, /hasAlpha/, 'leftover hasAlpha must be gone from Utils.ets');
    assert.doesNotMatch(utils, /0xff000000/, 'leftover 0xff000000 mask must be gone from Utils.ets');
    assert.doesNotMatch(utils, /!== 0/, 'leftover !== 0 polarity must be gone from Utils.ets');
    assert.doesNotMatch(utils, /> 0xffffff/, 'leftover > 0xffffff polarity must be gone from Utils.ets');

    assert.match(packed, />>>/, 'packedColor must use unsigned >>> shifts');
    assert.match(packed, />>> 24/, 'alpha must be taken with unsigned >>> 24');
  });

  it('source: ColorUtils.numberTo2DColor / decimalTo2DColor wire to packed helpers', () => {
    const src = fs.readFileSync(utilsPath, 'utf8');
    const numberBody = extractStaticMethodBody(src, 'numberTo2DColor');
    const decimalBody = extractStaticMethodBody(src, 'decimalTo2DColor');
    const resourceBody = extractStaticMethodBody(src, 'resourceTo2DColor');

    assert.match(numberBody, /return numberTo2DColor\(\s*hex,\s*bitLength\s*\)/);
    assert.match(decimalBody, /return decimalTo2DColor\(\s*decimal,\s*bitLength\s*\)/);
    assert.match(resourceBody, /packedResourceColorTo2DColor/);
  });
});

function extractStaticMethodBody(source: string, methodName: string): string {
  const re = new RegExp(
    `static ${methodName}\\([^)]*\\):[^{]+\\{([\\s\\S]*?)\\n  \\}`,
  );
  const match = source.match(re);
  assert.ok(match, `Could not parse ColorUtils.${methodName} from Utils.ets`);
  return match[1];
}
