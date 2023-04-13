%{
    #include "test_translator.h"
    extern int yylex();
    void yyerror(char* s);
%}

%union 
{
    char* str;
    Node* node;
}

%token AND OR SELECT PROJECT JOIN UNION INTERSECT DIFF PROD LSQ RSQ LPAR RPAR
%token <str> WORD

%start result

%type<node>
    expression
    table
    term

%%

result :
        | result table
        {
            // printTable($2);
            get($2);
        }
;

table : term
        { $$ = makeTree($1); }
        | SELECT LSQ expression RSQ LPAR table PROD table RPAR
        { $$ = joinTree($3, $6, $8); }
        | SELECT LSQ expression RSQ LPAR table JOIN LSQ expression RSQ table RPAR
        { $$ = joinTree(appendAndNode($3, $9), $6, $11); }
        | SELECT LSQ expression RSQ LPAR table DIFF table RPAR
        { $$ = diffTree($3, $6, $8); }
        | SELECT LSQ expression RSQ LPAR table RPAR
        { $$ = makeSelectTree($3, $6); }
        | PROJECT LSQ expression RSQ LPAR table RPAR
        { $$ = makeProjectTree($3, $6); }
        | PROJECT LSQ expression RSQ LPAR table UNION table RPAR
        { $$ = unionTree($3, $6, $8); }
;

expression: term
            { $$ = $1; }
            | expression AND term
            { $$ = makeAndNode($1, $3); }
;

term:   WORD
        { $$ = makeTermNode($1); }
        | term OR WORD
        {
            string temp($3);
            string s = ($1)->content + " OR " + temp;
            $$ = makeTermNode(s);
        }
;

%%

void yyerror(char* s)
{
    printf("Error Detected : %s\n", s);
}