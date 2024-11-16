import { WidgetBuilder } from "./builder/WidgetBuilder";

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

export class TextOverflowWidget implements WidgetBuilder {
  constructor(options: TextOverflowWidgetOptions) {
    this.builder = options.builder;
    this.position = options.position ?? TextOverflowPosition.end;
    this.builderArgs = options.builderArgs;
  }

  builder: WrappedBuilder<[ESObject]>;
  position: TextOverflowPosition;
  builderArgs: ESObject;
}