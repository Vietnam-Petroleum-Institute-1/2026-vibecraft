#!/usr/bin/env node
import { buildProgram } from './cli/commands';

buildProgram().parse(process.argv);
