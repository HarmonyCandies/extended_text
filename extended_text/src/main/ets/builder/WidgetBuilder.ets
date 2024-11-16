
export interface WidgetBuilder {
  builder: WrappedBuilder<[ESObject]>;
  builderArgs: ESObject;
}