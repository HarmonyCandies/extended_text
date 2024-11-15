import { ColorUtils, ExtendedText } from '@candies/extended_text'
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';


@Entry
@Component
export struct TextDemo {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string = MySpecialTextSpanBuilder.content;
  @State joinZeroWidthSpace: boolean = false;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row() {
            Text('joinZeroWidthSpace: ')
            Checkbox({ name: 'checkbox1', })
              .select(this.joinZeroWidthSpace)
              .selectedColor(0x39a2db)
              .shape(CheckBoxShape.ROUNDED_SQUARE)
              .onChange((value: boolean) => {
                this.joinZeroWidthSpace = value;
              })
          }

          ExtendedText({
            text: this.content,
            specialTextSpanBuilder: this.specialTextSpanBuilder,
            paragraphStyle: {
              textStyle: {
                color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'), this.context),
                fontSize: vp2px(18),
              },
            },
            joinZeroWidthSpace: this.joinZeroWidthSpace,
          }).margin(10)
          Image($rawfile('candies_ account.png')).margin(10)
        }
      }
    }.title('TextDemo')
  }
}