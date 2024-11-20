import { WidgetBuilder } from "./builder/WidgetBuilder";

export enum TextOverflowPosition {
  /// at the start of view.
  start,
  /// at the middle of view.
  middle,
  /// at the end of view.
  end,
  /// make sure the keepVisible span in view.
  auto,
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