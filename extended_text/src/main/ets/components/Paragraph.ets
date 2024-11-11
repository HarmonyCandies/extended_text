import { TextOverflowWidget } from '../TextOverflowWidget';
import { TextSpan } from '../painting/TextSpan';
import { WidgetSpan } from '../painting/WidgetSpan';
import { WidgetBuilder } from '../WidgetBuilder';
import { text } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { drawing } from '@kit.ArkGraphics2D'
import { ExtendedParagraphBuilder } from '../ParagraphBuilder';

@Component
export struct ExtendedParagraph {
  paragraphStyle?: text.ParagraphStyle;
  overflowWidget?: TextOverflowWidget;
  text: TextSpan = new TextSpan({});

  @Builder
  builder() {
    ForEach([...WidgetSpan.extractFromInlineSpan(this.text),
      ...(this.overflowWidget == undefined ? [] : [this.overflowWidget])], (item: WidgetBuilder, index: number) => {
      item.builder.builder()
    })
  };

  private _paragraph: text.Paragraph | undefined = undefined;
  onDrawText: (paragraph: text.Paragraph) => void = () => {
  };

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    let paragraph = this._paragraph;
    let rects = paragraph!.getRectsForPlaceholders();
    for (let index = 0; index < rects.length; index++) {
      const rect = rects[index];
      let child = children[index];
      child.layout({ x: px2vp(rect.rect.left), y: px2vp(rect.rect.top) });
    }

  }

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>,
    constraint: ConstraintSizeOptions): SizeResult {

    let fontCollection = new text.FontCollection();
    let paragraphGraphBuilder = new ExtendedParagraphBuilder({
      textStyle: this.text!.textStyle ?? this.paragraphStyle?.textStyle,
      align: this.paragraphStyle?.align ?? text.TextAlign.START,
      textDirection: this.paragraphStyle?.textDirection ?? text.TextDirection.LTR,
      maxLines: this.paragraphStyle?.maxLines,
      breakStrategy: this.paragraphStyle?.breakStrategy,
      strutStyle: this.paragraphStyle?.strutStyle,
      textHeightBehavior: this.paragraphStyle?.textHeightBehavior,
    }, fontCollection,);

    let childCount = this.overflowWidget != null ? children.length - 1 : children.length;


    let dimensions = new Array<MeasureResult>();
    for (let index = 0; index < childCount; index++) {
      const child = children[index];
      let childResult: MeasureResult = child.measure({
        minHeight: constraint.minHeight,
        minWidth: constraint.minWidth,
        maxWidth: constraint.maxWidth,
        maxHeight: constraint.maxHeight
      })
      dimensions.push({
        width: vp2px(childResult.width),
        height: vp2px(childResult.height),
      });
    }


    this.text?.build(paragraphGraphBuilder, dimensions);


    let paragraph = paragraphGraphBuilder.build();
    let maxWidth = constraint.maxWidth as number;
    paragraph.layoutSync(vp2px(maxWidth));
    this.onDrawText(paragraph);
    this._paragraph = paragraph;
    let xx = paragraph.getMaxWidth();
    let a = paragraph.getMinIntrinsicWidth();
    let b = paragraph.getMaxIntrinsicWidth();
    let didExceedMaxLines = paragraph.didExceedMaxLines();

    //
    for (let index = childCount; index < children.length; index++) {


    }
    let didVisualOverflow = this._didVisualOverflow(paragraph, constraint);

    return {
      width: maxWidth,
      height: px2vp(paragraph.getHeight()),
    };
  }

  _didVisualOverflow(paragraph: text.Paragraph, constraint: ConstraintSizeOptions): boolean {
    let textSize: SizeResult = {
      width: px2vp(paragraph.getMaxWidth()),
      height: px2vp(paragraph.getHeight()),
    };
    let size: SizeResult = {
      width: constraint.maxWidth! as number,
      height: constraint.maxHeight! as number,
    }
    let textDidExceedMaxLines =
      paragraph.didExceedMaxLines();
    let
      didOverflowHeight =
        size.height < textSize.height || textDidExceedMaxLines;
    let
      didOverflowWidth = size.width < textSize.width;
    let hasVisualOverflow = didOverflowWidth || didOverflowHeight;
    return hasVisualOverflow;
  }

  build() {
    this.builder()
  }
}