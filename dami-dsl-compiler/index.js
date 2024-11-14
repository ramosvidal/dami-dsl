import antlr4 from "antlr4";
import fs from "fs";
import path from "path";

import BIDIGrammarLexer from "./lib/BIDIGrammarLexer.js";
import BIDIGrammarParser from "./lib/BIDIGrammarParser.js";
import ErrorListener from "./src/ErrorListener.js";
import BIDIVisitor from "./src/BIDIVisitor.js";
import store from "./src/store.js";
import script from "./src/script.js";

const rootFolder = process.cwd();

const definitionPath = process.argv[2];

const outputFile = process.argv[3];

const input = fs.readFileSync(path.resolve(rootFolder, definitionPath), {
  encoding: "utf-8"
});


// console.log(`input: ${input}`);

const chars = new antlr4.InputStream(input);
// console.log(`chars: ${chars}`);
const lexer = new BIDIGrammarLexer(chars);

lexer.strictMode = false; // do not use js strictMode
// console.log(`lexer: ${lexer.getAllTokens()}`);

const tokens = new antlr4.CommonTokenStream(lexer);
const parser = new BIDIGrammarParser(tokens);

const listener = new ErrorListener();

// Do this after creating the parser and before running it
//parser.removeErrorListeners(); // Remove default ConsoleErrorListener
//parser.addErrorListener(listener); // Add custom error listener

const visitor = new BIDIVisitor(store, script);

const tree = parser.parse();

visitor.start(tree, outputFile);
// store.getProducts().forEach(e => console.log(e.toString()));
