import { DrawGradient } from "./Declare";

/// Enum to represent different modes of gradient applications on text.
export enum GradientRenderMode {
  fullText, // Apply gradient to the entire text.
  line, // Apply gradient to each line of the text.
  selection, // Apply gradient to specific text selections.
  word, // Apply gradient to specific text word.
  character, // Apply gradient to specific text character.
}


export interface GradientConfig {
  renderMode: GradientRenderMode;
  drawGradient: DrawGradient;
}