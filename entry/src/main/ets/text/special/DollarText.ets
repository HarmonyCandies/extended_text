import * as extended_text from '@candies/extended_text'
import { TextSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"


export class DollarText extends extended_text.SpecialText {
  static flag: string = '$';

  constructor(context: Context, start?: number, textStyle?: text.TextStyle,) {
    super(DollarText.flag, DollarText.flag, context, start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    let text = this.getContent();
    return new TextSpan({
      text: text,
      style: {
        fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Orange),
      },
      actualText: this.toString(),
      start: this.start,
    });
  }
}