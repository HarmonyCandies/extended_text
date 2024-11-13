import { text } from "@kit.ArkGraphics2D"

export class ExtendedParagraphBuilder extends text.ParagraphBuilder {
  constructor(paragraphStyle: text.ParagraphStyle, fontCollection: text.FontCollection) {
    super(paragraphStyle, fontCollection);
    this.paragraphStyle = paragraphStyle;
    this.fontCollection = fontCollection;
  }

  placeholderCount: number = 0;
  paragraphStyle: text.ParagraphStyle;
  fontCollection: text.FontCollection
  hideWidgets: Array<number> = [];

  copy(): ExtendedParagraphBuilder {
    return new ExtendedParagraphBuilder(this.paragraphStyle, this.fontCollection);
  }
}