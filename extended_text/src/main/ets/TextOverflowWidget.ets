import { WidgetBuilder } from "./builder/WidgetBuilder";

export enum TextOverflowPosition {
  /// at the start of text view.
  start,
  /// at the middle of text view.
  middle,
  /// at the end of text view.
  end,
  /// make sure the keepVisible span in text view.
  /// [See also]: https://github.com/HarmonyCandies/extended_text/blob/main/entry/src/main/ets/pages/SearchHighlightDemo.ets
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