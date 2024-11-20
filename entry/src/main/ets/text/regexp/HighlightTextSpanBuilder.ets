import { RegExpSpecialTextSpanBuilder } from '@candies/extended_text';
import { HighlightText } from './HighlightText';


export class HighlightTextSpanBuilder extends RegExpSpecialTextSpanBuilder {
  get regExps() {
    return [
      new HighlightText(),
    ];
  }
}