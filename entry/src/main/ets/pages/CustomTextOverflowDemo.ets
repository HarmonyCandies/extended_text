import { ColorUtils, ExtendedText } from '@candies/extended_text'
import * as extended_text from '@candies/extended_text'
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';
import { promptAction, router } from '@kit.ArkUI';

@Builder
function buildTextOverflowWidget(builderArgs: ESObject) {
  Row() {
    Text("\u2026")
    Image($rawfile('40.png')).width(20).height(20)
  }
  .alignItems(VerticalAlign.Center)
  .onClick(() => {
    let args: Array<ESObject> = builderArgs as Array<ESObject>;
    args[0](args[1], args[2]);

  })
}

@Entry
@Component
export struct CustomTextOverflowDemo {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string = MySpecialTextSpanBuilder.content;

  @Builder
  createText(position: extended_text.TextOverflowPosition, maxLines?: number) {
    Column() {
      Row() {
        Text('TextOverflowPosition: ' + extended_text.TextOverflowPosition[position].toString())
        Text('maxLines: ' + maxLines?.toString())
      }.justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: 10,
      }).width('100%')

      ExtendedText({
        text: this.content,
        specialTextSpanBuilder: this.specialTextSpanBuilder,
        overflowWidget: new extended_text.TextOverflowWidget(
          {
            builder: wrapBuilder(buildTextOverflowWidget),
            position: position,
            builderArgs: [this.onTextOverflowWidgetClick, position, maxLines,],
          }
        ),
        paragraphStyle: {
          textStyle: {
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'), this.context),
            fontSize: vp2px(18),
            heightScale: 1.2,
          },
          maxLines: maxLines,
        },
      })
    }
    .alignItems(HorizontalAlign.Start)
    .border({
      color: Color.Gray,
      width: 1,
    })
    .padding(10)
    .margin({
      top: 20,
    })
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          this.createText(extended_text.TextOverflowPosition.start, 4)
          this.createText(extended_text.TextOverflowPosition.middle, 3)
          this.createText(extended_text.TextOverflowPosition.middle, 4)
          this.createText(extended_text.TextOverflowPosition.end, 4)
        }.margin(5)
      }
    }.title('CustomTextOverflowDemo')
  }

  onTextOverflowWidgetClick(position: extended_text.TextOverflowPosition, maxLines?: number): void {

    promptAction.showToast({
      message: '点击溢出文本!\n' + 'TextOverflowPosition: ' + extended_text.TextOverflowPosition[position].toString() +
        '\n' +
        'maxLines: ' + maxLines?.toString(),
      alignment: Alignment.Center,
    })
  }
}