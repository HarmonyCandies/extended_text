import { TextOverflowPosition, TextOverflowWidget } from '../TextOverflowWidget';
import { TextSpan } from '../painting/TextSpan';
import { WidgetSpan } from '../painting/WidgetSpan';
import { WidgetBuilder } from '../builder/WidgetBuilder';
import { text, common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { drawing } from '@kit.ArkGraphics2D'
import { ExtendedParagraphBuilder } from '../builder/ParagraphBuilder';
import { RectUtils } from '../Utils';
import {
  Accumulator,
  AssertException,
  debounce,
  InlineSpan,
  InlineSpanUtils,
  UnsupportedOperationException
} from '../../../../Index';
import { inspector } from '@kit.ArkUI';

@Component
export struct ExtendedParagraph {
  // @Prop @Watch('onRebuild')
  paragraphStyle?: text.ParagraphStyle;
  // @Prop @Watch('onRebuild')
  overflowWidget?: TextOverflowWidget;
  fontCollection?: text.FontCollection;
  // @Prop @Watch('onRebuild')
  text: TextSpan = new TextSpan({});
  onDrawText: (paragraph: text.Paragraph, overflowClipRects: Array<common2D.Rect>) => void = () => {
  };
  private _paragraph: text.Paragraph | undefined = undefined;
  private _overflowWidgetRect: common2D.Rect | null = null;
  private _overflowClipRects: Array<common2D.Rect> = [];

  @Builder
  builder() {
    ForEach([...WidgetSpan.extractFromInlineSpan(this.text),
      ...(this.overflowWidget == undefined ? [] : [this.overflowWidget])], (item: WidgetBuilder, index: number) => {
      item.builder.builder(item.builderArgs)
    })
  };

  aboutToAppear(): void {
    if (this.onDrawText != undefined && this._paragraph != undefined) {
      this.onDrawText(this._paragraph, this._overflowClipRects);
    }
  }

  build() {
    this.builder()
  }

  onPlaceChildren(selfLayoutInfo: GeometryInfo, children: Array<Layoutable>, constraint: ConstraintSizeOptions) {
    if (children.length == 0) {
      return;
    }

    let paragraph = this._paragraph!;
    let rects = paragraph.getRectsForPlaceholders();
    let index = 0;

    for (; index < rects.length; index++) {
      let rect = rects[index].rect;
      rect = {
        left: px2vp(rect.left),
        right: px2vp(rect.right),
        top: px2vp(rect.top),
        bottom: px2vp(rect.bottom),
      }
      let child = children[index];
      let margin = child.getMargin();
      let x = rect.left - margin.start;
      let y = rect.top - margin.top;

      if ((this._overflowWidgetRect != null && RectUtils.hasIntersection(rect, this._overflowWidgetRect!)) ||
        // hide widget
        (rect.right == rect.left && rect.top == rect.bottom)
      ) {
        // 不显示
        x = Infinity;
        y = Infinity;
      }
      child.layout({ x: x, y: y });
    }

    if (this.overflowWidget != null) {
      // overflow widget
      let child = children[children.length-1];
      if (this._overflowWidgetRect != null) {
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
    let fontCollection = this.fontCollection ?? new text.FontCollection();
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
      let childResult: MeasureResult = child.measure({})
      let margin = child.getMargin();
      dimensions.push({
        width: vp2px(childResult.width + margin.start + margin.end),
        height: vp2px(childResult.height + margin.top + margin.bottom),
      });
    }

    let position = this.overflowWidget?.position ?? TextOverflowPosition.end;
    let maxWidth = constraint.maxWidth as number;
    this.text?.build(paragraphGraphBuilder, dimensions);
    let paragraph = paragraphGraphBuilder.build();
    paragraph.layoutSync(vp2px(maxWidth));
    let didVisualOverflow = this._didVisualOverflow(paragraph, constraint);
    if (didVisualOverflow && this.overflowWidget != undefined) {
      if (position == TextOverflowPosition.auto) {
        let keepVisibleSpan: InlineSpan | null = null;
        this.text.visitChildren((span) => {
          if (span.keepVisible === true) {
            keepVisibleSpan = span;
            return false;
          }
          return true;
        })

        if (keepVisibleSpan == null && this.overflowWidget?.position == TextOverflowPosition.auto) {
          throw new AssertException(0, 'TextOverflowPosition.auto 只在 TextSpan 设置了 keepVisible 的情况下生效');
        }
        let range = keepVisibleSpan!.range!;
        let newParagraph = this._findNoOverflowByAuto(range, paragraphGraphBuilder, dimensions, constraint);
        if (newParagraph != null) {
          console.debug('find no overflow by layout the ParagraphBuilder' + this._layoutCount.toString() + ' times.')
          paragraph = newParagraph;
        }
      } else if (position != TextOverflowPosition.end) {
        let start = 0;
        let end = 0;
        const child = children[children.length-1];

        let copy = paragraphGraphBuilder.copy();
        this.text.build(copy, dimensions);
        let oneLineParagraph = copy.build();
        oneLineParagraph.layoutSync(Infinity);
        let estimatedCropRange = this._getEstimatedCropRange(paragraph, oneLineParagraph, child, position);
        start = estimatedCropRange.start!;
        end = estimatedCropRange.end!;

        start = Math.min(start, end);
        end = Math.max(start, end);

        let newParagraph = this._findNoOverflow({
          start: start,
          end: end,
        }, paragraphGraphBuilder, dimensions, constraint,);
        if (newParagraph != null) {
          console.debug('find no overflow by layout the ParagraphBuilder' + this._layoutCount.toString() + ' times.')
          paragraph = newParagraph;
        }
      }
    }


    this._overflowClipRects = [];
    if (this.overflowWidget != undefined) {
      const child = children[children.length-1];
      if (didVisualOverflow) {
        this._overflowClipRects.push(...this._setOverflowRect(paragraph, child, position));
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

    this.onDrawText(paragraph, this._overflowClipRects);
    this._paragraph = paragraph;
    return {
      width: maxWidth,
      height: px2vp(paragraph.getHeight()),
    };

  }

  // _handlexxx(paragraph: text.Paragraph, oneLineParagraph: text.Paragraph, overflowWidget: Measurable,
  // ): TextOverflowPosition {
  //   let keepVisibleSpan: InlineSpan | null = null;
  //   this.text.visitChildren((span) => {
  //     if (span.keepVisible === true) {
  //       keepVisibleSpan = span;
  //       return false;
  //     }
  //     return true;
  //   })
  //
  //   if (keepVisibleSpan == null && this.overflowWidget?.position == TextOverflowPosition.auto) {
  //     throw new AssertException(0, 'TextOverflowPosition.auto 只在 TextSpan 设置了 keepVisible 的情况下生效');
  //   }
  //   let range = keepVisibleSpan!.range!;
  //   let start = range.start!;
  //   let end = range.end!;
  //
  //
  //   start = this.text.convertInlineSpanPostionToParagraphPostion(start);
  //   end = this.text.convertInlineSpanPostionToParagraphPostion(end);
  //   let rects = paragraph.getRectsForRange({ start: start, end: end, }, text.RectWidthStyle.MAX,
  //     text.RectHeightStyle.MAX);
  //   let xxx = oneLineParagraph.getRectsForRange({ start: start, end: end, }, text.RectWidthStyle.MAX,
  //     text.RectHeightStyle.MAX);
  //
  //
  //   let overflowWidgetRectStart: common2D.Rect =
  //     this._getOverflowRect(paragraph, overflowWidget, TextOverflowPosition.start,);
  //   let overflowWidgetRectEnd: common2D.Rect =
  //     this._getOverflowRect(paragraph, overflowWidget, TextOverflowPosition.end,);
  //   // in view
  //   if (rects.length != 0) {
  //     for (let index = 0; index < rects.length; index++) {
  //       const element = rects[index];
  //       if (RectUtils.hasIntersection(overflowWidgetRectEnd, element.rect)) {
  //         return TextOverflowPosition.start;
  //       }
  //     }
  //     return TextOverflowPosition.end;
  //   } else {
  //
  //     let left = xxx[0].rect.left;
  //
  //     let right = oneLineParagraph.getMaxIntrinsicWidth() - xxx[0].rect.right;
  //
  //
  //     // at the end
  //     if (right >= (overflowWidgetRectEnd.right - overflowWidgetRectEnd.left)) {
  //       return TextOverflowPosition.start;
  //     }
  //
  //
  //     return TextOverflowPosition.auto;
  //   }
  // }

  _getEstimatedCropRange(paragraph: text.Paragraph, oneLineParagraph: text.Paragraph,
    overflowWidget: Measurable,
    position: TextOverflowPosition,
  ): TextRange {

    let margin = overflowWidget.getMargin();
    let childResult = overflowWidget.measure({})
    let overflowWidgetSize: MeasureResult = {
      width: vp2px((childResult.width + margin.start + margin.end)),
      height: vp2px((childResult.height + margin.top + margin.bottom)),
    };
    let lines = paragraph.getLineMetrics();
    let maxIntrinsicWidth = oneLineParagraph.getMaxIntrinsicWidth();

    switch (position) {
      case TextOverflowPosition.start: {
        for (let index = lines.length - 1; index >= 0; index--) {
          const line = lines[index];
          maxIntrinsicWidth -= line.width;
        }
        let end =
          oneLineParagraph.getGlyphPositionAtCoordinate(Math.max(overflowWidgetSize.width, maxIntrinsicWidth),
            oneLineParagraph.getHeight() / 2).position;
        return {
          start: 0,
          end: this.text.convertParagraphPostionToInlineSpanPostion(end),
        }
      }
      case TextOverflowPosition.middle: {
        let lineNum = Math.floor(lines.length / 2);
        let isEven = lines.length % 2 === 0;
        let line = lines[lineNum];
        let lineCenter = line.topHeight + line.height / 2;
        let overflowRect: common2D.Rect = {
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
        };
        let textWidth = paragraph.getMaxWidth();
        if (isEven) {
          overflowRect = {
            left: 0,
            top: lineCenter - overflowWidgetSize.height / 2,
            right: overflowWidgetSize.width,
            bottom: lineCenter + overflowWidgetSize.height / 2,
          }
        } else {
          overflowRect = {
            left: textWidth / 2 - overflowWidgetSize.width / 2,
            top: lineCenter - overflowWidgetSize.height / 2,
            right: textWidth / 2 + overflowWidgetSize.width / 2,
            bottom: lineCenter + overflowWidgetSize.height / 2,
          }
        }
        let start = paragraph.getGlyphPositionAtCoordinate(overflowRect.right,
          overflowRect.top + (overflowRect.bottom - overflowRect.top) / 2)
          .position;
        start = this.text.convertParagraphPostionToInlineSpanPostion(start);

        for (let index = lines.length - 1; index > lineNum; index--) {
          const line = lines[index];
          maxIntrinsicWidth -= line.width;
        }

        maxIntrinsicWidth -= (line.width - overflowRect.right);

        let end =
          oneLineParagraph.getGlyphPositionAtCoordinate(Math.max(overflowWidgetSize.width, maxIntrinsicWidth),
            oneLineParagraph.getHeight() / 2).position;
        end = this.text.convertParagraphPostionToInlineSpanPostion(end);
        return {
          start: start,
          end: end,
        }
      }
        break;
    }

    return {
      start: 0,
      end: 0,
    }
  }

  _getOverflowRect(paragraph: text.Paragraph,
    overflowWidget: Measurable, position: TextOverflowPosition): common2D.Rect {
    let textWidth = paragraph.getMaxWidth();
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
        line = lines[0]; {
        let lineCenter = line.topHeight + line.height / 2;
        overflowWidgetRect = {
          left: 0,
          top: lineCenter - overflowWidgetSize.height / 2,
          right: overflowWidgetSize.width,
          bottom: lineCenter + overflowWidgetSize.height / 2,
        }
      }
        break;
      case TextOverflowPosition.middle: {
        let lineNum = Math.floor(lines.length / 2);
        let isEven = lines.length % 2 === 0;
        line = lines[lineNum];

        let lineCenter = line.topHeight + line.height / 2;

        if (isEven) {
          overflowWidgetRect = {
            left: 0,
            top: lineCenter - overflowWidgetSize.height / 2,
            right: overflowWidgetSize.width,
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

      }
        break;
      case TextOverflowPosition.end: {
        line = lines[lines.length-1];
        let lineCenter = line.topHeight + line.height / 2;
        overflowWidgetRect = {
          left: textWidth - overflowWidgetSize.width,
          top: lineCenter - overflowWidgetSize.height / 2,
          right: textWidth,
          bottom: lineCenter + overflowWidgetSize.height / 2,
        }
      }
        break;
    }
    return overflowWidgetRect;
  }

  _setOverflowRect(paragraph: text.Paragraph,
    overflowWidget: Measurable, position: TextOverflowPosition,): Array<common2D.Rect> {
    let childResult = overflowWidget.measure({})
    let margin = overflowWidget.getMargin();
    let overflowWidgetRect: common2D.Rect = this._getOverflowRect(paragraph, overflowWidget, position,);
    let overflowWidgetSize: MeasureResult = {
      width: vp2px((childResult.width + margin.start + margin.end)),
      height: vp2px((childResult.height + margin.top + margin.bottom)),
    };
    let x = (overflowWidgetRect.right - overflowWidgetRect.left) / 10;
    let left = paragraph.getGlyphPositionAtCoordinate(overflowWidgetRect.left - x,
      overflowWidgetRect.top + overflowWidgetSize.height / 2);
    let right = paragraph.getGlyphPositionAtCoordinate(overflowWidgetRect.right + x,
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

  _layoutCount: number = 0;

  _findNoOverflowByAuto(range: TextRange, paragraphGraphBuilder: ExtendedParagraphBuilder,
    dimensions: Array<MeasureResult>, constraint: ConstraintSizeOptions): text.Paragraph | null {

    this._layoutCount = 0;
    let hasVisualOverflow: Boolean = true;
    let result: text.Paragraph | null = null;
    let rawRange: TextRange = {
      start: range.start,
      end: range.end,
    }
    let maxOffset = Array.from(this.text!.toActualText()).map(char => char.codePointAt(0) || 0).length;
    let maxEnd = maxOffset;
    while (hasVisualOverflow) {
      result = this._tryToFindNoOverflow(range, paragraphGraphBuilder, dimensions, constraint, false);
      hasVisualOverflow = result == null;
      if (hasVisualOverflow) {
        range.start = Math.min(range.start! + 1, rawRange.start!);
        range.end = Math.max(range.end! - 1, rawRange.end!);
      } else {
        range.start = Math.min(range.start! - 1, 0);
        range.end = Math.max(range.end! + 1, maxOffset);
        let pre: TextRange = {
          start: range.start,
          end: range.end,
        };
        let result = this._tryToFindNoOverflow(range, paragraphGraphBuilder, dimensions, constraint, false);
        let _hasVisualOverflow = result == null;
        if (_hasVisualOverflow) {
          hasVisualOverflow = false;
        } else {

        }

      }
    }
    return result;
  }

  _findNoOverflow(range: TextRange, paragraphGraphBuilder: ExtendedParagraphBuilder,
    dimensions: Array<MeasureResult>, constraint: ConstraintSizeOptions): text.Paragraph | null {
    this._layoutCount = 0;
    let hasVisualOverflow: Boolean = true;
    let result: text.Paragraph | null = null;

    let maxOffset = Array.from(this.text!.toActualText()).map(char => char.codePointAt(0) || 0).length;
    let maxEnd = maxOffset;
    while (hasVisualOverflow) {
      result = this._tryToFindNoOverflow(range, paragraphGraphBuilder, dimensions, constraint, true);
      hasVisualOverflow = result == null;
      if (hasVisualOverflow) {
        range.end = Math.min(
          range.end! + Math.max(Math.floor((maxEnd - range.end!) / 2), 1),
          maxOffset
        );
      } else {
        // see pre one whether overflow
        range.end = Math.min(range.end! - 1, maxOffset);

        let pre: TextRange = {
          start: range.start,
          end: range.end,
        };
        let result = this._tryToFindNoOverflow(range, paragraphGraphBuilder, dimensions, constraint, true);
        let _hasVisualOverflow = result == null;
        if (_hasVisualOverflow) {
          // fix end
          range.end = Math.min(range.end + 1, maxOffset);
          // find the one
          hasVisualOverflow = false;
        } else {
          maxEnd = range.end;
          range.end = Math.max(
            range.start!,
            Math.min(
              maxEnd - Math.max(Math.floor((maxEnd - range.start!) / 2), 1), maxEnd));
          // if range is not changed, so maybe we should break.
          if (pre.start == range.start && pre.end == range.end) {
            hasVisualOverflow = false;
          } else {
            hasVisualOverflow = true;
          }
        }
      }
    }
    return result;
  }

  _tryToFindNoOverflow(range: TextRange, paragraphGraphBuilder: ExtendedParagraphBuilder,
    dimensions: Array<MeasureResult>, constraint: ConstraintSizeOptions, excludeRange: boolean): text.Paragraph | null {
    let builder = paragraphGraphBuilder.copy();
    let text = this._cutOffInlineSpan(range, this.text, new Accumulator(), excludeRange);
    text.build(builder, dimensions);
    let p = builder.build();
    p.layoutSync(vp2px(constraint.maxWidth as number));
    this._layoutCount++;
    if (this._didVisualOverflow(p, constraint)) {
      return null;
    } else {
      return p;
    }
  }

  _cutOffInlineSpan(range: TextRange, value: InlineSpan, offset: Accumulator, excludeRange: boolean): InlineSpan {
    let output: InlineSpan;
    let actualText = value.actualText;
    if (value instanceof TextSpan) {
      let children: Array<InlineSpan> | undefined = undefined;
      let start = offset.value;
      let text = value.text;
      if (text !== undefined) {
        // 将字符串转为字符（Unicode 单位）的数组
        // abc😀
        // https://github.com/dart-lang/sdk/issues/35798

        const runes: number[] = Array.from(text).map(char => char.codePointAt(0) || 0);

        const finallyRunes: number[] = [];
        for (let i = 0; i < runes.length; i++) {
          const index = i + offset.value;
          let contains = range.start! <= index && index <= range.end! && excludeRange;
          if (contains) {
            continue; // 如果索引在指定范围内，则跳过
          }
          finallyRunes.push(runes[i]);
        }

        // 将字符码点数组转换回字符串
        // 😀 小心被裁剪之后不合法的乱码
        text = InlineSpanUtils.safeToStringFromRunes(finallyRunes);
        // text = String.fromCodePoint(...finallyRunes);
      }

      actualText ??= value.text;
      if (actualText != undefined) {
        const runes: number[] = Array.from(actualText).map(char => char.codePointAt(0) || 0);
        offset.increment(runes.length);
      }

      if (value.children != undefined) {
        children = [];
        for (let index = 0; index < value.children.length; index++) {
          const child = value.children[index];
          children.push(this._cutOffInlineSpan(range, child, offset, excludeRange));
        }
      }

      output = new TextSpan(
        {
          text: text,
          children: children,
          style: value.style,
          start: start,
          actualText: actualText,
          keepVisible: value.keepVisible,
        }
      );
    } else if (value instanceof WidgetSpan) {
      let hide = range.start! <= offset.value && offset.value <= range.end! && excludeRange;
      output = new WidgetSpan({
        builder: value.builder,
        builderArgs: value.builderArgs,
        hide: hide,
        align: value.align,
        baseline: value.baseline,
        baselineOffset: value.baselineOffset,
        start: value.start,
        style: value.style,
        actualText: value.actualText,
        keepVisible: value.keepVisible,
      })
      offset.increment(actualText?.length ?? 1);
    } else {
      output = value;
    }

    return output!;
  }
}

