import { WidgetBuilder } from "./WidgetBuilder";

export enum TextOverflowPosition {
  start,
  middle,
  end,
}

export interface TextOverflowWidgetOptions {
  builder: WrappedBuilder<[]>;
  position?: TextOverflowPosition;
}

export class TextOverflowWidget implements WidgetBuilder {
  constructor(options: TextOverflowWidgetOptions) {
    this.builder = options.builder;
    this.position = options.position ?? TextOverflowPosition.end;
  }

  builder: WrappedBuilder<[]>;
  position: TextOverflowPosition;
}