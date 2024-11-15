import { InlineSpan, InlineSpanOptions } from "./InlineSpan";
import { text } from "@kit.ArkGraphics2D"
import { StringBuffer } from "../Utils";

export interface PlaceholderSpanOptions extends InlineSpanOptions {
  /**
   * Alignment mode of placeholder.
   * @type { PlaceholderAlignment }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  align?: text.PlaceholderAlignment;

  /**
   * Baseline of placeholder.
   * @type { TextBaseline }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baseline?: text.TextBaseline;

  /**
   * Baseline offset of placeholder.
   * @type { number }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baselineOffset?: number;
}

export abstract class PlaceholderSpan extends InlineSpan {
  constructor(options: PlaceholderSpanOptions) {
    super(options);
    this.align = options.align ?? text.PlaceholderAlignment.CENTER_OF_ROW_BOX;
    this.baseline = options.baseline ?? text.TextBaseline.ALPHABETIC;
    this.baselineOffset = options.baselineOffset ?? 0;
  }

  /// The unicode character to represent a placeholder.
  static placeholder: string = '\uFFFC';
  /**
   * Alignment mode of placeholder.
   * @type { PlaceholderAlignment }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  align: text.PlaceholderAlignment;
  /**
   * Baseline of placeholder.
   * @type { TextBaseline }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baseline: text.TextBaseline;
  /**
   * Baseline offset of placeholder.
   * @type { number }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baselineOffset: number;

  computeToPlainText(buffer: StringBuffer): void {
    buffer.write(PlaceholderSpan.placeholder)
  }

  getInlineOffset(): number {
    return 1;
  }
}