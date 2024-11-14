const antlr4 = require('antlr4');
const DoubleGrammarLexer = require('./lib/DoubleGrammarLexer.js');
const DoubleGrammarParser = require('./lib/DoubleGrammarParser.js');
const ErrorListener = require('./src/ErrorListener.js');

const input = '2++++2';

const chars = new antlr4.InputStream(input);
const lexer = new DoubleGrammarLexer.DoubleGrammarLexer(chars);

lexer.strictMode = false; // do not use js strictMode

const tokens = new antlr4.CommonTokenStream(lexer);
const parser = new DoubleGrammarParser.DoubleGrammarParser(tokens);
const listener = new ErrorListener();

// Do this after creating the parser and before running it
//parser.removeErrorListeners(); // Remove default ConsoleErrorListener
//parser.addErrorListener(listener); // Add custom error listener

console.log('JavaScript input:');
console.log(input);

const tree = parser.parse();
