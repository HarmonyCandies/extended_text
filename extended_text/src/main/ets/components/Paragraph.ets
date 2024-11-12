import { TextOverflowPosition, TextOverflowWidget } from '../TextOverflowWidget';
import { TextSpan } from '../painting/TextSpan';
import { WidgetSpan } from '../painting/WidgetSpan';
import { WidgetBuilder } from '../WidgetBuilder';
import { text, common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { drawing } from '@kit.ArkGraphics2D'
import { ExtendedParagraphBuilder } from '../ParagraphBuilder';

@Component
export struct ExtendedParagraph {
  paragraphStyle?: text.ParagraphStyle;
  overflowWidget?: TextOverflowWidget;
  text: TextSpan = new TextSpan({});
  _overflowOffset: common2D.Point = { x: 0, y: 0 };

  @Builder
  builder() {
    ForEach([...WidgetSpan.extractFromInlineSpan(this.text),
      ...(this.overflowWidget == undefined ? [] : [this.overflowWidget])], (item: WidgetBuilder, index: number) => {
      item.builder.builder(item.builderArgs)
    })
  };

  private _paragraph: text.Paragraph | undefined = undefined;
  onDrawText: (paragraph: text.Paragraph, overflowClipRects: Array<common2D.Rect>) => void = () => {
  };
  _overflowWidgetRect: common2D.Rect | null = null;

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    let paragraph = this._paragraph!;
    let rects = paragraph.getRectsForPlaceholders();
    let index = 0;
    for (; index < rects.length; index++) {
      const rect = rects[index];
      let child = children[index];
      let margin = child.getMargin();
      child.layout({ x: px2vp(rect.rect.left - margin.start), y: px2vp(rect.rect.top - margin.top) });
    }

    if (index < children.length && this._overflowWidgetRect != null) {
      // overflow widget
      let child = children[children.length-1];
      let didVisualOverflow = this._didVisualOverflow(paragraph, constraint);
      if (didVisualOverflow) {
        child.layout({
          x: this._overflowWidgetRect.left,
          y: this._overflowWidgetRect.top,
        })
      } else {
        // move out the screen
        child.layout({ x: Infinity, y: Infinity })
      }
    }

  }

  onMeasureSize(selfLayoutInfo: GeometryInfo, children: Array<Measurable>,
    constraint: ConstraintSizeOptions): SizeResult {
    this._overflowWidgetRect = null;
    let fontCollection = new text.FontCollection();
    let paragraphGraphBuilder = new ExtendedParagraphBuilder({
      textStyle: this.paragraphStyle?.textStyle,
      align: this.paragraphStyle?.align ?? text.TextAlign.START,
      textDirection: this.paragraphStyle?.textDirection ?? text.TextDirection.LTR,
      maxLines: this.paragraphStyle?.maxLines,
      breakStrategy: this.paragraphStyle?.breakStrategy,
      strutStyle: this.paragraphStyle?.strutStyle,
      textHeightBehavior: this.paragraphStyle?.textHeightBehavior,
    }, fontCollection,);

    let childCount = this.overflowWidget != null ? children.length - 1 : children.length;

    let index = 0;
    let dimensions = new Array<MeasureResult>();
    for (; index < childCount; index++) {
      const child = children[index];
      let childResult: MeasureResult = child.measure({
        minHeight: constraint.minHeight,
        minWidth: constraint.minWidth,
        maxWidth: constraint.maxWidth,
        maxHeight: constraint.maxHeight
      })
      let margin = child.getMargin();
      let padding = child.getPadding();
      let borderWidth = child.getBorderWidth();

      dimensions.push({
        width: vp2px(childResult.width + margin.start + margin.end),
        height: vp2px(childResult.height + margin.top + margin.bottom),
      });
    }


    this.text?.build(paragraphGraphBuilder, dimensions);


    let paragraph = paragraphGraphBuilder.build();
    let maxWidth = constraint.maxWidth as number;
    paragraph.layoutSync(vp2px(maxWidth));
    let overflowClipRects: Array<common2D.Rect> = [];
    if (index < children.length) {
      let didVisualOverflow = this._didVisualOverflow(paragraph, constraint);
      const child = children[index];
      if (didVisualOverflow) {
        overflowClipRects.push(...this._setOverflowRect(paragraph, child));
      } else {
        // not render
        child.measure({
          minHeight: 0,
          minWidth: 0,
          maxWidth: 0,
          maxHeight: 0,
        })
      }
    }

    this.onDrawText(paragraph, overflowClipRects);
    this._paragraph = paragraph;
    return {
      width: maxWidth,
      height: px2vp(paragraph.getHeight()),
    };

  }

  _setOverflowRect(paragraph: text.Paragraph,
    overflowWidget: Measurable,): Array<common2D.Rect> {
    let position = this.overflowWidget?.position;
    let textWidth = paragraph.getMaxWidth();
    let textHeight = paragraph.getHeight();
    let margin = overflowWidget.getMargin();

    let childResult = overflowWidget.measure({})
    let overflowWidgetRect: common2D.Rect = {
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
    };
    let overflowWidgetSize: MeasureResult = {
      width: vp2px((childResult.width + margin.start + margin.end)),
      height: vp2px((childResult.height + margin.top + margin.bottom)),
    };
    let lines = paragraph.getLineMetrics();
    let line: text.LineMetrics = lines[lines.length-1];
    switch (position) {
      case TextOverflowPosition.start:
        line = lines[0];
        overflowWidgetRect = {
          left: 0,
          top: 0,
          right: overflowWidgetSize.width,
          bottom: overflowWidgetSize.height,
        }
        break;
      case TextOverflowPosition.middle:
        let lineNum = Math.ceil(lines.length / 2) - 1;
        let isEven = lines.length % 2 === 0;
        line = lines[lineNum];

        let lineCenter = line.topHeight + line.height / 2;

        if (isEven) {
          overflowWidgetRect = {
            left: textWidth - overflowWidgetSize.width,
            top: lineCenter - overflowWidgetSize.height / 2,
            right: textWidth,
            bottom: lineCenter + overflowWidgetSize.height / 2,
          }
        } else {
          overflowWidgetRect = {
            left: textWidth / 2 - overflowWidgetSize.width / 2,
            top: lineCenter - overflowWidgetSize.height / 2,
            right: textWidth / 2 + overflowWidgetSize.width / 2,
            bottom: lineCenter + overflowWidgetSize.height / 2,
          }
        }

        break;
      case TextOverflowPosition.end:
        line = lines[lines.length-1];
        overflowWidgetRect = {
          left: textWidth - overflowWidgetSize.width,
          top: textHeight - overflowWidgetSize.height,
          right: textWidth,
          bottom: textHeight,
        }
        break;
    }
    let left = paragraph.getGlyphPositionAtCoordinate(overflowWidgetRect.left,
      overflowWidgetRect.top + overflowWidgetSize.height / 2);
    let right = paragraph.getGlyphPositionAtCoordinate(overflowWidgetRect.right,
      overflowWidgetRect.top + overflowWidgetSize.height / 2);

    let range: text.Range = { start: left.position, end: right.position };
    let overflowClipRects: Array<common2D.Rect> = [];


    let rects = paragraph.getRectsForRange(range, text.RectWidthStyle.MAX, text.RectHeightStyle.MAX);
    for (let index = 0; index < rects.length; index++) {
      const rect = rects[index].rect;
      let left = Math.max(rect.left, overflowWidgetRect.left);
      let right = Math.min(rect.right, overflowWidgetRect.right);

      if (left < right) {
        if (left > rect.left) {
          left = rect.left;
        }
        if (right < rect.right) {
          right = rect.right;
        }
        overflowClipRects.push({
          left: left,
          top: rect.top,
          right: right,
          bottom: rect.bottom,
        });
      }
    }
    this._overflowWidgetRect = {
      left: px2vp(overflowWidgetRect.left),
      right: px2vp(overflowWidgetRect.right),
      top: px2vp(overflowWidgetRect.top),
      bottom: px2vp(overflowWidgetRect.bottom),
    };
    return overflowClipRects;
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