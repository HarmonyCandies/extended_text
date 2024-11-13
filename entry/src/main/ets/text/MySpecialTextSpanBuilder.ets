import * as extended_text from '@candies/extended_text'
import { text, common2D } from "@kit.ArkGraphics2D"
import { DollarText } from './DollarText';
import { EmojiText } from './EmojiText';

export class MySpecialTextSpanBuilder extends extended_text.SpecialTextSpanBuilder {
  createSpecialText(flag: string, index: number, context: Context,
    textStyle?: text.TextStyle | undefined): extended_text.SpecialText | null {
    if (this.isStart(flag, EmojiText.flag)) {
      return new EmojiText(context, index - (EmojiText.flag.length - 1), textStyle,);
    } else if (this.isStart(flag, DollarText.flag)) {
      return new DollarText(context, index - (DollarText.flag.length - 1), textStyle);
    }
    return null;
  }
}