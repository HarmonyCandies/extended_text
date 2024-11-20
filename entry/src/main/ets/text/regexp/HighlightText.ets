import * as extended_text from '@candies/extended_text'
import { TextSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"


export class HighlightText extends extended_text.RegExpSpecialText {
  get regExp(): RegExp {
    return new RegExp("<Highlight color=['\"](.*?)['\"]>(.*?)</Highlight>", "g");
  }

  static getHighlightString(content: string) {
    return '<Highlight color="#FF2196F3">' + content + '</Highlight>';
  }

  finishText(start: number,
    match: RegExpExecArray,
    context: Context,
    textStyle?: text.TextStyle,): extended_text.InlineSpan {
    let color = match[1];
    return new TextSpan({
      text: match[2],
      style: {
        fontSize: vp2px(18),
        color: extended_text.ColorUtils.stringTo2DColor(color),
      },
      actualText: match[0],
      start: start,
      keepVisible: true,
    });
  }
}