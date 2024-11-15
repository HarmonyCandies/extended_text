import * as extended_text from '@candies/extended_text'
import { TextSpan, WidgetSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"
import { buildEmojiText } from '../special/EmojiText';


export class RegExpEmojiText extends extended_text.RegExpSpecialText {
  get regExp(): RegExp {
    return new RegExp("\\[(.+?)\\]", "g");
  }

  finishText(start: number,
    match: RegExpExecArray,
    context: Context,
    textStyle?: text.TextStyle,): extended_text.InlineSpan {
    let key = match[0];
    if (emojiUitl.has(key)) {
      return new WidgetSpan(
        {
          builder: wrapBuilder<[ESObject]>(buildEmojiText),
          builderArgs: emojiUitl.get(key),
          actualText: key,
          start: start,
        }
      );
    }
    return new TextSpan({ text: key, style: textStyle });
  }
}

let emojiUitl: Map<string, string> =
  new Map([
    ['[love]', 'love.png'],
    ['[sun_glasses]', 'sun_glasses.png'],
    ['[40]', '40.png'],
    ['[candies]', 'candies.png'],]
  );