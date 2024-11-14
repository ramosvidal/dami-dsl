parser grammar BIDIGrammarParser;

options {
  superClass = BIDIGrammarBaseRecognizer;
  tokenVocab = BIDIGrammarLexer;
}

parse
  : sentence+
;

sentence
  : alterStatement
  | createStatement
  | importSchema
  | insertStatement
  | updateStatement
;

alterStatement:
 ALTER_SYMBOL TABLE_SYMBOL identifier (
   addColumn
   | addConstraint
   | addForeignKey
   | dropColumn
 )
;

createStatement:
  CREATE_SYMBOL (
    createEntity
    | createExtension
    | createSchema
    | createServer
    | createUserMapping
  )
;

dropStatement:
  DROP_SYMBOL (
    dropExtension
    | dropSchema
    | dropServer
    | dropTable
  )
;

insertStatement:
  INSERT_SYMBOL INTO_SYMBOL identifier 
    OPAR_SYMBOL identifier (COMMA_SYMBOL identifier)* CPAR_SYMBOL
    (selectStatement) SCOL_SYMBOL
;

updateStatement:
  UPDATE_SYMBOL identifier SET_SYMBOL column EQUAL_SYMBOL 
    OPAR_SYMBOL (selectStatement) CPAR_SYMBOL SCOL_SYMBOL
;

addColumn: 
  ADD_SYMBOL property SCOL_SYMBOL 
;

addConstraint:
  ADD_SYMBOL CONSTRAINT_SYMBOL identifier 
;

addForeignKey:
  ADD_SYMBOL FOREIGN_SYMBOL KEY_SYMBOL OPAR_SYMBOL identifier CPAR_SYMBOL
    REFERENCES_SYMBOL identifier SCOL_SYMBOL
;

createEntity:
  ENTITY_SYMBOL identifier OPAR_SYMBOL
	  property (COMMA_SYMBOL property)*
  CPAR_SYMBOL SCOL_SYMBOL
;

createExtension: 
  EXTENSION_SYMBOL IF_SYMBOL NOT_SYMBOL EXISTS_SYMBOL identifier
;

createSchema: 
  SCHEMA_SYMBOL (IF_SYMBOL NOT_SYMBOL EXISTS_SYMBOL)? identifier 
    (AUTHORIZATION_SYMBOL identifier) SCOL_SYMBOL
;

createServer:
  SERVER_SYMBOL identifier
    FOREIGN_SYMBOL DATA_SYMBOL WRAPPER_SYMBOL identifier
    OPTIONS_SYMBOL OPAR_SYMBOL HOST_SYMBOL SQUOTE_SYMBOL identifier SQUOTE_SYMBOL 
      COMMA_SYMBOL DBNAME_SYMBOL SQUOTE_SYMBOL identifier SQUOTE_SYMBOL 
      COMMA_SYMBOL PORT_SYMBOL SQUOTE_SYMBOL identifier SQUOTE_SYMBOL 
      CPAR_SYMBOL SCOL_SYMBOL
;

createTable:
  TABLE_SYMBOL IF_SYMBOL NOT_SYMBOL EXISTS_SYMBOL identifier
    OPAR_SYMBOL property (COMMA_SYMBOL property)* CPAR_SYMBOL SCOL_SYMBOL
;

createUserMapping:
  USER_SYMBOL MAPPING_SYMBOL FOR_SYMBOL CURRENTUSER_SYMBOL SERVER_SYMBOL identifier
    OPTIONS_SYMBOL OPAR_SYMBOL USER_SYMBOL SQUOTE_SYMBOL identifier SQUOTE_SYMBOL 
      COMMA_SYMBOL PASSWORD_SYMBOL SQUOTE_SYMBOL identifier SQUOTE_SYMBOL CPAR_SYMBOL SCOL_SYMBOL
;

dropColumn:
  DROP_SYMBOL identifier SCOL_SYMBOL
;

dropExtension:
  EXTENSION_SYMBOL identifier CASCADE_SYMBOL SCOL_SYMBOL
;

dropSchema:
  SCHEMA_SYMBOL identifier CASCADE_SYMBOL SCOL_SYMBOL
;

dropServer:
  SERVER_SYMBOL identifier CASCADE_SYMBOL SCOL_SYMBOL
;

dropTable:
  TABLE_SYMBOL IF_SYMBOL EXISTS_SYMBOL identifier CASCADE_SYMBOL SCOL_SYMBOL
;

importSchema:
  IMPORT_SYMBOL FOREIGN_SYMBOL SCHEMA_SYMBOL PUBLIC_SYMBOL
    FROM_SYMBOL SERVER_SYMBOL identifier INTO_SYMBOL OLD_SYMBOL SCOL_SYMBOL
;

selectStatement:
  SELECT_SYMBOL column (COMMA_SYMBOL column)*
  FROM_SYMBOL identifier
;

column: 
  identifier
;

property: propertyDefinition | relationshipDefinition;

propertyDefinition:
  identifier TYPE (
    IDENTIFIER_SYMBOL
    | DISPLAYSTRING_SYMBOL
    | REQUIRED_SYMBOL
    | UNIQUE_SYMBOL
    | NOT_SYMBOL NULL_SYMBOL
  )*
;

relationshipDefinition:
	ownedRelationshipDefinition | mappedRelationshipDefinition;

mappedRelationshipDefinition:
  identifier identifier RELATIONSHIP_SYMBOL MAPPEDBY_SYMBOL identifier;

ownedRelationshipDefinition:
	identifier identifier RELATIONSHIP_SYMBOL OPAR_SYMBOL cardinality COMMA_SYMBOL cardinality
		CPAR_SYMBOL BIDIRECTIONAL_SYMBOL?;

cardinality:
  ZERO_ONE_SYMBOL
  | ONE_ONE_SYMBOL
  | ZERO_MANY_SYMBOL
  | ONE_MANY_SYMBOL
;
srid: INT_NUMBER;
identifier: IDENTIFIER;
text: QUOTED_TEXT;

hexColor: HEX_COLOR;
floatNumber: FLOAT_NUMBER;