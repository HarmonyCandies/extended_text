/**
 * leftover: packed RGB/ARGB → {alpha, red, green, blue}.
 * Host-testable: no ArkGraphics2D / ArkUI imports.
 *
 * Default: 24-bit RGB when value <= 0xffffff (alpha 255), matching
 * resourceColorTo2DColor examples 0xffffff / 0xffff0000.
 * Values > 0xffffff are 32-bit ARGB (high byte via >>>, including alpha=0
 * when that byte is present in the numeric value).
 * Pass bitLength=32 to force ARGB when the JS number is <= 0xffffff
 * (0x00FF0000 === 0xFF0000; bare 0x00FF0000 cannot be distinguished).
 */

export interface ColorChannels {
  alpha: number;
  red: number;
  green: number;
  blue: number;
}

export type ColorBitLength = 24 | 32;

/**
 * Decode a packed color number.
 * @param hex packed RGB (24-bit) or ARGB (32-bit)
 * @param bitLength 32 → force ARGB (alpha from high byte, including 0);
 *                  24 or omitted → RGB (alpha 255) when hex <= 0xffffff.
 */
export function numberTo2DColor(hex: number, bitLength?: ColorBitLength): ColorChannels {
  const unsigned: number = hex >>> 0;
  const treatAsArgb: boolean = bitLength === 32 || unsigned > 0xffffff;
  return {
    alpha: treatAsArgb ? (unsigned >>> 24) & 0xff : 255,
    red: (unsigned >>> 16) & 0xff,
    green: (unsigned >>> 8) & 0xff,
    blue: unsigned & 0xff,
  };
}

/** Same default as numberTo2DColor (getColorSync / decimal path). */
export function decimalTo2DColor(decimal: number, bitLength?: ColorBitLength): ColorChannels {
  return numberTo2DColor(decimal, bitLength);
}

/** resourceTo2DColor / getColorSync: same 24-bit RGB default. */
export function packedResourceColorTo2DColor(hex: number, bitLength?: ColorBitLength): ColorChannels {
  return numberTo2DColor(hex, bitLength);
}
