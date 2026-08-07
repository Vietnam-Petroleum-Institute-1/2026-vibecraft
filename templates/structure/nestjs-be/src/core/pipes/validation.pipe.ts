import { ValidationPipe, ValidationPipeOptions } from '@nestjs/common';

// Project-wide validation defaults — see AGENTS.md "Security Rules" (ALWAYS
// validate ALL user input at the Controller level via DTOs).
const options: ValidationPipeOptions = {
  whitelist: true, // strip properties not declared in the DTO
  forbidNonWhitelisted: true, // reject requests that send extra properties
  transform: true, // auto-convert payloads into DTO class instances
};

export class AppValidationPipe extends ValidationPipe {
  constructor() {
    super(options);
  }
}
