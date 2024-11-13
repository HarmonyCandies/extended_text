import { text, common2D } from "@kit.ArkGraphics2D"
import { BusinessError } from "@kit.BasicServicesKit";

class UnsupportedOperationException implements BusinessError {
  code: number;
  data?: void | undefined;
  name: string;
  message: string;
  stack?: string | undefined;

  constructor(code: number, message: string, stack?: string) {
    this.code = code;
    this.name = 'UnsupportedOperationException';
    this.message = message;
    this.stack = stack;
  }
}

// textStyle?: text.TextStyle
export class TextStyleUtils {
  static copyWith(textStyle: text.TextStyle,
  ): text.TextStyle {
    return {}
  }
}

class MyTextStyle implements text.TextStyle {
}

export class ColorUtils {
  static resourceColorTo2DColor(resourceColor: ResourceColor, context?: Context,
  ): common2D.Color {

    let type = typeof resourceColor;
    // HEX格式颜色，支持rgb或者argb。示例：0xffffff，0xffff0000。
    if (type === 'number') {
      //  'number';
      let hex = resourceColor as number;
      return ColorUtils.numberTo2DColor(hex);
    }
    // rgb或者argb格式颜色。示例：'#ffffff', '#ff000000', 'rgb(255, 100, 255)', 'rgba(255, 100, 255, 0.5)'。
    // Color 会转换成 string
    else if (type === 'string') {
      let stringColor = resourceColor as string;
      return ColorUtils.stringTo2DColor(stringColor);
    } else {
      let resource = resourceColor as Resource;
      if (context == undefined) {
        throw new UnsupportedOperationException(1, '该颜色为 Resource，需要传 context 参数');
      }
      return ColorUtils.resourceTo2DColor(resource, context);
    }

    throw new UnsupportedOperationException(0, '无法解析颜色的格式');
  }

  static stringTo2DColor(color: string): common2D.Color {
    if (color.startsWith("#")) {
      // HEX 格式
      const hex = color.slice(1);
      if (hex.length === 6) { // RGB 格式
        const red = parseInt(hex.slice(0, 2), 16);
        const green = parseInt(hex.slice(2, 4), 16);
        const blue = parseInt(hex.slice(4, 6), 16);
        return {
          alpha: 255,
          red,
          green,
          blue
        };
      } else if (hex.length === 8) { // ARGB 格式
        const alpha = parseInt(hex.slice(0, 2), 16);
        const red = parseInt(hex.slice(2, 4), 16);
        const green = parseInt(hex.slice(4, 6), 16);
        const blue = parseInt(hex.slice(6, 8), 16);
        return {
          alpha,
          red,
          green,
          blue
        };
      }
    } else if (color.startsWith("rgb")) {
      // RGB 或 RGBA 格式
      const rgbaMatch = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+),?\s*([\d.]*)\)/);
      if (rgbaMatch) {
        const red = parseInt(rgbaMatch[1], 10);
        const green = parseInt(rgbaMatch[2], 10);
        const blue = parseInt(rgbaMatch[3], 10);
        const alpha = rgbaMatch[4] ? Math.round(parseFloat(rgbaMatch[4]) * 255) : 255;
        return {
          alpha,
          red,
          green,
          blue
        };
      }
    }

    throw new UnsupportedOperationException(0, '无法解析颜色的格式');
  }

  static numberTo2DColor(hex: number): common2D.Color {
    const hasAlpha = (hex & 0xff000000) !== 0;
    return {
      alpha: hasAlpha ? (hex >> 24) & 0xff : 255, // 如果没有透明位，默认为 255（不透明）
      red: (hex >> 16) & 0xff,
      green: (hex >> 8) & 0xff,
      blue: hex & 0xff,
    };
  }

  static resourceTo2DColor(resource: Resource, context: Context): common2D.Color {
    return ColorUtils.decimalTo2DColor(context.resourceManager.getColorSync(resource.id))
  }

  static decimalTo2DColor(decimal: number): common2D.Color {
    const hasAlpha = decimal > 0xffffff; // 判断是否为 32 位（ARGB）
    return {
      alpha: hasAlpha ? (decimal >> 24) & 0xff : 255, // 如果没有 alpha，默认设为 255（不透明）
      red: (decimal >> 16) & 0xff,
      green: (decimal >> 8) & 0xff,
      blue: decimal & 0xff,
    };
  }
}

export class RectUtils {
  static getIntersection(rect1: common2D.Rect, rect2: common2D.Rect): common2D.Rect | null {
    // 计算相交矩形的边界
    const left = Math.max(rect1.left, rect2.left);
    const top = Math.max(rect1.top, rect2.top);
    const right = Math.min(rect1.right, rect2.right);
    const bottom = Math.min(rect1.bottom, rect2.bottom);

    // 检查是否有交集（有效的矩形区域）
    if (left < right && top < bottom) {
      return {
        left,
        top,
        right,
        bottom
      };
    }

    // 如果没有交集，返回 null
    return null;
  }

  static hasIntersection(rect1: common2D.Rect, rect2: common2D.Rect): boolean {
    return RectUtils.getIntersection(rect1, rect2) != null;
  }
}

export class Accumulator {
  private _value: number;

  // Accumulator may be initialized with a specified value; otherwise, it will initialize to zero.
  constructor(value: number = 0) {
    this._value = value;
  }

  // The integer stored in this Accumulator.
  get value(): number {
    return this._value;
  }

  // Increases the value by the addend.
  increment(addend: number): void {
    if (addend < 0) {
      throw new Error("Addend must be non-negative");
    }
    this._value += addend;
  }
}

export class StringBuffer {
  private _value: string;

  // Accumulator may be initialized with a specified value; otherwise, it will initialize to zero.
  constructor(value: string = '') {
    this._value = value;
  }

  // The integer stored in this Accumulator.
  get value(): string {
    return this._value;
  }

  // Increases the value by the addend.
  write(addend: string): void {
    this._value += addend;
  }
}


export function safeSubstring(text: string, start: number, end: number): string {
  const characters = Array.from(
    text.matchAll(/[\uD800-\uDBFF][\uDC00-\uDFFF]|[\s\S]/g),
    (match) => match[0]
  );

  const safeStart = Math.min(start, characters.length);
  const safeEnd = Math.min(end, characters.length);

  return characters.slice(safeStart, safeEnd).join("");
}

export function safeToStringFromRunes(runes: number[]): string {
  const safeRunes: number[] = [];

  let i = 0;
  while (i < runes.length) {
    const currentRune = runes[i];

    // 如果当前字符是高代理项（D800..DBFF）
    if (currentRune >= 0xD800 && currentRune <= 0xDBFF) {
      // 检查下一个字符是否是低代理项（DC00..DFFF）
      if (i + 1 < runes.length && runes[i + 1] >= 0xDC00 && runes[i + 1] <= 0xDFFF) {
        // 如果是完整的代理对，添加到结果数组
        safeRunes.push(currentRune, runes[i + 1]);
        i += 2; // 跳过这两个字符
      } else {
        // 如果只有高代理项，丢弃这个字符
        i++;
      }
    } else {
      // 如果当前字符不是代理对，直接添加到结果数组
      safeRunes.push(currentRune);
      i++;
    }
  }

  // 将有效的 Unicode 码点转换为字符串
  return String.fromCodePoint(...safeRunes);
}

