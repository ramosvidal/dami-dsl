import antlr4 from "antlr4";

import SyntaxGenericError from "./error/helper.js";

/**
 * Custom Error Listener
 *
 * @returns {object}
 */
export default class ErrorListener extends antlr4.error.ErrorListener {
  /**
   * Checks syntax error
   *
   * @param {object} recognizer The parsing support code essentially. Most of it is error recovery stuff
   * @param {object} symbol Offending symbol
   * @param {int} line Line of offending symbol
   * @param {int} column Position in line of offending symbol
   * @param {string} message Error message
   * @param {string} payload Stack trace
   */
  syntaxError(recognizer, symbol, line, column, message, payload) {
    
    console.log(message);
    throw new SyntaxGenericError({ line, column, message });
  }
}

