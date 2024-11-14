lexer grammar BIDIGrammarLexer;

options {
  superClass = BIDIGrammarLexer;
}

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
// Any letter but without e/E and digits (which are used to match a decimal number).
fragment LETTER_WITHOUT_FLOAT_PART: [a-df-zA-DF-Z_$\u0080-\uffff];

fragment UNDERLINE_SYMBOL: '_';
fragment QUOTE_SYMBOL: '"';

ADD_SYMBOL: A D D;
ALTER_SYMBOL: A L T E R;
AS_SYMBOL: A S;
AUTHORIZATION_SYMBOL: A U T H O R I Z A T I O N;
BIDIRECTIONAL_SYMBOL: B I D I R E C T I O N A L;
CALL_SYMBOL: C A L L;
CASCADE_SYMBOL: C A S C A D E;
CONSTRAINT_SYMBOL: C O N S T R A I N T;
CREATE_SYMBOL: C R E A T E;
CURRENTUSER_SYMBOL: C U R R E N T UNDERLINE_SYMBOL U S E R;
DATA_SYMBOL: D A T A;
DBNAME_SYMBOL: D B N A M E;
DISPLAYSTRING_SYMBOL: D I S P L A Y UNDERLINE_SYMBOL S T R I N G;
DROP_SYMBOL: D R O P;
EDITABLE_SYMBOL: E D I T A B L E;
ENTITY_SYMBOL: E N T I T Y;
EXECUTE_SYMBOL: E X E C U T E;
EXISTS_SYMBOL: E X I S T S;
EXTENSION_SYMBOL: E X T E N S I O N;
FROM_SYMBOL: F R O M;
FOR_SYMBOL: F O R;
FOREIGN_SYMBOL: F O R E I G N;
GENERATE_SYMBOL: G E N E R A T E;
HIDDEN_SYMBOL: H I D D E N;
HOST_SYMBOL: H O S T;
IDENTIFIER_SYMBOL: I D E N T I F I E R;
IF_SYMBOL: I F;
IMPORT_SYMBOL: I M P O R T;
INSERT_SYMBOL: I N S E R T;
INTO_SYMBOL: I N T O;
KEY_SYMBOL: K E Y;
MAPPEDBY_SYMBOL: M A P P E D UNDERLINE_SYMBOL B Y;
MAPPING_SYMBOL: M A P P I N G;
NOT_SYMBOL: N O T;
NULL_SYMBOL: N U L L;
OLD_SYMBOL: O L D;
OPTIONS_SYMBOL: O P T I O N S;
PASSWORD_SYMBOL: P A S S W O R D;
PORT_SYMBOL: P O R T;
PRIMARY_SYMBOL: P R I M A R Y;
PROCEDURE_SYMBOL: P R O C E D U R E;
PUBLIC_SYMBOL: P U B L I C;
REFERENCES_SYMBOL: R E F E R E N C E S;
RELATIONSHIP_SYMBOL: R E L A T I O N S H I P;
REQUIRED_SYMBOL: R E Q U I R E D;
SCHEMA_SYMBOL: S C H E M A;
SELECT_SYMBOL: S E L E C T;
SERVER_SYMBOL: S E R V E R;
SET_SYMBOL: S E T;
STYLE_SYMBOL: S T Y L E;
TABLE_SYMBOL: T A B L E;
UNIQUE_SYMBOL: U N I Q U E;
UPDATE_SYMBOL: U P D A T E;
URL_SYMBOL: U R L;
USE_SYMBOL: U S E;
USER_SYMBOL: U S E R;
USING_SYMBOL: U S I N G;
WRAPPER_SYMBOL: W R A P P E R;

ZERO_ONE_SYMBOL: '0..1';
ONE_ONE_SYMBOL: '1..1';
ZERO_MANY_SYMBOL: '0..*';
ONE_MANY_SYMBOL: '1..*';

TYPE
  : L O N G
  | B O O L E A N
  | I N T E G E R
  | D O U B L E
  | L O C A L D A T E
  | S T R I N G
  | L I N E S T R I N G
  | M U L T I L I N E S T R I N G
  | P O L Y G O N
  | M U L T I P O L Y G O N
  | P O I N T
  | M U L T I P O I N T
;

POUND_SYMBOL : '#';
DOT_SYMBOL   : '.';
OPAR_SYMBOL  : '(';
CPAR_SYMBOL  : ')';
COMMA_SYMBOL : ',';
SCOL_SYMBOL  : ';';
SQUOTE_SYMBOL: '\'';
EQUAL_SYMBOL: '=';

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
;

QUOTED_TEXT: QUOTE_SYMBOL (~[\r\n"])* QUOTE_SYMBOL;
