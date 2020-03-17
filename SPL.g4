grammar SPL;

AND: 'AND' | '&''&';
OR:  'OR' | '|''|';
NOT: 'NOT' | '!';
XOR: 'XOR';

BY: 'BY' | 'by';
AS: 'AS' | 'as';

IF: 'IF' | 'if';
CASE: 'CASE' | 'case';

TRUE: 'true' | 't';
FALSE: 'false' | 'f';

SED: 'sed' | 'SED';

FROM: 'from'|'FROM';
WHERE: 'where'|'WHERE';

LPAR: '(';
RPAR: ')';
EQ: '=';
DOUBLE_EQ: '==';
NEQ: '!=';
LESS: '<';
LESS_EQ: '=<';
GREATER: '>';
GREATER_EQ:'>=';

convert_function
  : 'auto'
  | 'ctime'
  | 'dur2sec'
  | 'memk'
  | 'mktime'
  | 'mstime'
  | 'none'
  | 'num'
  | 'rmcomma'
  | 'rmunit'
  ;

aggregation_function
 : 'avg'
 | 'count'
 | 'dc'
 | 'distinct_count'
 | 'earliest'
 | 'eval'
 | 'latest'
 | 'sum'
 | 'list'
 | 'max'
 | 'min'
 | 'sum'
 | 'std'
 | 'stddev'
 | 'stdev'
 | 'stddev_pop'
 | 'stddev_samp'
 | 'values'
 | 'var_pop'
 | 'var_samp'
 | 'variance'
 ;

reserved_keywords
  : 'type'
  | 'stats'
  | 'tstats'
  | 'rename'
  | 'eval'
  | WHERE
  | 'fields'
  | 'mvcombine'
  | 'join'
  | 'bucket'
  | 'bin'
  | 'mvexpand'
  | 'transaction'
  | 'fields'
  | 'table'
  | 'format'
  | 'rex'
  | 'nomv'
  | 'lookup'
  | 'timechart'
  | 'search'
  | 'makeresults'
  | 'makemv'
  | 'eventstats'
  | 'multisearch'
  | 'summariesonly'
  | 'prestats'
  | 'local'
  | 'append'
  | 'convert'
  | 'include_reduced_buckets'
  | 'allow_old_summaries'
  | 'chunk_size'
  | 'fillnull_value'
  | 'datamodel'
  | 'sid'
  | 'prefix'
  | 'span'
  | 'sort'
  | 'transpose'
  | 'in'
  | 'allnum'
  | 'delim'
  | 'extendtimerange'
  | 'maxtime'
  | 'fillnull'
  | 'maxout'
  | 'timeout'
  | 'tokenizer'
  | 'allowempty'
  | 'setsv'
  | 'agg'
  | 'cont'
  | 'partial'
  | 'sep'
  | 'value'
  | 'regex'
  | 'return'
  | 'selfjoin'
  | 'outputlookup'
  | 'create_empty'
  | 'override_if_empty'
  | 'key_field'
  | 'xmlkv'
  | FROM
  | aggregation_function
  | convert_function
  | ID
  ;


timeExpression: PLUS|MINUS Digits Duration;
ID : LetterOrPunctFinal LetterOrDigitOrPunct* LetterOrDigitOrPunctFinal ; // Be careful of this one, it will catch all words!
INT: Digits;
L_WILDCARD: WC LetterOrDigitOrPunct+;   // *foo // TODO: + or * ?
R_WILDCARD: LetterOrDigitOrPunct+ WC;          // foo* // TODO: + or * ?
LR_WILDCARD: WC (LetterOrDigitOrPunct|WC)+ WC; // *foo*bar*baz*
STRING: '"' (ESC|.)*? '"' ;

PLUS: '+';
MINUS: '-';
CONCAT: '.';

WORD
 : LetterOrDigitOrPunctFinal LetterOrDigitOrPunct*? LetterOrDigitOrPunctFinal+?
 | LetterOrPunctFinal
 ;

left_side_value
  : WORD
  | ID
  | reserved_keywords
  ;

fieldname
  : WORD
  | ID
  | reserved_keywords
  //| '"' fieldname '"'
  | '*'
  | STRING
  ;
boolean_value: TRUE|FALSE;

math_operator: PLUS  | MINUS | '*' | '/' | '%' | '^' | '&' | CONCAT;
logical_operator: AND | OR | XOR;
unary_operator: '~' | PLUS | MINUS | NOT;
comparison_operator: EQ | DOUBLE_EQ | NEQ | LESS | LESS_EQ | GREATER | GREATER_EQ;

fragment Duration: 'd' | 's' | 'm' | 'y';
fragment WC : '*';
fragment ESC : '\\"' | '\\\\' ; // 2-char sequences \" and \\


WS : [ \t\n]+ -> skip;

fragment LetterOrDigit
    : Letter
    | [0-9]
    ;
fragment Letter
    : [a-zA-Z$_]
    ;
fragment Digits
    : [0-9]+
    ;

fragment PunctNonFinal
    : '.'
    | '-'
    | '\\'
    | ':'
    | '{'
    // | '/' XXX: This is for sourcetype=bblabla/Operational
    ;

fragment PunctFinal
    : '_'
    | '}'
    ;

fragment Punct
    : PunctFinal
    | PunctNonFinal
    ;

fragment LetterOrPunctFinal
  : Letter
  | PunctFinal
  ;

fragment LetterOrDigitOrPunct
    : LetterOrDigit
    | Punct
    ;

fragment LetterOrDigitOrPunctNonFinal
    : LetterOrDigit
    | PunctNonFinal
    ;

fragment LetterOrDigitOrPunctFinal
    : LetterOrDigit
    | PunctFinal
    ;

query: stat EOF;

stat
  : '|'? spl_generating_command ('|' spl_command)*
  ;

subsearch_expr
  : '[' stat ']'
  ;

spl_command
  : spl_command_eval
  | spl_command_rex
  | spl_command_table
  | spl_command_format
  | spl_command_stats
  | spl_command_rename
  | spl_command_fields
  | spl_command_where
  | spl_command_transaction
  | spl_command_append
  | spl_command_mvexpand
  | spl_command_mvcombine
  | spl_command_nomv
  | spl_command_bucket
  | spl_command_join
  | spl_command_makemv
  | spl_command_lookup
  | spl_command_timechart
  | spl_command_sort
  | spl_command_fillnull
  | spl_command_return
  | spl_command_regex
  | spl_command_selfjoin
  | spl_command_convert
  | spl_command_transpose
  | spl_command_outputlookup
  | spl_command_xmlkv
  | spl_generating_command
  ;

spl_generating_command
  : spl_command_search
  | spl_command_multisearch
  | spl_command_tstats
  | spl_command_inputlookup
  | spl_command_makeresults
  | spl_command_eventstats
  ;

spl_command_search
  : ('search') search_arg*
  ;

search_arg
  : search_arg logical_operator search_arg
  | unary_operator search_arg
  | search_arg_expr
  | in_expr
  | LPAR search_arg+ RPAR
  ;

search_arg_expr
  : keyword_expr
  | wildcard_expr
  | field_comparison_expr
  | subsearch_expr
  | logical_expr
  | comparative_expr
  | unary_operator search_arg_expr
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Eval
// eval <field>=<expression>["," <field>=<expression>]...
spl_command_eval
  : 'eval' left_side_value EQ eval_expr (',' left_side_value '=' eval_expr)*
  ;

eval_expr
  : eval_expr math_operator eval_expr
  | function_call_expr
  | INT
  | unary_operator INT
  | STRING
  | WORD
  | ID
  | reserved_keywords
  | subsearch_expr
  | LPAR eval_expr RPAR
  ;

spl_command_where
  : WHERE logical_expr
  ;

spl_command_format // XXX
  : 'format' fieldname*
  ;

fieldname_list
  : fieldname
  | fieldname (','? fieldname)+
  | fieldname (fieldname)+ // XXX: This syntax should be banned! Update line above
  ;

tstats_fieldname_list
  : fieldname
  | fieldname (',' fieldname)+
  | fieldname (fieldname)+ // XXX: This syntax should be banned! Update line above
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Tstats
// | tstats [prestats=<bool>] [local=<bool>] [append=<bool>] [summariesonly=<bool>] [include_reduced_buckets=<bool>] [allow_old_summaries=<bool>] [chunk_size=<unsigned int>] [fillnull_value=<string>] <stats-func>...
//          [FROM ( <namespace> | sid=<tscollect-job-id> | datamodel=<data_model-name> )]
//          [WHERE <search-query> | <field> IN (<value-list>)]
//          [BY (<field-list> | (PREFIX(<field>))) [span=<timespan>] ]
spl_command_tstats
  : 'tstats' (( 'summariesonly' '=' boolean_value)
             | ('prestats' '=' boolean_value)
             | ('local' '=' boolean_value)
             | ('append' '=' boolean_value)
             | ('include_reduced_buckets' '=' boolean_value)
             | ('allow_old_summaries' '=' boolean_value)
             | ('chunk_size' '=' INT)
             | ('fillnull_value' '=' STRING))*
             aggregation_expr_list
             (FROM ( ('datamodel' EQ fieldname)
                     | (loose_string)
                     | ('sid' EQ loose_string)))?
             (WHERE search_arg+)?
             (BY  (tstats_fieldname_list)
                   (('prefix' LPAR fieldname RPAR)
                    |('span' EQ loose_string))*)?
  ;

spl_command_rename
  : 'rename' (fieldname AS fieldname) (',' fieldname AS fieldname)*
  ;

spl_command_inputlookup
  : 'inputlookup' ID (WHERE field_comparison_expr)?
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Lookup
// lookup [local=<bool>] [update=<bool>] <lookup-table-name> ( <lookup-field> [AS <event-field>] )... [ OUTPUT | OUTPUTNEW (<lookup-destfield> [AS <event-destfield>] )... ]
// XXX: Insufficient
spl_command_lookup
  : 'lookup' ID lookup_field_list (WHERE field_comparison_expr)?
  ;

lookup_field_list
  : fieldname (AS fieldname)? (',' fieldname (AS fieldname)?)*
  | fieldname (AS fieldname)?     (fieldname (AS fieldname)?)*
  ;

spl_command_table
  : 'table' fieldname_list
  ;

spl_command_fields
  //: 'fields' ('+'|'-')? ID (',' ID)*
  : 'fields' fields_modifier? fieldname(','? fieldname)*
  ;

fields_modifier: MINUS|PLUS;

in_expr
  : fieldname 'IN' LPAR keyword_expr (',' keyword_expr)* RPAR
  | fieldname 'IN' LPAR keyword_expr     (keyword_expr)* RPAR   // XXX: Should be banned
  | fieldname 'IN' LPAR wildcard_expr (',' wildcard_expr)* RPAR
  | fieldname 'IN' LPAR wildcard_expr     (wildcard_expr)* RPAR // XXX: Should be banned
  | fieldname 'IN' LPAR subsearch_expr RPAR
  ;

logical_expr
  : logical_expr comparison_operator logical_expr
  | logical_expr logical_operator  logical_expr
  | eval_expr // for expression like: |where foo > 2*bar
  | in_expr
  | fieldname
  | keyword_expr
  | wildcard_expr
  | subsearch_expr
  | function_call_expr
  | eval_expr
  | LPAR logical_expr RPAR
  ;

comparative_expr
  : logical_expr comparison_operator logical_expr
  ;

keyword_expr
  : ID
  | STRING
  | INT
  ;

wildcard_expr
  : '*'
  | LR_WILDCARD
  | L_WILDCARD
  | R_WILDCARD;

field_comparison_expr
  : fieldname comparison_operator right_value_expr
  ;

right_value_expr
  : timeExpression
  | WORD
  | boolean_value
  | wildcard_expr
  | ID
  | STRING
  | INT
  | if_expr
  | function_call_expr
  ;


case_item_list
 : case_item
 | case_item ',' case_item_list
 ;

case_item
 : logical_expr ',' eval_expr
 ;

case_expr
 : CASE LPAR case_item_list RPAR
 ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/ConditionalFunctions#if.28X.2CY.2CZ.29
if_expr
  : IF LPAR logical_expr ',' eval_expr ',' eval_expr RPAR
  ;

function_call_param_list
  : function_param_expr
  | function_param_expr ',' function_call_param_list
  ;

function_call_expr
  : if_expr
  | case_expr
  | ID LPAR  function_call_param_list? RPAR
  ;

function_param_expr
  : right_value_expr
  | eval_expr
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Stats
// Simple:
//    stats (stats-function(field) [AS field])... [BY field-list]
// Complete:
//    stats [partitions=<num>] [allnum=<bool>] [delim=<string>]
//          ( <stats-agg-term>... | <sparkline-agg-term>... )
//          [<by-clause>][<dedup_splitvals>]
spl_command_stats
 : 'stats' stats_option*
           aggregation_expr_list
           (BY fieldname_list)?
           stats_option*
 ;

stats_fieldname
 : fieldname
 | '*'
 | L_WILDCARD
 | R_WILDCARD
 ;

stats_option
  : 'allnum' EQ boolean_value
  | 'delim' EQ STRING
  ;

aggregation_expr_list
  : aggregation_expr
  | aggregation_expr (','? aggregation_expr)+
  | aggregation_expr (aggregation_expr)+      // XXX: This syntax should be banned, update line above
  ;

aggregation_expr
  : aggregation_function_expr
  | aggregation_function_expr AS stats_fieldname
  ;

aggregation_function_expr
  : aggregation_function
  | aggregation_function LPAR aggregation_function_expr RPAR
  | aggregation_function LPAR eval_expr RPAR
  | aggregation_function LPAR stats_fieldname RPAR
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Multisearch
// | multisearch <subsearch1> <subsearch2> <subsearch3> ...
spl_command_multisearch // XXX #14
  : 'multisearch' subsearch_expr+
  ;

spl_command_mvexpand // XXX #25
  : 'mvexpand' fieldname_list
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Mvcombine
// mvcombine [delim=<string>] <field>
spl_command_mvcombine
  : 'mvcombine' ('delim' '=' loose_string)? fieldname
  ;

spl_command_transaction
  : 'transaction' transaction_option* fieldname transaction_option*
  ;

transaction_option
  : ID EQ boolean_value
  ;

loose_string
  : WORD
  | STRING
  | ID
  ;

regex_string: STRING;
sed_expr: STRING;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Rex
// rex [field=<field>]
//     ( <regex-expression> [max_match=<int>] [offset_field=<string>] ) | (mode=sed <sed-expression>)
spl_command_rex
  : 'rex' 'field' '=' fieldname regex_string (('max_match' '=' INT)|('offset_field' '=' loose_string))*
  | 'rex' (('field' '=' fieldname)|('mode' '=' SED))+ sed_expr
  | 'rex' STRING
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Append
// append [ extendtimerange=<boolean> | maxtime=<int> | maxout=<int> | timeout=<int>] <subsearch>
//
spl_command_append
  : 'append' subsearch_option* subsearch_expr
  ;

subsearch_option
  : 'extendtimerange' '=' boolean_value
  | 'maxtime' '=' INT
  | 'maxout' '=' INT
  | 'timeout' '=' INT
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Makeresults
// | makeresults [<count>] [<annotate>] [<splunk-server>] [<splunk-server-group>...]
// XXX: Implement makeresults options
spl_command_makeresults
  : 'makeresults'
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Nomv
spl_command_nomv
  : 'nomv' fieldname
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Eventstats
// eventstats [allnum=<bool>]
//            <stats-agg-term> ...
//            [<by-clause>]
spl_command_eventstats
  : 'eventstats' stats_option*
                 aggregation_expr_list
                 (BY fieldname_list)?
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Bin
// bin [<bin-options>...] <field> [AS <newfield>]
//     bin-options: bins | minspan | span | <start-end> | aligntime
spl_command_bucket
  : 'bucket' bin_option* fieldname (AS fieldname)? bin_option*
  | 'bin'    bin_option* fieldname (AS fieldname)? bin_option*
  ;

bin_option // XXX: I use loose_string randomly
  : 'bins' '=' loose_string
  | 'minspan' '=' loose_string
  | 'span' '=' loose_string
  | 'aligntime' '=' loose_string
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Join
// join [join-options...] [field-list] subsearch
spl_command_join
  : 'join' join_option* (fieldname (',' fieldname)*)? subsearch_expr
  ;

// type=(inner | outer | left) | usetime=<bool> | earlier=<bool> | overwrite=<bool> | max=<int>
join_option
  : 'type' '=' ID
  | 'usetime' '=' boolean_value
  | 'earlier' '=' boolean_value
  | 'overwrite' '=' boolean_value
  | 'max' '=' INT
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Makemv
// makemv [delim=<string> | tokenizer=<string>] [allowempty=<bool>] [setsv=<bool>] <field>
spl_command_makemv
  : 'makemv' makemv_option* fieldname
  ;

makemv_option
  : 'delim' '=' loose_string
  | 'tokenizer' '=' loose_string
  | 'allowempty' '=' boolean_value
  | 'setsv' '=' boolean_value
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Timechart
// timechart [sep=<string>] [format=<string>] [partial=<bool>] [cont=<bool>] [limit=<int>]
//           [agg=<stats-agg-term>] [<bin-options>... ]
//           ( (<single-agg> [BY <split-by-clause>] ) | (<eval-expression>) BY <split-by-clause> )
//           [<dedup_splitvals>]
spl_command_timechart
  : 'timechart' timechart_option* aggregation_function AS fieldname
  | 'timechart' timechart_option* eval_expr BY fieldname
  ;

timechart_option
  : 'span' EQ WORD
  | 'sep' EQ STRING
  | 'format' EQ STRING
  | 'partial' EQ boolean_value
  | 'cont' EQ boolean_value
  | 'limit' EQ INT
  | 'agg' EQ aggregation_function
  // XXX: Missing bin-options
  ;

spl_command_sort
  : 'sort' MINUS? fieldname_list
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Fillnull
// fillnull [value=string] [<field-list>]
spl_command_fillnull
  : 'fillnull' ('value' EQ STRING)? fieldname_list
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Return
// return [<count>] [<alias>=<field>...] [<field>...] [$<field>...]
spl_command_return
  : 'return' INT? (fieldname EQ fieldname)* fieldname* ('$' fieldname)*
  ;

// https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Selfjoin
// selfjoin [<selfjoin-options>...] <field-list>
//          selfjoin-options: overwrite=<bool> | max=<int> | keepsingle=<bool>
spl_command_selfjoin
  : 'selfjoin' selfjoin_option* fieldname_list selfjoin_option*
  ;

selfjoin_option
  : ID EQ boolean_value
  | ID EQ INT
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/Convert
// convert [timeformat=string] (<convert-function> [AS <field>] )...
// <convert-function>:  auto() | ctime() | dur2sec() | memk() | mktime() | mstime() | none() | num() | rmcomma() | rmunit()
spl_command_convert
  : 'convert' ('timeformat' EQ STRING)? (','? convert_function LPAR fieldname RPAR (AS fieldname)?)*
  ;

// https://docs.splunk.com/Documentation/Splunk/8.0.2/SearchReference/regex
// regex (<field>=<regex-expression> | <field>!=<regex-expression> | <regex-expression>)
spl_command_regex
  : 'regex' fieldname EQ STRING
  | 'regex' fieldname NEQ STRING
  | 'regex' fieldname STRING
  ;

// https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Transpose
// transpose [int] [column_name=<string>] [header_field=<field>] [include_empty=<bool>]
spl_command_transpose
  : 'transpose' INT? (fieldname EQ STRING)? (ID EQ fieldname)? (ID EQ boolean_value)?
  ;

// https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/Outputlookup
//    | outputlookup
//    [append=<bool>]
//    [create_empty=<bool>]
//    [override_if_empty=<bool>]
//    [max=<int>]
//    [key_field=<field>]
//    [createinapp=<bool>]
//    [output_format=<string>]
//    <filename> | <tablename>
spl_command_outputlookup
  : 'outputlookup'  outputlookup_option* fieldname
  ;

outputlookup_option
  : 'append' EQ boolean_value
  | 'create_empty' EQ boolean_value
  | 'override_if_empty' EQ boolean_value
  | 'max' EQ INT
  | 'key_field' EQ fieldname
  ;

spl_command_xmlkv
  : 'xmlkv'
  ;

ErrorChar
   : .
   ;