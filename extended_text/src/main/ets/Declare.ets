import { InlineSpan } from "./painting/InlineSpan";
import drawing from "@ohos.graphics.drawing";
import { text } from "@kit.ArkGraphics2D"

export declare type InlineSpanVisitor = (span: InlineSpan) => boolean;

export declare type DrawGradient =
  (context: DrawContext, paragraph: text.Paragraph,
  )
  =>
  drawing.Pen;
