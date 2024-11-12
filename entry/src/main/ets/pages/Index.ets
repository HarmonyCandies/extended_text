import { drawing } from '@kit.ArkGraphics2D'
import { text } from "@kit.ArkGraphics2D"
import { common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { ExtendedText, TextSpan } from '@candies/extended_text'
import * as extended_text from '@candies/extended_text'
import { MySpecialTextSpanBuilder } from '../text/MySpecialTextSpanBuilder';


@Builder
function buildTextOverflowWidget(builderArgs: ESObject) {
  Row() {
    Text("\u2026")
    Image($rawfile('candies.png')).width(20).height(20)
  }.onClick(() => {
    (builderArgs as () => void)();
  })
}

@Entry
@Component
struct Index {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  build() {
    Column() {
      Text() {
        Span('  123 Hello World !   ').fontSize('10fp').fontColor(Color.Blue)
        ContainerSpan() {
          ImageSpan($r('app.media.app_icon'))
            .width('40vp')
            .height('40vp')
            .verticalAlign(ImageSpanAlignment.CENTER)
          Span('   Hello World !   ').fontSize('16fp').fontColor(Color.White)
        }.textBackgroundStyle({ color: "#7F007DFF", radius: "12vp" })

        Span('  456 Hello World !   ').fontSize('10fp').fontColor(Color.Blue)
      }

      Column().backgroundColor(Color.Blue).width(50).height(50)
      Row().width(100).height(100).backgroundColor(Color.Blue)

      ExtendedText({
        text: "[love]Extended text help you to build rich text quickly. any special text you will have with extended text." +
          "It\'s my pleasure to invite you to join $HarmonyCandies$ if you want to make harmony better.[love]" +
          "'if you meet any problem, please let me know @zmtzawqlp .",
        specialTextSpanBuilder: this.specialTextSpanBuilder,
        overflowWidget: new extended_text.TextOverflowWidget(
          {
            builder: wrapBuilder(buildTextOverflowWidget),
            position: extended_text.TextOverflowPosition.end,
            builderArgs: this.onTextOverflowWidgetClick,
          }
        ),
        paragraphStyle: {
          textStyle: {
            color: {
              alpha: 255,
              red: 0,
              green: 0,
              blue: 255,
            },
            fontSize: vp2px(18),
            // ellipsis: '...abc',
            // ellipsisMode: text.EllipsisMode.END,
          },
          maxLines: 4,
        },
      }).width('100%')
    }
  }

  onTextOverflowWidgetClick(): void {
    console.log('点击溢出文本')
  }
}