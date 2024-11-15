import { RegExpSpecialText, RegExpSpecialTextSpanBuilder } from '@candies/extended_text';
import { RegExpEmojiText } from './EmojiText';
import { RegExpDollarText } from './DollarText';
import { RegExpLinkText } from './LinkText';


export class MyRegExpSpecialTextSpanBuilder extends RegExpSpecialTextSpanBuilder {
  get regExps() {
    return [
      new RegExpDollarText(),
      new RegExpEmojiText(),
      new RegExpLinkText(),
    ];
  }
}