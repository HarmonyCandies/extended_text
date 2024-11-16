import { text } from "@kit.ArkGraphics2D"
import { InlineSpanVisitor } from "../Declare";
import { ExtendedParagraphBuilder } from "../builder/ParagraphBuilder";
import { Accumulator, InlineSpanUtils, StringBuffer } from "../Utils";
import { buffer } from "@kit.ArkTS";
import { TextSpan } from "./TextSpan";
import { PlaceholderSpan } from "./PlaceholderSpan";
import { WidgetSpan } from "./WidgetSpan";


export interface InlineSpanOptions {
  style?: text.TextStyle;
  actualText?: string;
  start?: number;
}

export abstract class InlineSpan {
  style?: text.TextStyle;
  actualText?: string;
  range?: TextRange;

  get start(): number {
    return this.range!.start!;
  }

  get end(): number {
    return this.range!.end!;
  }

  get isSpecialInlineSpan() {
    return this.range != undefined && this.actualText != undefined;
  }

  constructor(options: InlineSpanOptions) {
    this.style = options.style;
    this.actualText = options.actualText;
  }

  abstract build(builder: ExtendedParagraphBuilder, dimensions: Array<MeasureResult>): void;


  /// Walks this [InlineSpan] and any descendants in pre-order and calls `visitor`
  /// for each span that has content.
  ///
  /// When `visitor` returns true, the walk will continue. When `visitor` returns
  /// false, then the walk will end.
  ///
  /// See also:
  ///
  ///  * [visitDirectChildren], which preforms `build`-order traversal on the
  ///    immediate children of this [InlineSpan], regardless of whether they
  ///    have content.
  abstract visitChildren(visitor: InlineSpanVisitor): boolean;

  /// Calls `visitor` for each immediate child of this [InlineSpan].
  ///
  /// The immediate children are visited in the same order they are added to
  /// a [ui.ParagraphBuilder] in the [build] method, which is also the logical
  /// order of the child [InlineSpan]s in the text.
  ///
  /// The traversal stops when all immediate children are visited, or when the
  /// `visitor` callback returns `false` on an immediate child. This method
  /// itself returns a `bool` indicating whether the visitor callback returned
  /// `true` on all immediate children.
  ///
  /// See also:
  ///
  ///  * [visitChildren], which performs preorder traversal on this [InlineSpan]
  ///    if it has content, and all its descendants with content.
  abstract visitDirectChildren(visitor: InlineSpanVisitor): boolean;

  abstract computeToPlainText(buffer: StringBuffer): void;

  textSpanToActualText(): string {

    let buffer = new StringBuffer();
    this.visitChildren((e) => {
      if (e.isSpecialInlineSpan) {
        buffer.write(e.actualText!);
      } else {
        e.computeToPlainText(buffer);
      }
      return true;
    });

    return buffer.value;
  }

  convertTextPainterPostionToTextInputPostion(textPosition: number): number {
    let caretOffset = textPosition;
    if (caretOffset <= 0) {
      return caretOffset;
    }

    let textOffset = 0;
    this.visitChildren((ts: InlineSpan) => {
      if (ts.isSpecialInlineSpan) {
        let length = ts.actualText!.length;
        caretOffset += length - ts.getInlineOffset();
        ///make sure caret is not in text when deleteAll is true
        if (
          caretOffset >= ts.start &&
            caretOffset <= ts.end) {
          if (caretOffset >
            (ts.end - ts.start) / 2.0 + ts.start) {
            // move caretOffset to end
            caretOffset = ts.end;
          } else {
            caretOffset = ts.start;
          }
          return false;
        }
      }

      textOffset += ts.getInlineOffset();
      if (textOffset >= textPosition) {
        return false;
      }
      return true;
    })

    return caretOffset;
  }

  abstract getInlineOffset(): number;


  abstract joinChar(offset: Accumulator, char?: string): InlineSpan;

}