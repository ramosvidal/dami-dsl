import {
  DerivationEngine,
  readJsonFromFile,
  readFile
} from "spl-js-engine";
import path from "path";
const rootFolder = process.cwd();

function engine() {
  return new DerivationEngine(
    `${rootFolder}/platform/code`,
    readFile(`${rootFolder}/platform/model.xml`),
    readJsonFromFile(`${rootFolder}/platform/config.json`),
    readFile(`${rootFolder}/platform/extra.js`),
    eval(readFile(`${rootFolder}/platform/transformation.js`)),
    false
  );
}

function generateProduct(output, productJson) {
  engine().generateProduct(path.resolve(rootFolder, output), productJson);
  return path.resolve(rootFolder, output);
}

export default generateProduct;
