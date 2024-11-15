import { ColorUtils, ExtendedText, SpecialTextSpanBuilder } from '@candies/extended_text'
import { MyRegExpSpecialTextSpanBuilder } from '../text/regexp/MyRegExpSpecialTextSpanBuilder';
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';


@Entry
@Component
export struct RegexpTextDemo {
  private specialTextSpanBuilder: SpecialTextSpanBuilder = new MyRegExpSpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string = MySpecialTextSpanBuilder.content;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          ExtendedText({
            text: this.content,
            specialTextSpanBuilder: this.specialTextSpanBuilder,
            paragraphStyle: {
              textStyle: {
                color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'), this.context),
                fontSize: vp2px(18),
              },
            },
            joinZeroWidthSpace: false,
          }).margin(10)
          Image($rawfile('candies_ account.png')).margin(10)
        }
      }
    }.title('RegexpTextDemo')
  }
}