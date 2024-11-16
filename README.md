# extended_text

一个文本组件，支持特殊文本效果（比如图片，@人）,自定义文本溢出效果(ellipsis), 多行文本溢出效果位置(ellipsisMode)的支持.




| ![text_demo.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/text_demo.png)                   | ![overflow.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/overflow.png) |
| ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| ![joinZeroWidthSpace.png](https://github.com/HarmonyCandies/HarmonyCandies/blob/main/gif/extended_text/joinZeroWidthSpace.png) |
|                                                                                                                                |


关注公众号 `糖果代码铺` ，获取更多鸿蒙开发资讯.

![candies.png](https://github.com/zmtzawqlp/zmtzawqlp/blob/master/candies.png)

- [extended\_text](#extended_text)
  - [安装](#安装)
  - [使用](#使用)
    - [参数](#参数)
    - [InlineSpan](#inlinespan)
      - [TextSpan](#textspan)
      - [PlaceholderSpan](#placeholderspan)
      - [PlaceholderSpan](#placeholderspan-1)
    - [OverflowWidget](#overflowwidget)
    - [SpecialTextSpanBuilder](#specialtextspanbuilder)
      - [SpecialText](#specialtext)
      - [特殊文本 Builder](#特殊文本-builder)
    - [RegExpSpecialTextSpanBuilder](#regexpspecialtextspanbuilder)
      - [RegExpSpecialText](#regexpspecialtext)
      - [特殊文本 Builder](#特殊文本-builder-1)


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

### InlineSpan

用于创建特殊文本的基类


 | 参数       |      类型      |                    描述                    |
 | :--------- | :------------: | :----------------------------------------: |
 | style      | text.TextStyle |                 文本的样式                 |
 | actualText |     string     | 该特殊文本的真实文本(不一定等于显示的文本) |
 | start      |     number     |       该特殊文本位于整个文本中的位置       |
```typescript
export interface InlineSpanOptions {
  style?: text.TextStyle;
  actualText?: string;
  start?: number;
}
```

#### TextSpan

继承于 `InlineSpan` ，用于显示纯文本。

 | 参数     |       类型        |               描述               |
 | :------- | :---------------: | :------------------------------: |
 | text     |      string       |            显示的文案            |
 | children | Array<InlineSpan> | 作为子节点，类型是  `InlineSpan` |


```typescript
export interface TextSpanOptions extends InlineSpanOptions {
  text?: string;
  children?: Array<InlineSpan>;
}
```

#### PlaceholderSpan

用于占位符的 `Span`

 | 参数           |           类型            |       描述       |
 | :------------- | :-----------------------: | :--------------: |
 | align          | text.PlaceholderAlignment | 占位符的对齐方式 |
 | baseline       |     text.TextBaseline     | 占位符的基线类型 |
 | baselineOffset |          number           | 位符的基线偏移量 |

```typescript
export interface PlaceholderSpanOptions extends InlineSpanOptions {
  /**
   * Alignment mode of placeholder.
   * @type { PlaceholderAlignment }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  align?: text.PlaceholderAlignment;

  /**
   * Baseline of placeholder.
   * @type { TextBaseline }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baseline?: text.TextBaseline;

  /**
   * Baseline offset of placeholder.
   * @type { number }
   * @syscap SystemCapability.Graphics.Drawing
   * @since 12
   */
  baselineOffset?: number;
}
```

#### PlaceholderSpan


继承于 `PlaceholderSpan` ，用于显示显示组件。


 | 参数        |            类型            |                  描述                  |
 | :---------- | :------------------------: | :------------------------------------: |
 | builder     | WrappedBuilder<[ESObject]> |    用于显示组件的 `WrappedBuilder`     |
 | builderArgs |          ESObject          | 用于显示组件的 `WrappedBuilder` 的参数 |
 | hide        |          boolean           |           是否需要显示该组件           |

```typescript
export interface WidgetSpanOptions extends PlaceholderSpanOptions {
  builder: WrappedBuilder<[ESObject]>;
  builderArgs: ESObject;
  hide?: boolean,
}
```

注意： `buildHyperlink` 只能是全局的 `@Builder`

```typescript
@Builder
export function buildHyperlink(builderArgs: ESObject) {
  Row(){
     Hyperlink(builderArgs[0], builderArgs[1])
  }
}

  return new WidgetSpan({
    builder: wrapBuilder<[ESObject]>(buildHyperlink),
    builderArgs: [href, content],
    style: {
      fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Blue),
      fontWeight: text.FontWeight.W600,
    },
    actualText: this.toString(),
    start: this.start,
  });
```

 
### OverflowWidget

用于自定义文本的溢出效果。

* 目前官方支持修改 `ellipsis` ，但是只能是字符串
* 目前官方支持 `ellipsisMode`，但是只支持单行文本



 | 参数        |            类型            |                    描述                    |
 | :---------- | :------------------------: | :----------------------------------------: |
 | builder     | WrappedBuilder<[ESObject]> |    用于显示溢出组件的 `WrappedBuilder`     |
 | builderArgs |          ESObject          | 用于显示溢出组件的 `WrappedBuilder` 的参数 |
 | position    |    TextOverflowPosition    |  用于控制溢出组件的位置(start,middle,end)  |

```typescript
export enum TextOverflowPosition {
  start,
  middle,
  end,
}

export interface TextOverflowWidgetOptions {
  builder: WrappedBuilder<[ESObject]>;
  position?: TextOverflowPosition;
  builderArgs?: ESObject;
}
```

### SpecialTextSpanBuilder

帮助将字符串文本快速转换为特殊的 `InlineSpan` 

#### SpecialText

下面的例子告诉你怎么创建一个 `$xxx$`

具体思路是对字符串进行进栈遍历，通过判断 `flag` 来判定是否是一个特殊字符。
例子：`$xxx$` ，以 `$` 开头并且以 `$` 结束，我们就认为它是一个 `$xxx$` 的特殊文本

```typescript
export class DollarText extends extended_text.SpecialText {
  static flag: string = '$';

  constructor(context: Context, start?: number, textStyle?: text.TextStyle,) {
    super(DollarText.flag, DollarText.flag, context, start, textStyle);
  }

  finishText(): extended_text.InlineSpan {
    let text = this.getContent();
    return new TextSpan({
      text: text,
      style: {
        fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Orange),
      },
      actualText: this.toString(),
      start: this.start,
    });
  }
}
```

#### 特殊文本 Builder

创建属于你自己规则的 `Builder`，上面说了你可以继承 `SpecialText` 来定义各种各样的特殊文本。
* `build` 方法中，是通过具体思路是对字符串进行进栈遍历，通过判断 `flag` 来判定是否是一个特殊文本。
  感兴趣的，可以看一下 `SpecialTextSpanBuilder` 里面 `build` 方法的实现，当然你也可以写出属于自己的 `build` 逻辑
* `createSpecialText` 通过判断 `flag` 来判定是否是一个特殊文本

```typescript
import * as extended_text from '@candies/extended_text'
import { text } from "@kit.ArkGraphics2D"
import { DollarText } from './DollarText';
import { EmojiText } from './EmojiText';
import { LinkText } from './LinkText';

export class MySpecialTextSpanBuilder extends extended_text.SpecialTextSpanBuilder {
  createSpecialText(flag: string, index: number, context: Context,
    textStyle?: text.TextStyle | undefined): extended_text.SpecialText | null {
    if (this.isStart(flag, EmojiText.flag)) {
      return new EmojiText(context, index - (EmojiText.flag.length - 1), textStyle,);
    } else if (this.isStart(flag, DollarText.flag)) {
      return new DollarText(context, index - (DollarText.flag.length - 1), textStyle);
    } else if (this.isStart(flag, LinkText.flag)) {
      return new LinkText(context, index - (LinkText.flag.length - 1), textStyle);
    }
    return null;
  }
}
```

 
### RegExpSpecialTextSpanBuilder

当然，也提供了通过正则的方式，创建特殊文本的方式。

#### RegExpSpecialText

下面的例子告诉你怎么创建一个 `$xxx$`

 你只需要继承 `RegExpSpecialText` , 并且写出来对应的正则表达式即可。

```typescript
import * as extended_text from '@candies/extended_text'
import { TextSpan } from '@candies/extended_text';
import { text } from "@kit.ArkGraphics2D"


export class RegExpDollarText extends extended_text.RegExpSpecialText {
  get regExp(): RegExp {
    return new RegExp('\\$(.+?)\\$', 'g');
  }
  finishText(start: number,
    match: RegExpExecArray,
    context: Context,
    textStyle?: text.TextStyle,): extended_text.InlineSpan {
    let text = match[0];
    return new TextSpan({
      text: text.replaceAll('$', ''),
      style: {
        fontSize: vp2px(18), color: extended_text.ColorUtils.resourceColorTo2DColor(Color.Orange),
      },
      actualText: this.toString(),
      start: start,
    });
  }
}
```

#### 特殊文本 Builder

将上一步创建的 `RegExpSpecialText`，放到 `regExps` 当中即可。

```typescript
import { RegExpSpecialTextSpanBuilder } from '@candies/extended_text';
import { RegExpEmojiText } from './EmojiText';
import { RegExpDollarText } from './DollarText';
import { RegExpLinkText } from './LinkText';


export class MyRegExpSpecialTextSpanBuilder extends RegExpSpecialTextSpanBuilder {
  get regExps() {
    return [
      new RegExpDollarText(),
      new RegExpEmojiText(),
      new RegExpLinkText(),
    ];
  }
}
```
