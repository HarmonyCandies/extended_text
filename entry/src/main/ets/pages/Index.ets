import { drawing } from '@kit.ArkGraphics2D'
import { text } from "@kit.ArkGraphics2D"
import { common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { ColorUtils, ExtendedText, TextSpan } from '@candies/extended_text'
import * as extended_text from '@candies/extended_text'
import { MySpecialTextSpanBuilder } from '../text/MySpecialTextSpanBuilder';
import { promptAction } from '@kit.ArkUI';

@Builder
function buildTextOverflowWidget(builderArgs: ESObject) {
  Row() {
    Text("\u2026")
    Image($rawfile('candies.png')).width(20).height(20)
  }
  .alignItems(VerticalAlign.Center)
  .onClick(() => {
    (builderArgs as () => void)();
  })
}

@Entry
@Component
struct Index {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string =
    "[love]😀Extended text help you to build rich text quickly.[40] any special text you will have with extended text." +
      "It\'s my pleasure to invite you to join $HarmonyCandies$ if you want to make harmony better.[love]" +
      "'if you meet any problem, please let me know @zmtzawqlp ."

  aboutToAppear() {

  }
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
        text: this.content,
        specialTextSpanBuilder: this.specialTextSpanBuilder,
        overflowWidget: new extended_text.TextOverflowWidget(
          {
            builder: wrapBuilder(buildTextOverflowWidget),
            position: extended_text.TextOverflowPosition.start,
            builderArgs: this.onTextOverflowWidgetClick,
          }
        ),
        paragraphStyle: {
          textStyle: {
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.brand'), this.context),
            fontSize: vp2px(18),
          },
          maxLines: 4,
        },
      })
      ExtendedText({
        text: this.content,
        specialTextSpanBuilder: this.specialTextSpanBuilder,
        overflowWidget: new extended_text.TextOverflowWidget(
          {
            builder: wrapBuilder(buildTextOverflowWidget),
            position: extended_text.TextOverflowPosition.middle,
            builderArgs: this.onTextOverflowWidgetClick,
          }
        ),
        paragraphStyle: {
          textStyle: {
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.brand'), this.context),
            fontSize: vp2px(18),
          },
          maxLines: 4,
        },
      }).margin({
        top: 50,
      })
      ExtendedText({
        text: this.content,
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
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.brand'), this.context),
            fontSize: vp2px(18),
          },
          maxLines: 4,
        },
      }).margin({
        top: 50,
      })
    }
  }

  onTextOverflowWidgetClick(): void {
    promptAction.showToast({ message: '点击溢出文本', alignment: Alignment.Center, })
  }
}