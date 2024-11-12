import { TextOverflowWidget } from '../TextOverflowWidget';
import { text, common2D } from "@kit.ArkGraphics2D"
import { image } from '@kit.ImageKit';
import { drawing } from '@kit.ArkGraphics2D'
import { InlineSpan } from '../painting/InlineSpan';
import { ExtendedParagraph } from './Paragraph';
import { TextSpan } from '../painting/TextSpan';
import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI';
import { SpecialTextSpanBuilder } from '../SpecialTextSpanBuilder';

@Component
export struct ExtendedText {
  overflowWidget?: TextOverflowWidget;
  paragraphStyle?: text.ParagraphStyle;
  private onReady: boolean = false;
  paragraph: text.Paragraph | undefined = undefined;
  text?: string;
  private myNodeController: MyNodeController = new MyNodeController()
  textSpan?: InlineSpan;
  specialTextSpanBuilder?: SpecialTextSpanBuilder;

  build() {
    Stack() {
      NodeContainer(this.myNodeController)
      ExtendedParagraph({
        overflowWidget: this.overflowWidget,
        paragraphStyle: this.paragraphStyle,
        text: this.specialTextSpanBuilder != undefined && this.text != undefined ? this.specialTextSpanBuilder.build(
          this.text!,
          this.paragraphStyle?.textStyle,
        ) :
          new TextSpan(
            {
              text: this.text,
              children: this.textSpan != undefined ? [this.textSpan] : [],
              style: this.paragraphStyle?.textStyle,
            }),
        onDrawText: (paragraph, overflowClipRects: Array<common2D.Rect>) => {
          this.myNodeController.clearNodes();
          let node = new MyRenderNode(paragraph, overflowClipRects);
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
  constructor(paragraph: text.Paragraph, overflowClipRects: Array<common2D.Rect>) {
    super();
    this.paragraph = paragraph;
    this.overflowClipRects = overflowClipRects;
  }

  paragraph: text.Paragraph;
  overflowClipRects: Array<common2D.Rect>;

  async draw(context: DrawContext) {
    if (this.overflowClipRects.length != 0) {
      context.canvas.saveLayer();

      for (let index = 0; index < this.overflowClipRects.length; index++) {
        const overflowClipRect = this.overflowClipRects[index];
        context.canvas.clipRect(overflowClipRect, drawing.ClipOp.DIFFERENCE);
      }
    }
    this.paragraph.paint(context.canvas, 0, 0);
    // let xxx = new drawing.Brush();
    // xxx.setColor({
    //   alpha: 50,
    //   red: 255,
    //   green: 0,
    //   blue: 0,
    // },)
    // context.canvas.attachBrush(xxx)
    // context.canvas.drawRect({
    //   top: 0,
    //   left: 0,
    //   right: context.size.width,
    //   bottom: context.size.height,
    // })

    if (this.overflowClipRects.length != 0) {
      context.canvas.restore();
    }
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