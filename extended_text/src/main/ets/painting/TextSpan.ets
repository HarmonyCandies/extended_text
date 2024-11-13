import { InlineSpan, InlineSpanOptions } from "./InlineSpan";
import { text } from "@kit.ArkGraphics2D"
import { InlineSpanVisitor } from "../Declare";
import { ExtendedParagraphBuilder } from "../ParagraphBuilder";
import { StringBuffer } from "../Utils";

export interface TextSpanOptions extends InlineSpanOptions {

  text?: string;
  children?: Array<InlineSpan>;
}

export class TextSpan extends InlineSpan {
  constructor(options: TextSpanOptions) {
    super(options);
    this.text = options.text;
    this.children = options.children;
    this.actualText = this.actualText ?? this.text;
    this.range = {
      start: options.start,
      end: options.start != undefined ? options.start + (options.actualText ?? this.text ?? '').length : undefined
    };

  }

  text?: string;
  children?: Array<InlineSpan>;

  build(builder: ExtendedParagraphBuilder, dimensions: Array<MeasureResult>): void {
    let hasStyle = this.style != undefined;
    if (hasStyle) {
      builder.pushStyle(this.style!);
    }

    if (this.text != undefined) {
      builder.addText(this.text);
    }

    if (this.children != undefined) {
      for (let index = 0; index < this.children!.length; index++) {
        const child = this.children[index];
        child.build(builder, dimensions);
      }
    }

    if (hasStyle) {
      builder.popStyle();
    }
  }

  visitChildren(visitor: InlineSpanVisitor): boolean {
    if (this.text != undefined && !visitor(this)) {
      return false;
    }
    let children = this.children;
    if (children != undefined) {
      for (let index = 0; index < children.length; index++) {
        const child = children[index];
        if (!child.visitChildren(visitor)) {
          return false;
        }
      }
    }
    return true;
  }

  visitDirectChildren(visitor: InlineSpanVisitor): boolean {
    let children = this.children;
    if (children != undefined) {
      for (let index = 0; index < children.length; index++) {
        const child = children[index];
        if (!child.visitChildren(visitor)) {
          return false;
        }
      }
    }
    return true;
  }

  computeToPlainText(buffer: StringBuffer): void {
    if (this.text != undefined) {
      buffer.write(this.text);
    }

    if (this.children != undefined) {
      for (let index = 0; index < this.children.length; index++) {
        const child = this.children[index];
        child.computeToPlainText(buffer);
      }
    }
  }
}