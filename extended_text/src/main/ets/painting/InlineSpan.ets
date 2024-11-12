import { text } from "@kit.ArkGraphics2D"
import { InlineSpanVisitor } from "../Declare";
import { ExtendedParagraphBuilder } from "../ParagraphBuilder";


export interface InlineSpanOptions {
  style?: text.TextStyle;
}

export abstract class InlineSpan {
  style?: text.TextStyle;

  constructor(options: InlineSpanOptions) {
    this.style = options.style;
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
}