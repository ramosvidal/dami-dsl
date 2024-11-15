import fs from "fs";
import path from "path";
const rootFolder = process.cwd();
const config = fs.readFileSync(path.resolve(rootFolder,'./src/error/config.json'));

const SyntaxGenericError = {};

Object.keys(config).forEach(group => {
  Object.keys(config[group]).forEach(definition => {
    // Sets name accoring to config
    const name = [
      group[0].toUpperCase(),
      group.slice(1),
      definition[0].toUpperCase(),
      definition.slice(1),
      "Error"
    ].join("");

    const code = `E_${group.toUpperCase()}_${definition.toUpperCase()}`;
    const message = config[group][definition].message;

    SyntaxGenericError[name] = class extends Error {
      constructor(payload) {
        super(payload);

        this.code = code;
        this.message = message;

        if (typeof payload !== "undefined") {
          this.message = payload.message || message;
          this.payload = payload;
        }

        Error.captureStackTrace(this, SyntaxGenericError[name]);
      }
    };
  });
});

export default SyntaxGenericError;
