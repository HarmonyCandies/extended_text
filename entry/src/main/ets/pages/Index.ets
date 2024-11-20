import router from '@ohos.router'
import { CustomTextOverflowDemo } from './CustomTextOverflowDemo';
import { RegexpTextDemo } from './RegexpTextDemo';
import { SearchHighlightDemo } from './SearchHighlightDemo';
import { TextDemo } from './TextDemo';


@Entry
@Component
struct Index {
  title: string = 'extended_text demo';
  pages: Array<PageInfo> = [
    {
      description: '展示如何快速创建特殊文本',
      route: 'TextDemo',
    },
    {
      description: '展示如何自定义文本溢出效果',
      route: 'CustomTextOverflowDemo',
    },
    {
      description: '展示如何利用正则表达式快速创建特殊文本',
      route: 'RegexpTextDemo',
    },
    {
      description: '一个短信搜索高亮的例子，展示 TextOverflowPosition.auto 的用法',
      route: 'SearchHighlightDemo',
    },
  ]
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'TextDemo') {
      TextDemo()
    } else if (name === 'CustomTextOverflowDemo') {
      CustomTextOverflowDemo()
    } else if (name === 'RegexpTextDemo') {
      RegexpTextDemo()
    } else if (name === 'SearchHighlightDemo') {
      SearchHighlightDemo()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Text(`${this.title}`)
        List() {
          ForEach(this.pages, (item: PageInfo, index) => {
            ListItem() {
              Text(`${index + 1}. ${item.description}`).onClick((x) => {
                this.pageInfos.pushPath({
                  name: item.route
                })

              }).margin(10)
            }.width('100%').align(Alignment.Start)
          })
        }.divider({ strokeWidth: 1, color: Color.Gray }).margin({ top: 10 })
      }
      .width('100%').height('100%')
    }.navDestination(this.PageMap)
  }
}

interface PageInfo {
  description: string;
  route: string;
}


