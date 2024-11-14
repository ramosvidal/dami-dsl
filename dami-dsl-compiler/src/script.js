import BIDI from "./BIDI.js";

let script = ``;
let foreignScript = ``;
let updateScript = ``;
let joinScript = ``;
let addColumn = ``;
let dropColumn = ``;

function getScript() {
    return script;
}

function createConnectionFrom(dbname, host, port, user, password) {
    script = script + `
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER ${dbname}_database_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '${host}', dbname '${dbname}', port '${port}');

CREATE USER MAPPING FOR CURRENT_USER SERVER ${dbname}_database_server OPTIONS (user '${user}', password '${password}');
`;
}

function dropConnection(dbname) {
    script = script + `
DROP SERVER ${dbname}_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;
`;
}

function importSchema(schema,ogName, dbname) {
    script = script + `
CREATE SCHEMA ${schema};

IMPORT FOREIGN SCHEMA ${ogName} FROM SERVER ${dbname}_database_server INTO ${schema};
`;
}

function createSchema(name, user) {
    if (user) {
        script = script + `
CREATE SCHEMA IF NOT EXISTS ${name} AUTHORIZATION ${user}; 
        `;
    } else {
        script = script + `
CREATE SCHEMA IF NOT EXISTS ${name}; 
        `;
    }
}

function dropSchemas(aux,origin) {
    script = script + `
DROP SCHEMA ${aux} CASCADE;
DROP SCHEMA ${origin} CASCADE;
`;
}
function dropSchema(name) {
    script = script + `
DROP SCHEMA ${name} CASCADE;
`;
}

function dropEverything() {
    if (dropColumn!=``){
        script = script + dropColumn;
        dropColumn = ``;
    };
}

function joinTable(joinA1,joinB1,joinA2,joinB2,joinA3,joinB3) {
    joinScript = ` WHERE ${joinA1}=${joinB1}`
    if (joinA2!=null) {
        joinScript = joinScript+` AND ${joinA2}=${joinB2}`
    } 
    if (joinA3!=null) {
        joinScript= joinScript+` AND ${joinA3}=${joinB3}`
    }
}

function mapTable(ogName, ogName2, ogName3, mapName, entity, connection) {
    if (addColumn!=``){
        script = script + addColumn;
        addColumn = ``;
    }
    if (ogName2 != null) {
        if (ogName3!=null) {
            script = script + `
INSERT INTO target.${mapName}(${entity.columns})
    SELECT ${entity.mappings}
FROM ${connection.originalSchema}.${ogName}, ${connection.originalSchema}.${ogName2}, ${connection.originalSchema}.${ogName3}`;
        } else {
        script = script + `
INSERT INTO target.${mapName}(${entity.columns})
    SELECT ${entity.mappings}
FROM ${connection.originalSchema}.${ogName}, ${connection.originalSchema}.${ogName2}`;
        }
    } else {
        script = script + `
INSERT INTO target.${mapName}(${entity.columns})
    SELECT ${entity.mappings}
FROM ${connection.originalSchema}.${ogName}`;
    }
    
    if (joinScript!=``){
        script = script + joinScript;
        joinScript = ``;
    }

    script = script + `;
    `;

    if (updateScript!=``){
        script = script + updateScript;
        updateScript = ``;
    }

    if (foreignScript!=``) {
        script = script + foreignScript;
        foreignScript = ``;
    }
}

function mapAllTable(ogName, mapName, entity, connection) {
    if (addColumn!=``){
        script = script + addColumn;
        addColumn = ``;
    }
    script = script + `
INSERT INTO target.${mapName}
    SELECT *
FROM ${connection.originalSchema}.${ogName};
    `;

    if (updateScript!=``){
        script = script + updateScript;
        updateScript = ``;
    }

    if (foreignScript!=``) {
        script = script + foreignScript;
        foreignScript = ``;
    }
}

function keepingStatement(ogTable, ogProperty, ogType, newTable, newProperty, newType, connection) {
    script = script + `
ALTER TABLE target.${newTable} ADD ${ogTable}_${ogProperty} ${ogType}; 

CREATE TABLE IF NOT EXISTS ${connection.auxiliarSchema}.${newTable}(
    ${newTable}_${newProperty} ${newType},
    ${ogTable}_${ogProperty} ${ogType}
);
`;
}

function saveAuxRelation(savedColumn, ogType, newTable, newColumn, newType, connection) {
    script = script + `
CREATE TABLE IF NOT EXISTS ${connection.auxiliarSchema}.${newTable}(
    ${newColumn} ${newType},
    ${savedColumn} ${ogType}
);
`;
}

function linkAndCleanMapping(newTable, aux, connection) {
    script = script + `
INSERT INTO ${connection.auxiliarSchema}.${newTable}(${aux.columns}) 
    SELECT ${aux.mappings}
FROM target.${newTable};
`;
}

function whereStatement(originSchema, originTable, auxColumn, destTable, destColumn) {
    script = script + `
UPDATE target.${destTable} SET ${destColumn} = (
    SELECT ${auxColumn} FROM ${originSchema}.${originTable} t WHERE t.${auxColumn} = ${destTable}.${destColumn}
);
`;
}

function foreignKey(destTable, destColumn, originTable, originColumn, save){
    if (save) {
    foreignScript = `
ALTER TABLE target.${destTable} ADD FOREIGN KEY (${destColumn}) REFERENCES target.${originTable}(${originColumn});
`;
    } else {
    script = script + `
ALTER TABLE target.${destTable} ADD FOREIGN KEY (${destColumn}) REFERENCES target.${originTable}(${originColumn});
`;    
    }
}

function updateReferenceWithAuxData(originTable, foreignAttr, auxiliarSchema, referencedTable, referencedAttr) {
    updateScript = updateScript + `
UPDATE target.${originTable} SET ${foreignAttr} = (
    SELECT ${referencedAttr} FROM target.${originTable} t WHERE);
`;
}

function updateDecomposedRelation(destTable, foreignAttr, referencedTable, referencedAttr, dividedAttr) {
    script = script + `
UPDATE target.${destTable} 
    SET ${foreignAttr} = (SELECT ${referencedAttr} FROM target.${referencedTable} t WHERE t.${dividedAttr} = ${destTable}.${dividedAttr});
`;
}

function updateReference(destTable, column, originSchema, originTable, originColumn, refColumn) {
    script = script + `
UPDATE target.${destTable} SET ${column} = (
    SELECT ${column} FROM ${originSchema}.${originTable} t WHERE t.${originColumn} = ${destTable}.${refColumn});
`;
}

function updateParentTable(originTable, foreignAttr, referencedTable, referencedAttr, sharedCol){
    updateScript = updateScript + `
UPDATE target.${originTable} SET ${foreignAttr} = ( SELECT ${referencedAttr} FROM ${referencedTable} a JOIN aux.${originTable} b ON a.${sharedCol} = b.${sharedCol} WHERE b.${originTable}_${referencedAttr} = ${originTable}.${referencedAttr});
    `;
}

function saveRelation(table, column, type) {
    addColumn = addColumn + `
ALTER TABLE target.${table} ADD ${column} ${type};
`;
    dropColumn = dropColumn + `
ALTER TABLE target.${table} DROP ${column};
`;
}

function addColumnNow(table, column, type) {
    script = script + `
ALTER TABLE target.${table} ADD ${column} ${type};
`;
}

function dropColumnLater(table, column, type) {
    dropColumn = dropColumn + `
ALTER TABLE target.${table} DROP ${column};
`;
}

function updateTable(table, attr, selectedAttr, originTable, originJoin,
    aux, auxTable, auxJoin, conditionAttribute, conditionTable, conditionDest) {
    script = script + `
UPDATE target.${table} 
    SET ${attr} = (SELECT ${selectedAttr} FROM target.${originTable} a JOIN ${aux}.${auxTable} b ON a.${originJoin}=b.${auxJoin} WHERE b.${conditionAttribute} = ${conditionTable}.${conditionDest});
`;
    }

function insertValues(table,column,values) {
    script = script + `
INSERT INTO ${table}.${column} values ${values};
`;
}

export default {
    createConnectionFrom,
    dropConnection,
    importSchema,
    createSchema,
    dropSchemas,
    dropSchema,
    dropEverything,
    joinTable,
    keepingStatement,
    linkAndCleanMapping,
    mapTable,
    mapAllTable,
    whereStatement,
    foreignKey,
    updateReference,
    updateReferenceWithAuxData,
    updateDecomposedRelation,
    updateParentTable,
    saveRelation,
    saveAuxRelation,
    addColumnNow,
    dropColumnLater,
    updateTable,
    insertValues,
    getScript
};