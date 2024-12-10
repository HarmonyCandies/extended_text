import { ColorUtils, ExtendedText } from '@candies/extended_text'
import { GradientRenderMode } from '@candies/extended_text/src/main/ets/GradientConfig';
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';
import { text } from "@kit.ArkGraphics2D"
import drawing from "@ohos.graphics.drawing";

@Entry
@Component
export struct GradientTextDemo {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string =  MySpecialTextSpanBuilder.content;
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
                color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'),
                  this.context),
                fontSize: vp2px(18),
              },
            },
            joinZeroWidthSpace: this.joinZeroWidthSpace,
            gradientConfig: {
              renderMode: GradientRenderMode.fullText,
              drawGradient: this.drawGradient
            }
          }).margin(10)
          Image($rawfile('candies_ account.png')).margin(10)
        }
      }
    }.title('TextDemo')
  }

  drawGradient(context: DrawContext, paragraph: text.Paragraph,): drawing.Pen {
    let pen = new drawing.Pen();
    let width = context.size.width;
    let height = context.size.height;
    let shaderEffect = drawing.ShaderEffect.createLinearGradient({ x: 0, y: height / 2 }, { x: width, y: height / 2 },
      [0xFF2196F3, 0xFFF44336], drawing.TileMode.CLAMP);
    pen.setShaderEffect(shaderEffect);
    pen.setBlendMode(drawing.BlendMode.SRC_IN);
    return pen;
  }
}