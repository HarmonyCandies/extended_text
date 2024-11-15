import * as extended_text from '@candies/extended_text'
import { TextSpan, WidgetSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"
import { xml } from '@kit.ArkTS';
import { buildHyperlink } from '../special/LinkText';


// <a href='https://github.com/HarmonyCandies'>HarmonyCandies</a>

// Hyperlink


export class RegExpLinkText extends extended_text.RegExpSpecialText {
  get regExp(): RegExp {
    return RegExp("<a href='(.*?)'>(.*?)</a>", "g");
  }

  finishText(start: number,
    match: RegExpExecArray,
    context: Context,
    textStyle?: text.TextStyle,): extended_text.InlineSpan {
    const href = match[1]; // 链接
    const content = match[2]; // 内容
    return new WidgetSpan({
      builder: wrapBuilder<[ESObject]>(buildHyperlink),
      builderArgs: [href, content],
      style: {
        fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Blue),
        fontWeight: text.FontWeight.W600,
      },
      actualText: match[0],
      start: start,
    });

  }
}