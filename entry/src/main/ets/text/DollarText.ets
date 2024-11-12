import * as extended_text from '@candies/extended_text'
import { TextSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"


export class DollarText extends extended_text.SpecialText {
  static flag: string = '$';

  constructor(textStyle?: text.TextStyle, start?: number,) {
    super(DollarText.flag, DollarText.flag, start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    let text = this.getContent();
    return new TextSpan({
      text: text, style: {
        fontSize: vp2px(18), color: {
          alpha: 255,
          red: 255,
          green: 152,
          blue: 0,
        }
      }
    });
  }
}