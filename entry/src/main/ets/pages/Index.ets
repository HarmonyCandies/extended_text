import { drawing } from '@kit.ArkGraphics2D'
import { text } from "@kit.ArkGraphics2D"
import { common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { ExtendedText, TextSpan } from '@candies/extended_text'
import * as extended_text from '@candies/extended_text'

@Builder
function test() {
  Column().backgroundColor(Color.Blue).width(25).height(25)
  // Text('测试一下');
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private textContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  build() {
    Column() {
      Text() {
        ContainerSpan() {
          ImageSpan($r('app.media.app_icon'))
            .width('40vp')
            .height('40vp')
            .verticalAlign(ImageSpanAlignment.CENTER)
          Span('   Hello World !   ').fontSize('16fp').fontColor(Color.White)
        }.textBackgroundStyle({ color: "#7F007DFF", radius: "12vp" })
      }

      Row().width(100).height(100).backgroundColor(Color.Blue)

      ExtendedText({
        text: '你好大的打击啊看得见啊看建档立卡1',
        textSpan: new extended_text.TextSpan({
          text: '测试', children: [
            new extended_text.WidgetSpan({
              builder: wrapBuilder(test)
            })
            , new extended_text.TextSpan({
            text: '后缀', textStyle: {
              color: {
                alpha: 255,
                red: 255,
                green: 0,
                blue: 0,
              },
              fontSize: vp2px(18),
            },
          },)
          ],
        }),
        paragraphStyle: {
          textStyle: {
            color: {
              alpha: 255,
              red: 0,
              green: 0,
              blue: 255,
            },
            fontSize: vp2px(18),
          },
          maxLines: 2,
        },
        textStyle: {
          color: {
            alpha: 255,
            red: 0,
            green: 255,
            blue: 0,
          },
          fontSize: vp2px(18),
        }

      }).width('100%').height(30)
    }
  }
}