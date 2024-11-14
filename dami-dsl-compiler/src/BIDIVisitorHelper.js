import fs from "fs";

export function writeFile(fileName, content, cb) {
  fs.writeFile(fileName, content, "utf-8", function(err) {
    if (err) {
      console.error(err);
    } else {
      console.log(`${fileName.split('.')[1]} file generated`);
      if (cb) cb();
    }
  });
}

export function transformation(spec) {
  _relationships(spec);

  return newSpec;
}

function _relationships(spec) {
  let source, target;

  spec.relationships.forEach(r => {
    source = spec.getEntity(r.source);
    target = spec.getEntity(r.target);
    let sourceOwner = targetOwner = false;
    let sourceMultiple = _multiple(r.sourceOpts.multiplicity);
    let targetMultiple = _multiple(r.targetOpts.multiplicity);
    if (sourceMultiple && !targetMultiple) {
      targetOwner = true;
    } else {
      sourceOwner = true;
    }

    source.properties.push({
      name: r.sourceOpts.label,
      class: target.name,
      owner: sourceOwner,
      bidirectional: r.targetOpts.label,
      multiple: sourceMultiple,
      required: _required(r.sourceOpts.multiplicity)
    });

    target.properties.push({
      name: r.targetOpts.label,
      class: source.name,
      owner: targetOwner,
      bidirectional: r.sourceOpts.label,
      multiple: targetMultiple,
      required: _required(r.targetOpts.multiplicity)
    });
  });
}

function _multiple(multiplicity) {
  return ["1..1", "0..1"].find(a => a == multiplicity) == null;
}

function _required(multiplicity) {
  return ["1..1", "1..*"].find(a => a == multiplicity) != null;
}

export function getPropertyParams(symbols) {
  if (!symbols.length) return null;

  const ret = {};
  if (symbols.includes("identifier")) {
    ret.pk = true;
  }
  if (symbols.includes("required")) {
    ret.required = true;
  }
  if (symbols.includes("unique")) {
    ret.unique = true;
  }
  if (symbols.includes("display_string")) {
    ret.displayString = true;
  }
  return ret;
}

export default {
  writeFile,
  transformation,
  getPropertyParams
};
