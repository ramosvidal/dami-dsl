grammar BIDIGrammar;

parse
  : sentence+
;

sentence
  : alterStatement
  | attributeToTableStatement
  | createStatement
  | dropStatement
  | generateScript
  | mapStatement
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
    createProduct
    | createConnectionTo
    | createConnectionFrom
    | createEntity
    | createSchema
  )
;

dropStatement:
  DROP_SYMBOL (
    dropConnection
    | dropSchema
    | dropTable
  )
;

generateScript:
  GENERATE_SYMBOL SCRIPT_SYMBOL identifier SCOL_SYMBOL
;

insertStatement:
  INSERT_SYMBOL INTO_SYMBOL identifier 
    OPAR_SYMBOL identifier (COMMA_SYMBOL identifier)* CPAR_SYMBOL
    (valueStatement | selectStatement) SCOL_SYMBOL
;

valueStatement:
  EQUAL_SYMBOL value (COMMA_SYMBOL value)*?
;

mapStatement:
  MAP_SYMBOL (
    mapAllStatement
    | mapSimpleStatement
  )
;

mapAllStatement: 
  ALL_SYMBOL PROPERTIES_SYMBOL identifier TO_SYMBOL identifier 
  (OPAR_SYMBOL
    columnMapping (COMMA_SYMBOL (columnMapping | saveRelation))* CPAR_SYMBOL 
    (foreignKeyRelation(COMMA_SYMBOL foreignKeyRelation)*)?
    (getStatement)?
    )?
  SCOL_SYMBOL
;

mapSimpleStatement: 
  identifier (COMMA_SYMBOL identifier)*? TO_SYMBOL identifier OPAR_SYMBOL
    columnMapping (COMMA_SYMBOL (columnMapping | saveRelation))* CPAR_SYMBOL 
    (WHERE_SYMBOL OPAR_SYMBOL identifier EQUAL_SYMBOL identifier (AND_SYMBOL identifier EQUAL_SYMBOL identifier)*? CPAR_SYMBOL)?
    (foreignKeyRelation(COMMA_SYMBOL foreignKeyRelation)*)?
    (getStatement)?
  SCOL_SYMBOL
;

columnMapping:
(identifier | NULL_SYMBOL | sqlStatement) (TYPE)? TO_SYMBOL identifier (foreignKeyStatement)?
;

sqlStatement:
  SQL_SYMBOL COL_SYMBOL QUOTED_TEXT 
;

saveRelation:
  SAVE_SYMBOL RELATION_SYMBOL identifier DOT_SYMBOL identifier AS_SYMBOL identifier TYPE (EQUALS_SYMBOL identifier DOT_SYMBOL identifier TYPE)
;

keepingStatement: 
  KEEPING_SYMBOL OPAR_SYMBOL identifier DOT_SYMBOL identifier TYPE EQUAL_SYMBOL identifier DOT_SYMBOL identifier TYPE CPAR_SYMBOL
;

foreignKeyStatement: 
  FOREIGN_SYMBOL KEY_SYMBOL identifier OPAR_SYMBOL identifier CPAR_SYMBOL
;

foreignKeyRelation:
  FOREIGN_SYMBOL KEY_SYMBOL identifier DOT_SYMBOL identifier REFERENCES_SYMBOL identifier DOT_SYMBOL identifier
;

getStatement:
  GET_SYMBOL identifier FROM_SYMBOL identifier DOT_SYMBOL identifier WHEN_SYMBOL identifier EQUAL_SYMBOL identifier
;

attributeToTableStatement:
  ATTRIBUTE_SYMBOL identifier OPAR_SYMBOL identifier CPAR_SYMBOL TO_SYMBOL TABLE_SYMBOL identifier OPAR_SYMBOL
    columnMapping (COMMA_SYMBOL (columnMapping | saveRelation))* CPAR_SYMBOL foreignKeyRelation SCOL_SYMBOL
;

updateStatement:
  UPDATE_SYMBOL identifier (setStatement | foreignKeyUpdate) SCOL_SYMBOL
;

setStatement:
  SET_SYMBOL column EQUAL_SYMBOL 
    OPAR_SYMBOL identifier (COMMA_SYMBOL identifier)* 
  FROM_SYMBOL identifier(DOT_SYMBOL identifier EQUAL_SYMBOL identifier DOT_SYMBOL identifier DOT_SYMBOL IDENTIFIER)?
  (WHERE_SYMBOL identifier EQUAL_SYMBOL identifier DOT_SYMBOL identifier)? CPAR_SYMBOL
;

foreignKeyUpdate:
 FOREIGN_SYMBOL KEY_SYMBOL identifier REFERENCES_SYMBOL identifier OPAR_SYMBOL identifier CPAR_SYMBOL
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

createProduct:
  PRODUCT_SYMBOL identifier SCOL_SYMBOL
;

createConnectionTo: 
  CONNECTION_SYMBOL TO_SYMBOL connectionData SCOL_SYMBOL
;

createConnectionFrom: 
  CONNECTION_SYMBOL FROM_SYMBOL connectionData SCOL_SYMBOL
;

connectionData: 
  OPAR_SYMBOL DBNAME_SYMBOL identifier COMMA_SYMBOL 
      HOST_SYMBOL identifier COMMA_SYMBOL 
      PORT_SYMBOL INT_NUMBER COMMA_SYMBOL 
      USER_SYMBOL identifier COMMA_SYMBOL 
      PASSWORD_SYMBOL identifier COMMA_SYMBOL
      SCHEMA_SYMBOL identifier CPAR_SYMBOL
;

createEntity:
  ENTITY_SYMBOL identifier OPAR_SYMBOL
	  property (COMMA_SYMBOL property)*
  CPAR_SYMBOL SCOL_SYMBOL
;

createSchema: 
  SCHEMA_SYMBOL identifier 
    (AUTHORIZATION_SYMBOL identifier)? SCOL_SYMBOL
;

dropColumn:
  DROP_SYMBOL identifier SCOL_SYMBOL
;

dropConnection:
  CONNECTION_SYMBOL SCOL_SYMBOL
;

dropSchema:
  SCHEMA_SYMBOL identifier SCOL_SYMBOL
;

dropTable:
  TABLE_SYMBOL identifier SCOL_SYMBOL
;

selectStatement:
  SELECT_SYMBOL identifier (COMMA_SYMBOL identifier)* 
  FROM_SYMBOL identifier(DOT_SYMBOL identifier EQUAL_SYMBOL identifier DOT_SYMBOL identifier DOT_SYMBOL IDENTIFIER)?
  (WHERE_SYMBOL identifier EQUAL_SYMBOL identifier DOT_SYMBOL identifier)?
;

column: 
  identifier
;
value: identifier;

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
host_identifier: HOST_IDENTIFIER;
password: STRING_LITERAL STRING_LITERAL*?;
text: QUOTED_TEXT;

hexColor: HEX_COLOR;
floatNumber: FLOAT_NUMBER;


//-----------------------------------------------------------------------


fragment A: [aA];
fragment B: [bB];
fragment C: [cC];
fragment D: [dD];
fragment E: [eE];
fragment F: [fF];
fragment G: [gG];
fragment H: [hH];
fragment I: [iI];
fragment J: [jJ];
fragment K: [kK];
fragment L: [lL];
fragment M: [mM];
fragment N: [nN];
fragment O: [oO];
fragment P: [pP];
fragment Q: [qQ];
fragment R: [rR];
fragment S: [sS];
fragment T: [tT];
fragment U: [uU];
fragment V: [vV];
fragment W: [wW];
fragment X: [xX];
fragment Y: [yY];
fragment Z: [zZ];

fragment DIGIT:    [0-9];
fragment DIGITS:   DIGIT+;
fragment HEXDIGIT: [0-9a-fA-F];

fragment LETTER_WHEN_UNQUOTED_NO_DIGIT: [a-zA-Z_$\u0080-\uffff];
fragment LETTER_WHEN_UNQUOTED: DIGIT | LETTER_WHEN_UNQUOTED_NO_DIGIT;
fragment LETTER_WHEN_QUOTED: SQUOTE_SYMBOL LETTER_WHEN_UNQUOTED SQUOTE_SYMBOL;
// Any letter but without e/E and digits (which are used to match a decimal number).
fragment LETTER_WITHOUT_FLOAT_PART: [a-df-zA-DF-Z_$\u0080-\uffff];

fragment UNDERLINE_SYMBOL: '_';
fragment QUOTE_SYMBOL: '"';

ADD_SYMBOL: A D D;
ALL_SYMBOL: A L L;
ALTER_SYMBOL: A L T E R;
AND_SYMBOL: A N D;
AS_SYMBOL: A S;
ATTRIBUTE_SYMBOL: A T T R I B U T E;
AUTHORIZATION_SYMBOL: A U T H O R I Z A T I O N;
BIDI_SYMBOL: B I D I;
BIDIRECTIONAL_SYMBOL: B I D I R E C T I O N A L;
CALL_SYMBOL: C A L L;
CASCADE_SYMBOL: C A S C A D E;
CONNECTION_SYMBOL: C O N N E C T I O N;
CONSTRAINT_SYMBOL: C O N S T R A I N T;
CREATE_SYMBOL: C R E A T E;
CURRENTUSER_SYMBOL: C U R R E N T UNDERLINE_SYMBOL U S E R;
DATA_SYMBOL: D A T A;
DBNAME_SYMBOL: D B N A M E;
DECOMPOSE_SYMBOL: D E C O M P O S E;
DISPLAYSTRING_SYMBOL: D I S P L A Y UNDERLINE_SYMBOL S T R I N G;
DROP_SYMBOL: D R O P;
EDITABLE_SYMBOL: E D I T A B L E;
ENTITY_SYMBOL: E N T I T Y;
EQUALS_SYMBOL: E Q U A L S;
EXECUTE_SYMBOL: E X E C U T E;
EXISTS_SYMBOL: E X I S T S;
EXTENSION_SYMBOL: E X T E N S I O N;
FROM_SYMBOL: F R O M;
FOR_SYMBOL: F O R;
FOREIGN_SYMBOL: F O R E I G N;
GENERATE_SYMBOL: G E N E R A T E;
GET_SYMBOL: G E T;
HIDDEN_SYMBOL: H I D D E N;
HOST_SYMBOL: H O S T;
IDENTIFIER_SYMBOL: I D E N T I F I E R;
IF_SYMBOL: I F;
IMPORT_SYMBOL: I M P O R T;
INSERT_SYMBOL: I N S E R T;
INTO_SYMBOL: I N T O;
KEEPING_SYMBOL: K E E P I N G;
KEY_SYMBOL: K E Y;
MAP_SYMBOL: M A P;
MAPPEDBY_SYMBOL: M A P P E D UNDERLINE_SYMBOL B Y;
MAPPING_SYMBOL: M A P P I N G;
NEW_SYMBOL: N E W;
NOT_SYMBOL: N O T;
NULL_SYMBOL: N U L L;
OPTIONS_SYMBOL: O P T I O N S;
PASSWORD_SYMBOL: P W D;
PORT_SYMBOL: P O R T;
PRIMARY_SYMBOL: P R I M A R Y;
PROCEDURE_SYMBOL: P R O C E D U R E;
PRODUCT_SYMBOL: P R O D U C T;
PROPERTIES_SYMBOL: P R O P E R T I E S;
REFERENCES_SYMBOL: R E F E R E N C E S;
RELATION_SYMBOL: R E L A T I O N;
RELATIONSHIP_SYMBOL: R E L A T I O N S H I P;
REQUIRED_SYMBOL: R E Q U I R E D;
SAVE_SYMBOL: S A V E;
SCHEMA_SYMBOL: S C H E M A;
SCRIPT_SYMBOL: S C R I P T;
SELECT_SYMBOL: S E L E C T;
SERVER_SYMBOL: S E R V E R;
SET_SYMBOL: S E T;
STYLE_SYMBOL: S T Y L E;
SQL_SYMBOL: S Q L;
TABLE_SYMBOL: T A B L E;
TO_SYMBOL: T O;
UNIQUE_SYMBOL: U N I Q U E;
UPDATE_SYMBOL: U P D A T E;
URL_SYMBOL: U R L;
USE_SYMBOL: U S E;
USER_SYMBOL: U S E R;
USING_SYMBOL: U S I N G;
VALUES_SYMBOL: V A L U E S;
WHEN_SYMBOL: W H E N;
WHERE_SYMBOL: W H E R E;
WITH_SYMBOL: W I T H;
WRAPPER_SYMBOL: W R A P P E R;

ZERO_ONE_SYMBOL: '0..1';
ONE_ONE_SYMBOL: '1..1';
ZERO_MANY_SYMBOL: '0..*';
ONE_MANY_SYMBOL: '1..*';

TYPE
  : B I G I N T
  | B I N A R Y OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | B O O L E A N
  | C H A R OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | C H A R A C T E R OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | C H A R A C T E R V A R Y I N G OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | D A T E 
  | D A T E T I M E
  | D E C I M A L
  | D O U B L E
  | F L O A T
  | I N T
  | I N T E G E R
  | L O C A L D A T E
  | L O N G
  | P O I N T
  | P O L Y G O N
  | S T R I N G
  | T E X T OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | T I M E
  | T I M E S T A M P
  | V A R C H A R OPAR_SYMBOL INT_NUMBER CPAR_SYMBOL
  | Y E A R
;

POUND_SYMBOL : '#';
DOT_SYMBOL   : '.';
OPAR_SYMBOL  : '(';
CPAR_SYMBOL  : ')';
COMMA_SYMBOL : ',';
SCOL_SYMBOL  : ';';
COL_SYMBOL: ':';
SQUOTE_SYMBOL: '\'';
EQUAL_SYMBOL: '=';
HYPHEN_SYMBOL: '-';

HEX_COLOR: POUND_SYMBOL HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT HEXDIGIT;
INT_NUMBER: DIGITS;
FLOAT_NUMBER: (DIGITS? DOT_SYMBOL)? DIGITS;

COMMENT: '//' ~[\r\n]* -> skip;
//SPACE: [ \t]+ -> skip;
//EOFS: [\r\n] -> skip;
WHITESPACE: [ \t\f\r\n] -> channel(HIDDEN); // Ignore whitespaces.

IDENTIFIER:
    DIGITS+ [eE] (LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED*)? // Have to exclude float pattern, as this rule matches more.    
    | DIGITS+ LETTER_WITHOUT_FLOAT_PART LETTER_WHEN_UNQUOTED*
    | LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED* // INT_NUMBER matches first if there are only digits.
    | '\''LETTER_WHEN_UNQUOTED_NO_DIGIT LETTER_WHEN_UNQUOTED*'\'' 
;


fragment ID_NODE: [a-zA-Z_][a-zA-Z0-9]*;

HOST_IDENTIFIER: ID_NODE ('.' ID_NODE)*?;

STRING_LITERAL: 'a'..'z' | 'A'..'Z' | '0'..'9' | COL_SYMBOL | DOT_SYMBOL | '&' | '/' | '\\' | SCOL_SYMBOL | '+' | '$' | '%' | '@' | '|' | '¿' | '?';

QUOTED_TEXT: QUOTE_SYMBOL (~[\r\n"])* QUOTE_SYMBOL;
