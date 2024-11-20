import {
  ColorUtils,
  ExtendedText,
  SpecialTextSpanBuilder,
  TextOverflowPosition,
  TextOverflowWidget
} from '@candies/extended_text';
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';
import { DataSourceBase } from '@candies/loading_more_list/src/main/ets/viewmodel/LoadingMoreBase';
import { HighlightText } from '../text/regexp/HighlightText';
import { HighlightTextSpanBuilder } from '../text/regexp/HighlightTextSpanBuilder';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
export struct SearchHighlightDemo {
  private specialTextSpanBuilder: SpecialTextSpanBuilder = new HighlightTextSpanBuilder();
  context: Context = getContext(this);
  content: string = MySpecialTextSpanBuilder.content;
  @State joinZeroWidthSpace: boolean = false;
  @State searchMeassages: SearchMessages = new SearchMessages();
  controller: TextInputController = new TextInputController()
  @State searchText: string = ''

  aboutToAppear(): void {
    this.searchMeassages.push(...messages);
  }

  build() {
    NavDestination() {
      Column() {
        TextInput({ text: this.searchText, placeholder: '搜索...', controller: this.controller })
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 14, weight: 400 })
          .caretColor(Color.Blue)
          .width('95%')
          .height(40)
          .margin(20)
          .fontSize(14)
          .fontColor(Color.Black)// .inputFilter('[a-z]', (e) => {
            //   console.log(JSON.stringify(e))
            // })
          .onChange((value: string) => {
            this.searchText = value;
            this.searchMeassages.splice(0, this.searchMeassages.length);
            if (value != '') {
              for (let index = 0; index < messages.length; index++) {
                const element = messages[index];
                if (element.includes(value)) {
                  this.searchMeassages.push(element.replace(value, HighlightText.getHighlightString(value)));
                }
              }
            } else {
              this.searchMeassages.push(...messages);
            }
            this.searchMeassages.notifyDataReload();
          })

        List() {
          LazyForEach(this.searchMeassages, (item: string, index: number) => {
            MessageItem({
              message: item,
              specialTextSpanBuilder: this.specialTextSpanBuilder,
              maxLines: this.searchText === '' ? 3 : 1,
              textOverflowPosition: this.searchText === '' ? TextOverflowPosition.end : TextOverflowPosition.auto,
            })
          }, (item: string, index: number) => {
            return index + item;
          })
        }.layoutWeight(1)
      }

    }.title('TextDemo')
  }
}

class SearchMessages extends DataSourceBase<string> {
}

@Builder
function buildTextOverflowWidget(builderArgs: ESObject) {
  Text("\u2026")
    .onClick(() => {
      let args: Array<ESObject> = builderArgs as Array<ESObject>;
      args[0](args[1]);
    })
}

@Component
struct MessageItem {
  message: string = '';
  specialTextSpanBuilder?: SpecialTextSpanBuilder;
  context: Context = getContext(this);
  maxLines: number = 3;
  textOverflowPosition: TextOverflowPosition = TextOverflowPosition.end;
  dialogController: CustomDialogController | null = null;

  build() {
    Row() {
      ExtendedText({
        text: this.message,
        specialTextSpanBuilder: this.specialTextSpanBuilder,
        paragraphStyle: {
          textStyle: {
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'), this.context),
            fontSize: vp2px(18),
          },
          maxLines: this.maxLines,
        },
        overflowWidget: new TextOverflowWidget({
          builder: wrapBuilder(buildTextOverflowWidget),
          builderArgs: [this.onTextOverflowWidgetClick, this.message],
          position: this.textOverflowPosition,
        },)
      })
    }
    .border({
      color: Color.Gray,
      width: 1,
    }).padding(10)
    .margin(20).onClick(() => {
      this.showFullTextImage(this.message);
    })
  }

  onTextOverflowWidgetClick(content: string): void {
    // promptAction.showToast({
    //   message: '点击溢出文本!\n' + 'TextOverflowPosition: ' + TextOverflowPosition[position].toString() +
    //     '\n' +
    //     'maxLines: ' + maxLines?.toString(),
    //   alignment: Alignment.Center,
    // })
  }

  async showFullTextImage(text: string): Promise<void> {
    this.dialogController = new CustomDialogController({
      builder: FullTextDialog({
        text: text,
        controller: this.dialogController!,
      }),
      autoCancel: true,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {

      },
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      customStyle: false,
      cornerRadius: 20,
      width: 300,
      // height: 500,
      borderWidth: 1,
      borderStyle: BorderStyle.Dashed,
      borderColor: Color.Blue,
      backgroundColor: Color.White,
    });
    this.dialogController.open();
  }
}

@CustomDialog
@Component
struct FullTextDialog {
  text?: string;
  controller?: CustomDialogController;
  context: Context = getContext(this);

  build() {
    Column() {
      Button('关闭')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
          }
        }).backgroundColor(0xffffff).fontColor(Color.Black)
      ExtendedText({
        text: this.text, specialTextSpanBuilder: new HighlightTextSpanBuilder(),
        paragraphStyle: {
          textStyle: {
            color: ColorUtils.resourceColorTo2DColor($r('sys.color.font'), this.context),
            fontSize: vp2px(18),
          },
        },

      })
    }.padding(20)
    .borderRadius
    (10
    )
  }
}

const messages: Array<string> =
  ['【翼支付】尊敬的用户，您有2元话费券未使用，将于5天内失效，点击查看，如已使用请忽略！拒收请回复R',
    '气象台下周天气预报：17日阴到多云有短时小雨转多云到阴15到18度；18日阴到多云，局部有短时小雨转阴到多云12到15度；19日多云到阴转多云12到15度；20日多云12到17度；21日多云到晴13到17度；22日多云12到17度；23日阴到多云转阴到多云有短时小雨13到18度。【中国移动　气象助手】',
    '气象台15日6时：阴到多云有时有阵雨，今上午以前大部地区有雾。东北风3-4级，明转偏北风4-5级。23-19度。我台已发布大雾黄色预警。【中国移动　气象助手】',
    '防汛防台安全提示：“贝碧嘉”将近，请关注天气；暴雨来临，减少出行；确需开车，遇水绕行；注意坠物，减少伤害；人人关注防汛、人人知晓防汛、人人参与防汛。【市防汛指挥部办公室】',
    '市通管局、市反诈中心提醒：警惕邮寄黄金诈骗。近期，诈骗分子以各种名义，诱骗群众购买并邮寄实物黄金的案件呈上升趋势，请广大市民群众谨防被骗。',
    '【中国电信积分商城】尊敬的用户，您的 爱奇艺 VIP会员黄金月卡 已充值成功，使用充值账号登录即可享受会员权益。如尚未注册，使用充值号码完成注册后登录即可。关注微信“天翼积分”公众号 ，在个人中心查看订单详情！',
    '【人口普查】依法配合人口普查是每个公民应尽的义务。10月11日起，本市普查指导员和普查员将佩戴统一证件入户开展普查摸底，需要您的支持和配合！',
    '上海海警局提醒您：5月1日起，上海海域进入海洋伏季休渔期。请自觉遵守伏季休渔制度，切勿在通信海缆保护区内从事挖砂、钻探、抛锚、拖锚、底拖捕捞、张网及其他可能危及通信海缆安全的海上作业，积极配合执法部门开展日常执法工作，切实保护海底电缆管道及海洋渔业资源。欢迎通过95110海上报警电话提供违法违规线索。',
    '【开放原子】您好，第二届开放原子大赛已正式启动，大赛覆盖基础软件、工业软件、人工智能大模型、创新应用等多个技术领域，设置巅峰挑战赛、实战竞技赛、训练学习赛等不同难度的赛项类型，总奖金约1500万元。登录大赛官网，查看更多比赛信息。拒收请回复R',
    '【Apple】Apple 账户代码为：117409。请勿与他人共享。',
    '【饿了么】您在:炭小签·贵阳特色烧烤下的订单正在加急调度骑士中,恳请您耐心等待！',
  ];