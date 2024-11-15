import * as extended_text from '@candies/extended_text'
import { TextSpan, WidgetSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"

@Builder
export function buildEmojiText(builderArgs: ESObject) {
  Image($rawfile(builderArgs as string)).width(20).height(20).margin({ left: 5, right: 5,})
}

export class EmojiText extends extended_text.SpecialText {
  static flag: string = '[';

  constructor(context: Context, start?: number, textStyle?: text.TextStyle,) {
    super(EmojiText.flag, ']', context, start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    let key = this.toString();
    if (emojiUitl.has(key)) {
      return new WidgetSpan(
        {
          builder: wrapBuilder<[ESObject]>(buildEmojiText),
          builderArgs: emojiUitl.get(key),
          actualText: key,
          start: this.start,
        },
      );
    }
    return new TextSpan({ text: key, style: this.textStyle });
  }
}

let emojiUitl: Map<string, string> =
  new Map([
    ['[love]', 'love.png'],
    ['[sun_glasses]', 'sun_glasses.png'],
    ['[40]', '40.png'],
    ['[candies]', 'candies.png'],]
  );