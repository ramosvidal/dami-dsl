import BIDIGrammarVisitor from "../lib/BIDIGrammarVisitor.js";
import BIDI from "./BIDI.js";
import {
  writeFile,
  transformation,
  getPropertyParams
} from "./BIDIVisitorHelper.js";
import generateProduct from "./project-generator.js";

class Visitor extends BIDIGrammarVisitor {
  constructor(store, script) {
    super();
    this.store = store;
    this.script = script;
    this.outputfile = '';
  }

  start(ctx, out) {
    if (out != undefined) {
      this.outputfile = out;
    } else {
      this.outputfile = 'script';
    }
    return this.visitParse(ctx);
  }

  visitParse(ctx) {
    console.log(`visitParse: ${ctx.getText()}`);
    super.visitParse(ctx);
  }

  visitCreateProduct(ctx) {
    const productName = ctx.getChild(1).getText();
    console.log(`visitCreateProduct: ${productName}`);
    if (this.store.getProduct(productName)) {
      throw `Product ${productName} already exists!`;
    }

    this.store.addProduct(productName, new BIDI(productName));
    
    console.log(`setCurrentProduct: ${productName}`);
    this.store.setCurrentProduct(productName);
  }

  visitUseProduct(ctx) {
    const productName = ctx.getChild(2).getText();
    console.log(`visitUseProduct: ${productName}`);
    this.store.setCurrentProduct(productName);
  }

  visitCreateConnectionFrom(ctx) {
    super.visitCreateConnectionFrom(ctx);
  }

  visitConnectionData(ctx) {
    const dbname = ctx.getChild(2).getText();
    const host = ctx.getChild(5).getText();
    const port = ctx.getChild(8).getText();
    const user = ctx.getChild(11).getText();
    const password = ctx.getChild(14).getText();
    const schema = ctx.getChild(17).getText();
    console.log(`visitCreateConnectionFrom: ${host}:${port}/${dbname} -u ${user}`);

    if (ctx.parentCtx.getChild(1).getText() == 'FROM') {
      this.store.getCurrentProduct().addConnectionFrom(dbname, host, port, user, password, schema);
      this.store.setCurrentConnection(dbname);
      this.store.getCurrentProduct().addSchema(schema);

      this.store.getCurrentConnection().validate();

      this.script.createConnectionFrom(dbname, host, port, user, password);
      this.script.importSchema(schema, schema, dbname);
      this.store.getCurrentConnection().originalSchema = schema;
      this.store.getCurrentConnection().update(this.store.getCurrentConnection());
    }

    if (ctx.parentCtx.getChild(1).getText() == 'TO') {
      this.store.getCurrentProduct().addConnectionTo(dbname, host, port, user, password, schema);
      this.store.getCurrentProduct().addSchema(schema);
      this.store.getCurrentProduct().addSchema('aux');
      this.script.createSchema(schema, user);
      this.script.createSchema('aux', user);
      const connection = this.store.getCurrentProduct().getConnection(dbname);
      connection.auxiliarSchema = 'aux';
      connection.update(connection);
    }

  }

  visitDropConnection(ctx) {
    const connection = this.store.getCurrentConnection();
    console.log(`visitDropConnection: ${connection.host}:${connection.port}/${connection.dbname}`);

    this.script.dropConnection(connection.dbname);
  }

  visitImportSchema(ctx){
    const ogName = ctx.getChild(2).getText();
    const auxName = ctx.getChild(4).getText();
    console.log(`visitImportSchema: import ${ogName} schema into ${auxName} schema`);
    const connection = this.store.getCurrentConnection();
    this.store.getCurrentProduct().addSchema(auxName);
    this.script.importSchema(ogName, auxName, connection.dbname);
    connection.originalSchema = auxName;
    this.store.getCurrentConnection().update(connection);
  }

  visitCreateSchema(ctx){
    const name = ctx.getChild(1).getText();
    console.log(`visitCreateSchema: creating schema ${name}`);
    this.store.getCurrentProduct().addSchema(name);
    if (ctx.getChildCount() > 2) {
      const user = ctx.getChild(3).getText();
      this.script.createSchema(name,user);
    } else {
      this.script.createSchema(name,null);
    }
    const connection = this.store.getCurrentConnection();
    connection.auxiliarSchema = name;
    this.store.getCurrentConnection().update(connection);
  }

  visitDropSchema(ctx) {
    const name = ctx.getChild(1).getText();
    console.log(`visitDropSchema: dropping schema ${name}`);
    this.script.dropSchema(name);
  }

  visitMapAllStatement(ctx) {
    const ogName = ctx.getChild(2).getText();
    const mapName = ctx.getChild(4).getText();
    console.log(`visitMapAllStatement: map ${ogName} to ${mapName}`);
    
    this.store.getCurrentProduct().addEntity(mapName);
    this.store.setCurrentEntity(mapName);
    const entity = this.store.getCurrentEntity();
    const connection = this.store.getCurrentConnection();

    super.visitMapAllStatement(ctx);

    this.script.mapAllTable(ogName, mapName, entity, connection);
    const aux = this.store.getCurrentConnection().auxiliarSchema;
    if (aux != null && this.store.getCurrentProduct().getSchema(aux).getEntity(mapName) != null) {
      const auxTable = this.store.getCurrentProduct().getSchema(aux).getEntity(mapName);
      this.script.linkAndCleanMapping(mapName, auxTable, connection);
    }
    this.script.dropEverything();

    this.store.setCurrentEntity(null);
  }

  visitMapSimpleStatement(ctx) {
    let ogName = '';
    let ogName2 = null;
    let ogName3 = null;
    let mapName = '';
    if (ctx.getChild(1).getText()!='TO'){
      if (ctx.getChild(3).getText()!='TO'){
        ogName = ctx.getChild(0).getText();
        ogName2 = ctx.getChild(2).getText();
        ogName3 = ctx.getChild(4).getText();
        mapName = ctx.getChild(6).getText();
        console.log(`visitMapSimpleStatement: map ${ogName}, ${ogName2}, ${ogName3} to ${mapName}`);
      } else {        
        ogName = ctx.getChild(0).getText();
        ogName2 = ctx.getChild(2).getText();
        mapName = ctx.getChild(4).getText();
        console.log(`visitMapSimpleStatement: map ${ogName}, ${ogName2} to ${mapName}`);
      }
    } else {
      ogName = ctx.getChild(0).getText();
      mapName = ctx.getChild(2).getText();
      console.log(`visitMapSimpleStatement: map ${ogName} to ${mapName}`);
    }
    
    this.store.getCurrentProduct().addEntity(mapName);
    this.store.setCurrentEntity(mapName);
    const entity = this.store.getCurrentEntity();
    const connection = this.store.getCurrentConnection();

    super.visitMapSimpleStatement(ctx);

    const where = ctx.children.filter(s => s.getText)
    .map(s => s.getText()).indexOf('WHERE');

    if (where!=-1) {
      let whereClause = ctx.children.slice(where);      
      const whereEnd = ctx.children.filter(s => s.getText)
      .map(s => s.getText()).indexOf(')',where);
      whereClause = ctx.children.slice(where,whereEnd);
      
      const joinA1 = ctx.getChild(where+2).getText();
      const joinB1 = ctx.getChild(where+4).getText();
      let joinA2 = null;
      let joinB2 = null;
      let joinA3 = null;
      let joinB3 = null;
      if (whereClause.length>5) {
        joinA2 = ctx.getChild(where+6).getText();
        joinB2 = ctx.getChild(where+8).getText();
      }
      if (whereClause.length>9) {
        joinA3 = ctx.getChild(where+10).getText();
        joinB3 = ctx.getChild(where+12).getText();
      }
      this.script.joinTable(joinA1,joinB1,joinA2,joinB2,joinA3,joinB3);
    }

    this.script.mapTable(ogName, ogName2, ogName3, mapName, entity, connection);
    const aux = this.store.getCurrentConnection().auxiliarSchema;
    if (aux != null && this.store.getCurrentProduct().getSchema(aux).getEntity(mapName) != null) {
      const auxTable = this.store.getCurrentProduct().getSchema(aux).getEntity(mapName);
      this.script.linkAndCleanMapping(mapName, auxTable, connection);
    }
    this.script.dropEverything();
    
    this.store.getCurrentEntity().emptyEntity();

    this.store.setCurrentEntity(null);
  }

  visitDecomposeStatement(ctx) {
    const originalTable = ctx.getChild(1).getText();
    const subtable1 = ctx.getChild(3).getText();
    const subtable2 = ctx.getChild(5).getText();

    console.log(`visitDecomposeStatement: ${originalTable} using ${subtable1} and ${subtable2}`);
    super.visitDecomposeStatement(ctx);

    this.script.dropEverything();
  }

  visitDecomposedTable(ctx) {
    const originalTable = ctx.parentCtx.getChild(1).getText();
    const subtable = ctx.getChild(1).getText();
    console.log(`visitDecomposedTable: from ${originalTable} to ${subtable}`);
    
    this.store.getCurrentProduct().addEntity(subtable);
    this.store.setCurrentEntity(subtable);
    const entity = this.store.getCurrentEntity();
    
    super.visitDecomposedTable(ctx);

    const connection = this.store.getCurrentConnection();

    this.script.mapTable(originalTable, subtable, entity, connection);
    const aux = this.store.getCurrentConnection().auxiliarSchema;
    if (aux != null && this.store.getCurrentProduct().getSchema(aux).getEntity(subtable) != null) {
      const auxTable = this.store.getCurrentProduct().getSchema(aux).getEntity(subtable);
      this.script.linkAndCleanMapping(subtable, auxTable, connection);
    }
    this.store.setCurrentEntity(null);
  }

  visitAttributeToTableStatement(ctx) {
    const ogTable = ctx.getChild(1).getText();
    const ogCol = ctx.getChild(3).getText();
    const newTable = ctx.getChild(7).getText();
    console.log(`visitAttributeToTableStatement: ${ogTable}(${ogCol}) to ${newTable}`);
    
    this.store.getCurrentProduct().addEntity(newTable);
    this.store.setCurrentEntity(newTable);
    const entity = this.store.getCurrentEntity();
    const connection = this.store.getCurrentConnection();

    super.visitMapSimpleStatement(ctx);

    this.script.mapTable(ogTable, newTable, entity, connection);

    this.store.setCurrentEntity(null);
  }

  visitColumnMapping(ctx) {
      const ogColName = ctx.getChild(0).getText().replace(/^SQL:|"+/g,'');
      const newColName = ctx.getChild(2).getText();
      console.log(`visitColumnMapping: map ${ogColName} to ${newColName}`);
      
      this.store.getCurrentEntity().addColumn(newColName);
      this.store.getCurrentEntity().addMapping(ogColName);

      super.visitColumnMapping(ctx);
  }

  visitSaveRelation(ctx) {
    let newTable = '';
    let newColumn = '';
    let newType = '';

    const originalTable = ctx.getChild(2).getText();
    const originalColumn = ctx.getChild(4).getText();
    const savedColumn = ctx.getChild(6).getText();
    const originalType = ctx.getChild(7).getText();
    console.log(`visitSaveRelation: ${originalTable}.${originalColumn} AS ${savedColumn} ${originalType}`);

    this.store.getCurrentEntity().addColumn(savedColumn);
    this.store.getCurrentEntity().addMappingOG(originalColumn,'true');

    if (ctx.getChildCount() > 7) {
       newTable = ctx.getChild(9).getText();
       newColumn = ctx.getChild(11).getText();
       newType = ctx.getChild(12).getText();
      // if (ctx.parentCtx.getChild(0).getText() == 'TABLE') {
        this.script.addColumnNow(newTable, savedColumn, originalType);
        this.script.dropColumnLater(newTable, savedColumn, originalType);
      // } else {
      //   this.script.saveRelation(newTable, savedColumn, originalType);
      // }
    }
    const aux = this.store.getCurrentConnection().auxiliarSchema;
    this.store.getCurrentProduct().getSchema(aux).addEntity(newTable);

    const newColName = `${newTable}_${newColumn}`;
    const auxTable = this.store.getCurrentProduct().getSchema(aux).getEntity(newTable);
    auxTable.addColumn(newColName);
    auxTable.addColumn(savedColumn);
    auxTable.addMapping(newColumn);
    auxTable.addMapping(savedColumn);

    const connection = this.store.getCurrentConnection();
    this.script.saveAuxRelation(savedColumn, originalType, newTable, newColName, newType, connection);
  }

  visitKeepingStatement(ctx) {
    const ogTable = ctx.getChild(2).getText();
    const ogProperty = ctx.getChild(4).getText();
    const ogType = ctx.getChild(5).getText();

    const newTable = ctx.getChild(7).getText();
    const newProperty = ctx.getChild(9).getText();
    const newType = ctx.getChild(10).getText();

    console.log(`visitKeepingStatement: maintain ${ogTable}.${ogProperty} ${ogType} = ${newTable}.${newProperty} ${newType}`);

    const aux = this.store.getCurrentConnection().auxiliarSchema;
    this.store.getCurrentProduct().getSchema(aux).addEntity(newTable);
    
    const auxTable = this.store.getCurrentProduct().getSchema(aux).getEntity(newTable);
    auxTable.addColumn(`${newTable}_${newProperty}`);
    auxTable.addColumn(`${ogTable}_${ogProperty}`);
    auxTable.addMapping(`${newProperty}`);
    auxTable.addMapping(`${ogTable}_${ogProperty}`);

    this.store.getCurrentEntity().addColumn(`${ogTable}_${ogProperty}`);
    this.store.getCurrentEntity().addMapping(ogProperty);

    const connection = this.store.getCurrentConnection();
    this.script.keepingStatement(ogTable, ogProperty, ogType, newTable, newProperty, newType, connection);
  }

  visitForeignKeyStatement(ctx) {
    const destColumn = ctx.parentCtx.getChild(2).getText();
    const destTable = ctx.parentCtx.parentCtx.getChild(3).getText();
    const originTable = ctx.getChild(2).getText();
    const originColumn = ctx.getChild(4).getText();
    console.log(`visitForeignKeyStatement: ${originTable}(${originColumn})`);

    this.script.foreignKey(destTable, destColumn, originTable, originColumn, true);
  }

  visitForeignKeyRelation(ctx) {
    const originTable = ctx.getChild(2).getText();
    const foreignAttr = ctx.getChild(4).getText();
    const referencedTable = ctx.getChild(6).getText();
    const referencedAttr = ctx.getChild(8).getText();
    console.log(`visitForeignKeyRelation: ${originTable}(${foreignAttr}) references ${referencedTable}(${referencedAttr})`);


    // const connection = this.store.getCurrentProduct().getEntity();
    // console.log(connection.auxiliarSchema);
    // if (connection.auxiliarSchema){
    //   this.script.updateReferenceWithAuxData(originTable, foreignAttr, connection.auxiliarSchema, referencedTable, referencedAttr);
    // }
    const mapps = this.store.getCurrentProduct().getEntity(referencedTable).getMappings();
    const dividedAttr = this.store.getCurrentProduct().getEntity(referencedTable).getColumnAtIndex(mapps.indexOf(referencedAttr));

    if (ctx.parentCtx.getChild(0).getText() == 'TABLE') {
      this.script.updateDecomposedRelation(originTable, foreignAttr, referencedTable, referencedAttr, dividedAttr);
    }
    if (ctx.parentCtx.getChild(0).getText() == 'ATTRIBUTE' || ctx.parentCtx.getChild(0).getText() == 'MAP') {
      const ogCols = this.store.getCurrentProduct().getEntity(originTable).getColumns();
      const auxCols = this.store.getCurrentProduct().getSchema('aux').getEntity(originTable).getColumns();
      const sharedCol = ogCols.filter(element => auxCols.indexOf(element) !== -1);
      this.script.updateParentTable(originTable, foreignAttr, referencedTable, referencedAttr, sharedCol);
    }
    
  }

  visitGetStatement(ctx) {
    const destTable = ctx.parentCtx.getChild(2).getText();
    const column = ctx.getChild(1).getText();
    const originSchema = ctx.getChild(3).getText();
    const originTable = ctx.getChild(5).getText();
    const originColumn = ctx.getChild(7).getText();    
    const refColumn = ctx.getChild(9).getText();
    this.script.updateReference(destTable, column, originSchema, originTable, originColumn, refColumn);
    console.log(`visitGetStatement: GET ${destTable}.${column} FROM ${originSchema}.${originTable}.${originColumn} when ${refColumn} `);
  }

  visitWhereStatement(ctx) {
    const originSchema = ctx.getChild(2).getText();
    const originTable = ctx.getChild(4).getText();
    const auxColumn = ctx.getChild(6).getText();
    const destTable = ctx.getChild(9).getText();
    const destColumn = ctx.getChild(11).getText();
    console.log(`visitWhereStatement: ${originSchema}.${originTable}(${auxColumn}) ${destTable}(${destColumn})`);

    this.script.whereStatement(originSchema, originTable, auxColumn, destTable, destColumn);
  }

  visitUpdateStatement(ctx) {
    const table = ctx.getChild(1).getText();
    console.log(`visitUpdateStatement: ${table}`);
    super.visitUpdateStatement(ctx);
  }

  visitInsertStatement(ctx) {
    const table = ctx.getChild(2).getText();
    const column = ctx.getChild(4).getText();

    const items=ctx.children.slice(6,7).filter(s => s.getText)
    .map(s => s.getText().replace(/^=/,'')).toString();
    let values = items.split(',');
    let finalvalues = []
    values.forEach(e => finalvalues.push('(\''+e+'\')'));
    this.script.insertValues(table,column,finalvalues);
  }

  visitForeignKeyUpdate(ctx) {
    const table = ctx.parentCtx.getChild(1).getText();
    const column = ctx.getChild(2).getText();
    const refTable = ctx.getChild(4).getText();
    const refAttr = ctx.getChild(6).getText();
    this.script.foreignKey(table, column, refTable, refAttr, false);
  }

  visitSetStatement(ctx) {    
    const table = ctx.parentCtx.getChild(1).getText();
    const attr = ctx.getChild(1).getText();
    console.log(`visitSetStatement: set ${attr}`);
    const selectedAttr = ctx.getChild(4).getText();
    const originTable = ctx.getChild(6).getText();
    const originJoin = ctx.getChild(8).getText();     
    const aux = ctx.getChild(10).getText();
    const auxTable = ctx.getChild(12).getText();
    const auxJoin = ctx.getChild(14).getText();
    const conditionAttribute = ctx.getChild(16).getText();
    const conditionTable = ctx.getChild(18).getText();
    const conditionDest = ctx.getChild(20).getText();
    this.script.updateTable(table, attr, selectedAttr, originTable, originJoin,
      aux, auxTable, auxJoin, conditionAttribute, conditionTable, conditionDest);
    
  }

  visitCreateEntity(ctx) {
    const entityName = ctx.getChild(1).getText();
    console.log(`visitCreateEntity: ${entityName}`);

    this.store.getCurrentProduct().addEntity(entityName);
    this.store.setCurrentEntity(entityName);

    super.visitCreateEntity(ctx);

    this.store.getCurrentEntity().validate();
    this.store.setCurrentEntity(null);
  }

  visitPropertyDefinition(ctx) {
    const pName = ctx.getChild(0).getText();
    console.log(`visitPropertyDefinition: ${pName}`);
    const pType = ctx.getChild(1).getText();

    this.store.getCurrentEntity().addProperty(
      pName,
      pType,
      getPropertyParams(
        ctx.children
          .slice(2)
          .filter(s => s.getSymbol)
          .map(s => s.getSymbol().text.toLowerCase())
      )
    );
  }

  visitOwnedRelationshipDefinition(ctx) {
    const sourceOpts = {
      label: ctx.getChild(0).getText(),
      multiplicity: ctx.getChild(6).getText()
    };
    const targetOpts = {
      label: null,
      multiplicity: ctx.getChild(4).getText()
    };
    const rSource = this.store.getCurrentEntity().name;
    const rTarget = ctx.getChild(1).getText();

    this.store
      .getCurrentProduct()
      .addRelationship(rSource, rTarget, sourceOpts, targetOpts);
  }

  visitMappedRelationshipDefinition(ctx) {
    const sourceOpts = {
      label: ctx.getChild(4).getText(),
      multiplicity: null
    };
    const targetOpts = {
      label: ctx.getChild(0).getText(),
      multiplicity: null
    };
    const rTarget = this.store.getCurrentEntity().name;
    const rSource = ctx.getChild(1).getText();

    this.store
      .getCurrentProduct()
      .addRelationship(rSource, rTarget, sourceOpts, targetOpts);
  }
  
  visitGenerateScript(ctx) {
    const productName = ctx.getChild(2).getText();
    console.log(`visitGenerateScript: ${productName}`);

    this.script.dropSchemas(this.store.getCurrentConnection().auxiliarSchema, this.store.getCurrentConnection().originalSchema);
    
    const product = this.store.getCurrentProduct();
    if (product.connectionFrom) {
      this.script.dropConnection(product.connectionFrom.dbname);
    }
    
    if (product.connectionTo) {
      this.script.dropConnection(product.connectionFrom.dbname);
    }
    this.store.setCurrentProduct(productName);
    this.store.getCurrentProduct().validate();
    writeFile(
      `tests/${this.outputfile}.json`,
      JSON.stringify(this.store.getCurrentProduct(), null, 2)
    );
    writeFile(`tests/${this.outputfile}.sql`, this.script.getScript());
    this.store.products = [];
  }

}

export default Visitor;
