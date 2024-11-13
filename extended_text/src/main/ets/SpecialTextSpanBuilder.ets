import { InlineSpan } from './painting/InlineSpan';
import { TextSpan } from './painting/TextSpan';
import { text, common2D } from "@kit.ArkGraphics2D"

export abstract class SpecialText {
  private _content: string = '';
  private _startFlag: string;
  private endFlag: string;
  textStyle?: text.TextStyle;
  start?: number;
  context: Context;

  get startFlag(): string {
    return this._startFlag;
  }

  constructor(startFlag: string, endFlag: string, context: Context, start?: number, textStyle?: text.TextStyle) {
    this._startFlag = startFlag;
    this.endFlag = endFlag;
    this.textStyle = textStyle;
    this.start = start;
    this.context = context;
  }

  // 判断是否是 SpecialText 的结束标记
  isEnd(value: string): boolean {
    return value.endsWith(this.endFlag);
  }

  // 添加内容到 SpecialText
  appendContent(value: string): void {
    this._content += value;
  }

  // 获取 SpecialText 内容（不包含 startFlag 和 endFlag）
  getContent(): string {
    let content = this._content;
    if (content.endsWith(this.endFlag)) {
      content = content.substring(0, content.length - this.endFlag.length);
    }
    return content;
  }

  // 完成 SpecialText
  abstract finishText(): InlineSpan;

  // 转换为字符串表示
  toString(): string {
    return this.startFlag + this.getContent() + this.endFlag;
  }
}

export abstract class SpecialTextSpanBuilder {
  // 构建包含特殊文本的 TextSpan
  build(data: string, context: Context, textStyle?: text.TextStyle,): TextSpan {
    if (data === '') {
      return new TextSpan({ text: '', style: textStyle });
    }

    const inlineList: InlineSpan[] = [];
    if (data.length > 0) {
      let specialText: SpecialText | null = null;
      let textStack = '';

      for (let i = 0; i < data.length; i++) {
        const char = data[i];
        textStack += char;

        if (specialText) {
          // 总是追加字符，并在 getContent 方法中移除 endFlag
          specialText.appendContent(char);
          if (specialText.isEnd(textStack)) {
            inlineList.push(specialText.finishText());
            specialText = null;
            textStack = '';
          }
        } else {
          specialText = this.createSpecialText(textStack, i, context, textStyle);
          if (specialText) {
            if (textStack.length - specialText.startFlag.length >= 0) {
              textStack = textStack.slice(0, textStack.length - specialText.startFlag.length);
              if (textStack) {
                inlineList.push(new TextSpan({ text: textStack, style: textStyle, }));
              }
            }
            textStack = '';
          }
        }
      }

      if (specialText) {
        inlineList.push(new TextSpan({
          text: specialText.startFlag + specialText.getContent(),
          style: textStyle,
        }));
      } else if (textStack) {
        inlineList.push(new TextSpan({ text: textStack, style: textStyle }));
      }
    } else {
      inlineList.push(new TextSpan({ text: data, style: textStyle }));
    }

    return new TextSpan({ children: inlineList, style: textStyle });
  }

  // 基于 startFlag 构建 SpecialText
  abstract createSpecialText(
    flag: string,
    index: number,
    context: Context,
    textStyle?: text.TextStyle,
  ): SpecialText | null;

  // 检查字符串是否以 startFlag 开头
  isStart(value: string, startFlag: string): boolean {
    return value.endsWith(startFlag);
  }
}

export abstract class RegExpSpecialText {
  // 获取正则表达式
  abstract get regExp(): RegExp;

  // 完成文本，返回 InlineSpan
  abstract finishText(
    start: number,
    match: RegExpExecArray,
    textStyle?: text.TextStyle,
  ): InlineSpan;
}

export abstract class RegExpSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  // 获取正则表达式列表
  abstract get regExps(): RegExpSpecialText[];

  // 构建带有正则表达式的文本
  build(
    data: string, context: Context,
    textStyle: text.TextStyle,
  ): TextSpan {
    if (data === '') {
      return new TextSpan({ text: '', style: textStyle });
    }

    const children: InlineSpan[] = [];
    if (this.regExps.length > 0) {
      this.buildWithRegExp(data, 0, [...this.regExps], children, context, textStyle);
    }

    return new TextSpan({ text: '', children: children, style: textStyle, });
  }

  // 使用正则表达式进行构建
  buildWithRegExp(
    data: string,
    start: number,
    copyRegExps: RegExpSpecialText[],
    children: InlineSpan[],
    context: Context,
    textStyle?: text.TextStyle,
  ): void {
    if (data === '') {
      return;
    }

    if (copyRegExps.length === 0) {
      children.push(new TextSpan({ text: data, style: textStyle }));
      return;
    }

    const regExpSpecialText = copyRegExps[0];

    data.split(regExpSpecialText.regExp).map((part, index) => {
      if (index % 2 === 1) { // match
        const match = regExpSpecialText.regExp.exec(part)!;
        const matchString = match[0];
        children.push(
          regExpSpecialText.finishText(start, match, textStyle,)
        );
        start += matchString.length;
      } else { // non-match
        if (part.length > 0) {
          this.buildWithRegExp(part, start, copyRegExps.slice(1), children, context, textStyle,);
          start += part.length;
        }
      }
    });
  }

  // 创建 SpecialText
  // 基于 startFlag 构建 SpecialText
  createSpecialText(
    flag: string,
    index: number,
    context: Context,
    textStyle?: text.TextStyle,
  ): SpecialText | null {
    return null;
  }
}