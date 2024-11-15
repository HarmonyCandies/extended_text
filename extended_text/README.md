# extended_text

一个文本组件，支持特殊文本效果（比如图片，@人）,自定义文本溢出效果(ellipsis), 多行文本溢出效果位置(ellipsisMode)的支持.

![overflow.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/overflow.png)
![joinZeroWidthSpace.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/joinZeroWidthSpace.png)
![text_demo.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/text_demo.png)

关注公众号 `糖果代码铺` ，获取更多鸿蒙开发资讯.

![candies.png](https://github.com/zmtzawqlp/zmtzawqlp/blob/master/candies.png)

- [extended\_text](#extended_text)
  - [安装](#安装)
  - [使用](#使用)
    - [参数](#参数)


## 安装

`ohpm install @candies/extended_text`


## 使用

完整例子: https://github.com/HarmonyCandies/extended_text/blob/main/entry/src/main/ets/pages/Index.ets

### 参数

 | 参数                   |                              类型                               |          描述          |
 | :--------------------- | :-------------------------------------------------------------: | :--------------------: |
 | text                   |                             string                              |       字符串内容       |
 | textSpan               |                           InlineSpan                            | 用于创建特殊文本的基类 |
 | joinZeroWidthSpace     |                             boolean                             |  是否添加零宽度的空白  |
 | paragraphStyle         | text.ParagraphStyle (import { text } from "@kit.ArkGraphics2D") |       文本的样式       |
 | overflowWidget         |                       TextOverflowWidget                        |    用于定义溢出效果    |
 | specialTextSpanBuilder |                     SpecialTextSpanBuilder                      |    用于创建特殊文本    |

```typescript
import { ColorUtils, ExtendedText } from '@candies/extended_text'
import { MySpecialTextSpanBuilder } from '../text/special/MySpecialTextSpanBuilder';
 
@Entry
@Component
struct Index {
  private specialTextSpanBuilder: MySpecialTextSpanBuilder = new MySpecialTextSpanBuilder();
  context: Context = getContext(this);
  content: string = MySpecialTextSpanBuilder.content;
  @State joinZeroWidthSpace: boolean = false;

  build() {
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
        joinZeroWidthSpace: this.joinZeroWidthSpace,
      })
    }
  }
}
```

 