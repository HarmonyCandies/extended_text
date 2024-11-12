import { factoryMap } from "./FactoryMap";

export interface WidgetBuilder {
  builder: WrappedBuilder<[]>;
}