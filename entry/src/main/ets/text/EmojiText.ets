import * as extended_text from '@candies/extended_text'
import { TextSpan, WidgetSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"

@Builder
function buildEmojiText(builderArgs: ESObject) {
  Image($rawfile(builderArgs as string)).width(20).height(20).margin(5)
}

export class EmojiText extends extended_text.SpecialText {
  static flag: string = '[';

  constructor(textStyle?: text.TextStyle, start?: number,) {
    super(EmojiText.flag, ']', start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    let key = this.toString();
    if (emojiUitl.has(key)) {
      return new WidgetSpan(
        { builder: wrapBuilder<[ESObject]>(buildEmojiText), builderArgs: emojiUitl.get(key), },
      );
    }
    return new TextSpan({ text: key, style: this.textStyle });
  }
}

let emojiUitl: Map<string, string> = new Map([['[love]', 'love.png'], ['[sun_glasses]', 'sun_glasses.png'],]);