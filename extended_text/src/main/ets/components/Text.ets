import { TextOverflowWidget } from '../TextOverflowWidget';
import { text, common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { drawing } from '@kit.ArkGraphics2D'
import { InlineSpan } from '../painting/InlineSpan';
import { ExtendedParagraph } from './Paragraph';
import { TextSpan } from '../painting/TextSpan';
import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI';

@Component
export struct ExtendedText {
  overflowWidget?: TextOverflowWidget;
  paragraphStyle?: text.ParagraphStyle;
  private onReady: boolean = false;
  paragraph: text.Paragraph | undefined = undefined;
  text?: string;
  private myNodeController: MyNodeController = new MyNodeController()
  textSpan?: InlineSpan;
  textStyle?: text.TextStyle;

  build() {
    Stack() {
      NodeContainer(this.myNodeController)
      ExtendedParagraph({
        overflowWidget: this.overflowWidget,
        paragraphStyle: this.paragraphStyle,
        text: new TextSpan(
          {
            text: this.text,
            children: this.textSpan != undefined ? [this.textSpan] : [],
            textStyle: this.textStyle ?? this.paragraphStyle?.textStyle,
          }),
        onDrawText: (paragraph) => {
          this.myNodeController.clearNodes();
          let node = new MyRenderNode(paragraph);
          node.size = {
            width: paragraph.getMaxWidth(),
            height: paragraph.getHeight(),
          }
          this.myNodeController.addNode(node);
        }
      }).align(Alignment.Top).width('100%')
    }.onSizeChange((event) => {
      console.log(JSON.stringify(event));
    })
  }
}

class MyRenderNode extends RenderNode {
  constructor(paragraph: text.Paragraph) {
    super();
    this.paragraph = paragraph;
  }

  paragraph: text.Paragraph

  async draw(context: DrawContext) {
    this.paragraph.paint(context.canvas, 0, 0);
  }
}

class MyNodeController extends NodeController {
  private rootNode: FrameNode | null = null;

  makeNode(uiContext: UIContext): FrameNode {
    return this.rootNode ??= new FrameNode(uiContext)
  }

  addNode(node: RenderNode): void {
    if (this.rootNode == null) {
      return
    }
    // this.rootNode!.frame= node.frame;
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      // renderNode.size =  node.size;
      renderNode.appendChild(node)
    }
  }

  clearNodes(): void {
    if (this.rootNode == null) {
      return
    }
    const renderNode = this.rootNode.getRenderNode()
    if (renderNode != null) {
      renderNode.clearChildren()
    }
  }
}