import { InlineSpan, InlineSpanOptions } from "./InlineSpan";
import { text } from "@kit.ArkGraphics2D"
import { InlineSpanVisitor } from "../Declare";
import { ExtendedParagraphBuilder } from "../ParagraphBuilder";

export interface TextSpanOptions extends InlineSpanOptions {

  text?: string;
  children?: Array<InlineSpan>;
}

export class TextSpan extends InlineSpan {
  constructor(options: TextSpanOptions) {
    super(options);
    this.text = options.text;
    this.children = options.children;
  }

  text?: string;
  children?: Array<InlineSpan>;

  build(builder: ExtendedParagraphBuilder, dimensions: Array<MeasureResult>): void {
    let hasStyle = this.textStyle != undefined;
    if (hasStyle) {
      builder.pushStyle(this.textStyle!);
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
}