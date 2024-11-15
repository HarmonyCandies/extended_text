import * as extended_text from '@candies/extended_text'
import { TextSpan, WidgetSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"
import { xml } from '@kit.ArkTS';


// <a href='https://github.com/HarmonyCandies'>HarmonyCandies</a>

// Hyperlink

@Builder
export function buildHyperlink(builderArgs: ESObject) {
  Row(){
     Hyperlink(builderArgs[0], builderArgs[1])
  }
}

export class LinkText extends extended_text.SpecialText {
  static flag: string = '<a href=';

  constructor(context: Context, start?: number, textStyle?: text.TextStyle,) {
    super(LinkText.flag, '</a>', context, start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    const regex = /<a\s+href=['"]([^'"]*)['"]>(.*?)<\/a>/;
    const match = this.toString().match(regex);
    if (match) {
      const href = match[1]; // 链接
      const content = match[2]; // 内容
      return new WidgetSpan({
        builder: wrapBuilder<[ESObject]>(buildHyperlink),
        builderArgs: [href, content],
        style: {
          fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Blue),
          fontWeight: text.FontWeight.W600,
        },
        actualText: this.toString(),
        start: this.start,
      });
    } else {
      return new TextSpan({
        text: this.getContent(),
        style: {
          fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Blue),
          fontWeight: text.FontWeight.W600,
        },
      });
    }

  }
}