import * as extended_text from '@candies/extended_text'
import { TextSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"


export class RegExpDollarText extends extended_text.RegExpSpecialText {
  get regExp(): RegExp {
    return new RegExp('\\$(.+?)\\$', 'g');
  }
  finishText(start: number,
    match: RegExpExecArray,
    context: Context,
    textStyle?: text.TextStyle,): extended_text.InlineSpan {
    let text = match[0];
    return new TextSpan({
      text: text.replaceAll('$', ''),
      style: {
        fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Orange),
      },
      actualText: this.toString(),
      start: start,
    });
  }
}