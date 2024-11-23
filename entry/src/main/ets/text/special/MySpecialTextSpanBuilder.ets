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
    } else
      if (this.isStart(flag, DollarText.flag)) {
      return new DollarText(context, index - (DollarText.flag.length - 1), textStyle);
    }
    else if (this.isStart(flag, LinkText.flag)) {
      return new LinkText(context, index - (LinkText.flag.length - 1), textStyle);
    }
    return null;
  }

  static content: string =
    "<a href='https://github.com/HarmonyCandies'>HarmonyCandies</a> (糖果[candies]群) 成立于 2020 年 9 月 10 日，聚集了一群热爱 [love] $Harmony$ 和 $Flutter$ 的开发者们，糖果群致力于通过持续创建、维护和贡献高质量的库 ($Harmony$ 组件工具 和 $Flutter$ 鸿蒙插件)，让 $Harmony$ 更易用，助力开发者们更快、更高效地构建优秀的 $Harmony$ 应用。" +
      "我们已经在 $ohpm.openharmony.cn$ 上发布了<a href='https://ohpm.openharmony.cn/#/cn/result?sortedType=relevancy&page=1&q=candies'>多个鸿蒙实用的组件</a>，在 $pub.dev$ 上发布了<a href='https://pub-web.flutter-io.cn/packages?q=topic%3Aharmony-os'>多个Flutter鸿蒙插件</a>，不仅如此，我们还构建了很多实用工具、API、实战项目以及优质的技术文章，帮助 $Harmony$ 和 $Flutter$ 开发者们在职业生涯的不同阶段快速成长。" +
      "我们希望号召和帮助更多开发者们为 $Harmony$ 开发更多实用的插件库 (小糖果)，如果你有同样的目标和理想，糖果群欢迎你的加入！[sun_glasses]" +
      "关注 $糖果代码铺$ ，获取更多 $鸿蒙$ 和 $Flutter$ 开发资讯。";
}