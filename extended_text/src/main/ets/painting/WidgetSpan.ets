import { PlaceholderSpan, PlaceholderSpanOptions } from "./PlaceholderSpan";
import { text } from "@kit.ArkGraphics2D"
import { WidgetBuilder } from "../builder/WidgetBuilder";
import { ImageModifier } from "@kit.ArkUI";
import { InlineSpanVisitor } from "../Declare";
import { Accumulator, InlineSpan } from "../../../../Index";
import { ExtendedParagraphBuilder } from "../builder/ParagraphBuilder";

export interface WidgetSpanOptions extends PlaceholderSpanOptions {
  builder: WrappedBuilder<[ESObject]>;
  builderArgs: ESObject;
}

export class WidgetSpan extends PlaceholderSpan implements WidgetBuilder {
  constructor(options: WidgetSpanOptions) {
    super(options)
    this.actualText = this.actualText ?? PlaceholderSpan.placeholder;
    this.builder = options.builder;
    this.builderArgs = options.builderArgs;
    this.range = {
      start: options.start,
      end: options.start != undefined ? options.start + this.actualText!.length : undefined
    };
  }

  builder: WrappedBuilder<[ESObject]>;
  builderArgs: ESObject;

  build(builder: ExtendedParagraphBuilder, dimensions: Array<MeasureResult>): void {
    if (builder.placeholderCount >= dimensions.length) {
      return;
    }
    let hasStyle = this.style != undefined;
    if (hasStyle) {
      builder.pushStyle(this.style!);
    }
    let currentDimensions = dimensions[builder.placeholderCount];
    builder.addPlaceholder({
      width: this.hide ? 0 : currentDimensions.width,
      height: this.hide ? 0 : currentDimensions.height,
      align: this.align,
      baseline: this.baseline,
      baselineOffset: this.baselineOffset,
    });

    builder.placeholderCount = builder.placeholderCount + 1;
    if (hasStyle) {
      builder.popStyle();
    }
  }

  visitChildren(visitor: InlineSpanVisitor): boolean {
    return visitor(this);
  }

  visitDirectChildren(visitor: InlineSpanVisitor): boolean {
    return true;
  }

  static extractFromInlineSpan(inlineSpan: InlineSpan): Array<WidgetSpan> {
    let list = new Array<WidgetSpan>();
    inlineSpan.visitChildren((child) => {
      if (child instanceof WidgetSpan) {
        list.push(child);
      }
      return true;
    })
    return list;
  }

  joinChar(offset: Accumulator, char?: string): InlineSpan {
    offset.increment(this.actualText?.length ?? 1);
    return new WidgetSpan({
      builder: this.builder,
      builderArgs: this.builderArgs,
      hide: this.hide,
      align: this.align,
      baseline: this.baseline,
      baselineOffset: this.baselineOffset,
      start: this.start,
      style: this.style,
      actualText: this.actualText,
    });
  }

  toActualText(): string {
    return this.actualText ?? PlaceholderSpan.placeholder;
  }
}