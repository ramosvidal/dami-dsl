export class BIDI {
  constructor(name) {
    this.name = name;
    this.connectionFrom = {};
    this.connectionTo = {};
    this.schemas = [];
    this.entities = [];
    this.relationships = [];
    this.enums = [];
  }

  addEntity(name) {
    if (this.getEntity(name) == null) {
      this.entities.push(new Entity(name));
    }
  }

  getEntity(name) {
    return this.entities.find(e => e.name == name);
  }

  addConnectionFrom(dbname, host, port, user, password, schema) {
    if (this.connectionFrom.dbname == dbname && this.connectionFrom.host) {
      throw `Connection from database ${dbname} already exists!!!`;
    }
    this.connectionFrom = new Connection(dbname, host, port, user, password, schema);
  }

  addConnectionTo(dbname, host, port, user, password, schema) {
    if (this.connectionTo.dbname == dbname && this.connectionTo.host) {
      throw `Connection to database ${dbname} already exists!!!`;
    }
    this.connectionTo = new Connection(dbname, host, port, user, password, schema);
  }

  updateConnection(connection) {
    if (this.connectionFrom.name == connection.name) {
      this.connectionFrom.update(connection);  
    } else {
      this.connectionTo.update(connection);
    }
  }

  getConnection(name) {
    if (this.connectionTo.name == name) {
      return this.connectionTo;
    } else {
      return this.connectionFrom;
    }
  }

  addSchema(name) {
    if (this.getSchema(name)) {
      throw `Schema ${name} already exists!!!`;
    }
    this.schemas.push(new Schema(name));
  }

  getSchema(name) {
    return this.schemas.find(s => s.name == name);
  }

  addRelationship(source, target, sourceOpts, targetOpts) {
    const existingRelationship = this.getRelationship(
      source,
      target,
      sourceOpts.label
    );
    if (existingRelationship) {
      existingRelationship.update(sourceOpts, targetOpts);
    } else {
      this.relationships.push(
        new Relationship(source, target, sourceOpts, targetOpts)
      );
    }
  }

  getRelationship(source, target, sourceLabel) {
    return this.relationships.find(
      e =>
        e.source == source &&
        e.target == target &&
        e.sourceOpts.label == sourceLabel
    );
  }

  validate() {
    console.log(
      "Validar que el modelo de datos de la BIDI tenga sentido, es decir, que existan las entidades de las relaciones. No se puede hacer antes porque puedes definir una relación bidireccional y tienes que empezar por algún lado"
    );
  }

  toString() {
    return (
      `\nBIDI (${this.name} - ${this.entities.length} entities, ${this.relationships.length} relationships:\n\t` +
      `${this.entities.map(e => e.toString()).join("\n\t")}\n\n\t` +
      `${this.relationships.map(r => r.toString()).join("\n\t")}`
    );
  }
}

class Entity {
  constructor(name) {
    this.name = name;
    this.properties = [];
    this.columns = [];
    this.mappings = [];
  }

  addProperty(name, type, params) {
    if (this.getProperty(name)) {
      throw `Property ${name} already exists in entity ${this.name}!!!`;
    }
    this.properties.push(new Property(name, type, params));
  }

  getProperty(name) {
    return this.properties.find(p => p.name == name);
  }

  addColumn(name) {
    if (this.columns.some(c => c == name)) {
      console.log(`Column ${name} already exists in entity ${this.name}!!!`);
    } else this.columns.push(name);

  }

  getColumn(name) {
    return this.columns.find(c => c == name);
  }

  getColumns(){
    return this.columns;
  }

  getColumnAtIndex(index) {
    return this.columns[index];
  }

  addMapping(name) {
    if (this.mappings.some(m => m == name)) {
      console.log(`Mapping ${name} already exists in entity ${this.name}!!!`);
    } else this.mappings.push(name);
  }

  addMappingOG(name,og) {
    if (og==true) {
      this.mappings.push(name);
    } 
  }

  getMapping(name) {
    return this.mappings.find(m => m == name);
  }

  getMappings() {
    return this.mappings;
  }

  emptyEntity() {
    this.columns=[];
    this.mappings=[];
  }

  validate() {
    let pk = false;
    let displayString = false;
    this.properties.forEach(prop => {
      if (prop.pk) {
        if (pk) throw "ERROR: ya tiene una clave primaria";
        pk = true;
      }
      if (prop.displayString) {
        if (displayString) throw "ERROR: ya tiene un displayString";
        this.displayString = "$" + prop.name;
        delete prop.displayString;
        displayString = true;
      }
    });
  }

  toString() {
    return `Entity ${this.name}: ${this.properties
      .map(e => e.toString())
      .join(", ")}`;
  }
}

class Connection {
  constructor(dbname, host, port, user, password, schema) {    
    this.dbname = dbname;
    this.host = host;
    this.port = port;
    this.user = user;
    this.password = password;
    this.schema = schema;
    this.auxiliarSchema = null;
  }

  update(connection) {
    this.dbname = connection.dbname;    
    this.host = connection.host;
    this.port = connection.port;
    this.user = connection.user;
    this.password = connection.password;
    this.schema = connection.schema;
    this.auxiliarSchema = connection.auxiliarSchema;
  }

  validate() {
    console.log(`Connection ${this.dbname} valid!`);
  }

  toString() {
    return `Connection ${this.dbname}`;
  }
}

class Property {
  constructor(name, type, params) {
    this.name = name;
    this.class = type;
    if (params) {
      if (params.pk) {
        this.pk = true;
        this.required = true;
        this.unique = true;
        if (this.class == "Long") {
          this.class = "Long (autoinc)";
        }
      }
      if (params.required) {
        this.required = true;
      }
      if (params.unique) {
        this.unique = true;
      }
      if (params.displayString) {
        this.displayString = true;
      }
    }
  }

  toString() {
    return (
      this.name +
      ":" +
      this.class +
      (this.params ? "(" + Object.keys(this.params).join(", ") + ")" : "")
    );
  }
}

class Schema {
  constructor (name) {
    this.name = name;
    this.entities = [];
  }

  addEntity(name) {
    if (this.entities.some(e => e == name)) {
      throw `Column ${name} already exists in entity ${this.name}!!!`;
    }
    this.entities.push(new Entity(name));
  }

  getEntity(name) {
    return this.entities.find(e => e.name == name);
  }

  toString() {
    return `Schema ${this.name}: ${this.entities
      .map(e => e.toString())
      .join(", ")}`;
  }
}

class Relationship {
  constructor(source, target, sourceOpts, targetOpts) {
    this.source = source;
    this.target = target;
    this.sourceOpts = sourceOpts;
    this.targetOpts = targetOpts;
    if (!this.targetOpts.label) {
      this.targetOpts.label = this.source.toLowerCase();
      if (this.targetOpts.multiplicity.indexOf("*") != -1) {
        this.targetOpts.label += "s";
      }
    }
  }

  update(sourceOpts, targetOpts) {
    if (targetOpts.label) {
      this.targetOpts.label = targetOpts.label;
    }
    if (targetOpts.multiplicity) {
      this.targetOpts.multiplicity = targetOpts.multiplicity;
    }
    if (sourceOpts.multiplicity) {
      this.sourceOpts.multiplicity = sourceOpts.multiplicity;
    }
  }

  toString() {
    return (
      `${this.source}.${this.sourceOpts.label}(${this.sourceOpts.multiplicity})` +
      ` -> ${this.target}.${this.targetOpts.label}(${this.targetOpts.multiplicity})`
    );
  }
}

export default BIDI;
