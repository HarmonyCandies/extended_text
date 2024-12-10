import { TextOverflowWidget } from '../TextOverflowWidget';
import { text, common2D } from "@kit.ArkGraphics2D"
import { drawing } from '@kit.ArkGraphics2D'
import { InlineSpan } from '../painting/InlineSpan';
import { ExtendedParagraph } from './Paragraph';
import { TextSpan } from '../painting/TextSpan';
import { FrameNode, NodeController, RenderNode } from '@kit.ArkUI';
import { SpecialTextSpanBuilder } from '../builder/SpecialTextSpanBuilder';
import { Accumulator } from '../Utils';
import { GradientConfig } from '../GradientConfig';

@Component
export struct ExtendedText {
  @Prop overflowWidget?: TextOverflowWidget;
  @Prop paragraphStyle?: text.ParagraphStyle;
  @Prop fontCollection?: text.FontCollection;
  @Watch('reBuildTextSpan') @Prop specialTextSpanBuilder?: SpecialTextSpanBuilder;
  @Watch('reBuildTextSpan') @Prop text?: string;
  @Watch('reBuildTextSpan') @Prop textSpan?: InlineSpan;
  @Watch('reBuildTextSpan') @Prop joinZeroWidthSpace: boolean = false;
  @Watch('reBuildTextSpan') @Prop gradientConfig?: GradientConfig;
  private _building: boolean = false;
  private _nodeController: _NodeController = new _NodeController()

  reBuildTextSpan(propName: string) {
    if (!this._building) {
      this._nodeController.clearNodes();
      this._building = true;
      this._refreshTag = !this._refreshTag;
    }
  }

  @State private _refreshTag: boolean = false;

  build() {
    Stack() {
      NodeContainer(this._nodeController)
      if (this._refreshTag) {
        ExtendedParagraph({
          overflowWidget: this.overflowWidget,
          paragraphStyle: this.paragraphStyle,
          fontCollection: this.fontCollection,
          text: this._buildTextSpan(),
          onDrawText: (paragraph, overflowClipRects: Array<common2D.Rect>) => {
            this._nodeController.clearNodes();
            let node = new _RenderNode(paragraph, overflowClipRects);

            node.size = {
              width: paragraph.getMaxWidth(),
              height: paragraph.getHeight(),
            }
            this._nodeController.addNode(node);
            this._building = false;
          }
        }).align(Alignment.Top).width('100%')
      } else {
        ExtendedParagraph({
          overflowWidget: this.overflowWidget,
          paragraphStyle: this.paragraphStyle,
          fontCollection: this.fontCollection,
          text: this._buildTextSpan(),
          onDrawText: (paragraph, overflowClipRects: Array<common2D.Rect>) => {
            this._nodeController.clearNodes();
            let node = new _RenderNode(paragraph, overflowClipRects, this.gradientConfig);

            node.size = {
              width: paragraph.getMaxWidth(),
              height: paragraph.getHeight(),
            }
            this._nodeController.addNode(node);
            this._building = false;
          }
        }).align(Alignment.Top).width('100%')
      }
    }
  }

  _buildTextSpan(): TextSpan {
    let innerTextSpan: TextSpan | null = null;
    if (this.specialTextSpanBuilder != undefined && this.text != undefined) {
      innerTextSpan = this.specialTextSpanBuilder.build(
        this.text!,
        getContext(this),
        this.paragraphStyle?.textStyle,
      )
    }
    innerTextSpan ??= new TextSpan(
      {
        text: this.text,
        children: [
          ...(this.textSpan == undefined ? [] : [this.textSpan!])
        ],
        style: this.paragraphStyle?.textStyle,
      }
    );

    if (this.joinZeroWidthSpace) {
      innerTextSpan =
        innerTextSpan.joinChar(new Accumulator()) as TextSpan;
    }

    return innerTextSpan;
  }
}

class _RenderNode extends RenderNode {
  constructor(paragraph: text.Paragraph, overflowClipRects: Array<common2D.Rect>, gradientConfig?: GradientConfig) {
    super();
    this.paragraph = paragraph;
    this.overflowClipRects = overflowClipRects;
    this.gradientConfig = gradientConfig;
  }

  paragraph: text.Paragraph;
  overflowClipRects: Array<common2D.Rect>;
  gradientConfig?: GradientConfig;

  async draw(context: DrawContext) {
    if (this.overflowClipRects.length != 0) {
      context.canvas.saveLayer();

      for (let index = 0; index < this.overflowClipRects.length; index++) {
        const overflowClipRect = this.overflowClipRects[index];
        context.canvas.clipRect(overflowClipRect, drawing.ClipOp.DIFFERENCE);
      }
    }

    const canvas = context.canvas;
    // if (this.gradientConfig != undefined) {
    //   let pen = this.gradientConfig.drawGradient(context, this.paragraph);
    //   canvas.attachPen(pen);
    // }
    let brush = new drawing.Brush();
    let width = context.size.width;
    let height = context.size.height;
    let shaderEffect = drawing.ShaderEffect.createLinearGradient({ x: 0, y: height / 2 }, { x: width, y: height / 2 },
      [0xFF2196F3, 0xFFF44336], drawing.TileMode.CLAMP);
    brush.setShaderEffect(shaderEffect);
    brush.setBlendMode(drawing.BlendMode.DIFFERENCE);
    this.paragraph.paint(context.canvas, 0, 0);
    context.canvas.save();
    context.canvas.attachBrush(brush);
    context.canvas.drawRect({
      left: 0,
      top: 0,
      right: width,
      bottom: height
    });
    context.canvas.detachBrush();
    context.canvas.restore();
    // if (this.gradientConfig != undefined) {
    //   canvas.detachPen();
    // }

    if (this.overflowClipRects.length != 0) {
      context.canvas.restore();
    }
  }
}

class _NodeController extends NodeController {
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
      // let xxx= renderNode.size;
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