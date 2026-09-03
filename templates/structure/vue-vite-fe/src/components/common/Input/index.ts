import InputBase from './Input.vue';
import Password from './Password.vue';
import TextArea from './TextArea.vue';

// Mirrors the React Object.assign(InputBase, { TextArea, Password }) compound
// component so consumers can keep writing <Input.TextArea /> / <Input.Password />.
export const Input = Object.assign(InputBase, { TextArea, Password });

export type { InputProps } from './Input.vue';
export type { PasswordProps } from './Password.vue';
export type { TextAreaProps } from './TextArea.vue';
