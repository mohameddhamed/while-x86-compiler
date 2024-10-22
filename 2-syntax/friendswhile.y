%baseclass-preinclude <iostream>

%lsp-needed

%token T_PROGRAM
%token T_BEGIN
%token T_END
%token T_INTEGER 
%token T_BOOLEAN
%token T_SKIP
%token T_IF
%token T_THEN
%token T_ELSE
%token T_ENDIF
%token T_WHILE
%token T_DO
%token T_DONE
%token T_READ
%token T_WRITE
%token T_SEMICOLON
%token T_ASSIGN
%token T_OPEN
%token T_CLOSE
%token T_NUM
%token T_TRUE
%token T_FALSE
%token T_ID
%token T_TERNARY_IF
%token T_TERNARY_ELSE
%token T_BRACKET_OPEN
%token T_BRACKET_CLOSE
%token T_PARALLEL
%token T_COMMA
%token T_DUPLICATE
%token T_LIST
%token T_APPEND
%token T_DOT

%left T_OR T_AND
%left T_EQ
%left T_LESS T_GR
%left T_ADD T_SUB
%left T_CONCAT
%left T_MUL T_DIV T_MOD
%left T_SHL T_SHR
%nonassoc T_NOT

%start program

%%

program:
    T_PROGRAM T_ID declarations T_BEGIN statements T_END
    {
        std::cout << "start -> T_PROGRAM T_ID declarations T_BEGIN statements T_END" << std::endl;
    }
;

declarations:
    // empty
    {
        std::cout << "declarations -> epsilon" << std::endl;
    }
|
    declaration declarations
    {
        std::cout << "declarations -> declaration declarations" << std::endl;
    }
;

optlist:
    // empty
    {
        std::cout << "optlist -> epsilon" << std::endl;
    }
|
    T_LIST
    {
        std::cout << "optlist -> T_LIST" << std::endl;
    }
;

base_type:
    T_INTEGER optlist
    {
        std::cout << "base_type -> T_INTEGER optlist" << std::endl;
    }
|
    T_BOOLEAN optlist
    {
        std::cout << "base_type -> T_BOOLEAN optlist" << std::endl;
    }
;

tuple_args:
    // empty
    {
        std::cout << "tuple_args -> epsilon" << std::endl;
    }
|
    T_COMMA base_type tuple_args
    {
        std::cout << "tuple_args -> base_type T_COMMA tuple_args" << std::endl;
    }
;

tuple_type:
    T_LESS base_type tuple_args T_GR
    {
        std::cout << "tuple_type -> T_ANGLE_OPEN base_type tuple_args T_ANGLE_CLOSE" << std::endl;
    }
;

declaration:
    base_type declaration_vars T_SEMICOLON
    {
        std::cout << "declaration -> base_type declaration_vars T_SEMICOLON" << std::endl;
    }
|
    tuple_type declaration_vars T_SEMICOLON
    {
        std::cout << "declaration -> tuple_type declaration_vars T_SEMICOLON" << std::endl;
    }
;

declaration_vars_helper:
    T_COMMA T_ID declaration_vars_helper
    {
        std::cout << "declaratoin_vars_helper -> T_COMMA T_ID declaration_vars_helper" << std::endl;
    }
|
//empty
    {
        std::cout << "declaration_vars_helper -> epsilon" << std::endl;
    }
;

declaration_vars:
    T_ID declaration_vars_helper
    {
        std::cout << "declaration_vars -> T_ID declaration_vars_helper" << std::endl;
    }
;


statements:
    statement
    {
        std::cout << "statements -> statement" << std::endl;
    }
|
    statements statement
    {
        std::cout << "statement -> statements statement" << std::endl;
    }
;

statement:
    skip T_SEMICOLON
    {
        std::cout << "statement -> skip T_SEMICOLON" << std::endl;
    }
|
    assignment T_SEMICOLON
    {
        std::cout << "statement -> assignment T_SEMICOLON" << std::endl;
    }
|
    read T_SEMICOLON
    {
        std::cout << "statement -> read T_SEMICOLON" << std::endl;
    }
|
    write T_SEMICOLON
    {
        std::cout << "statement -> write T_SEMICOLON" << std::endl;
    }
|
    branch
    {
        std::cout << "statement -> branch" << std::endl;
    }
|
    loop
    {
        std::cout << "statement -> loop" << std::endl;
    }
|
    parallel T_SEMICOLON
    {
        std::cout << "statement -> parallelization" << std::endl;
    }
|
    T_DUPLICATE statement
    {
        std::cout << "statement -> T_DUPLICATE statement" << std::endl;
    }
;

skip:
    T_SKIP
    {
        std::cout << "skip -> T_SKIP" << std::endl;
    }
;

optindex:
    // empty
    {
        std::cout << "optindex -> epsilon" << std::endl;
    }
|
    T_BRACKET_OPEN T_NUM T_BRACKET_CLOSE
    {
        std::cout << "optindex -> T_BRACKET_OPEN T_NUMBER T_BRACKET_CLOSE" << std::endl;
    }
;

opt_tuple_index:
    // empty
    {
        std::cout << "opt_tuple_index -> epsilon" << std::endl;
    }
|
    T_DOT T_NUM
    {
        std::cout << "opt_tuple_index -> T_DOT T_NUM" << std::endl;
    }
;

root_assignment:
    T_ID opt_tuple_index optindex T_ASSIGN expression
    {
        std::cout << "root_assignment -> T_ID opt_tuple_index optindex T_ASSIGN expression" << std::endl;
    }
|
    T_ID opt_tuple_index optindex T_COMMA root_assignment T_COMMA expression
    {
        std::cout << "root_assignment -> T_ID opt_tuple_index optindex T_COMMA root_assignment T_COMMA expression" << std::endl;
    }
;


assignment:
    root_assignment
    {
        std::cout << "assignment -> root_assignment" << std::endl;
    }
|
    T_ID opt_tuple_index optindex T_APPEND list_expression
    {
        std::cout << "assignment -> T_ID opt_tuple_index optindex T_APPEND list_expression" << std::endl;
    }
|
   
;

read:
    T_READ T_OPEN T_ID opt_tuple_index optindex T_CLOSE
    {
        std::cout << "read -> T_READ T_OPEN T_ID opt_tuple_index optindex T_CLOSE" << std::endl;
    }
;

write:
    T_WRITE T_OPEN expression T_CLOSE
    {
        std::cout << "write -> T_WRITE T_OPEN expression T_CLOSE" << std::endl;
    }
;

branch:
    T_IF expression T_THEN statements T_ENDIF
    {
        std::cout << "branch -> T_IF expression T_THEN statements T_ENDIF" << std::endl;
    }
|
    T_IF expression T_THEN statements T_ELSE statements T_ENDIF
    {
        std::cout << "branch -> T_IF expression T_THEN statements T_ELSE statements T_ENDIF" << std::endl;
    }
;

loop:
    T_WHILE expression T_DO statements T_DONE
    {
        std::cout << "loop -> T_WHILE expression T_DO statements T_DONE" << std::endl;
    }
;

sstatement:
    skip | assignment | read | write | branch | loop | parallel
;

parallel:
    T_BRACKET_OPEN sstatement T_PARALLEL sstatement T_BRACKET_CLOSE
    {
        std::cout << "T_BRACKET_OPEN sstatement T_PARALLEL sstatement T_BRACKET_CLOSE" << std::endl;
    }
;

expression:
    T_NUM
    {
        std::cout << "expression -> T_NUM" << std::endl;
    }
|
    T_TRUE
    {
        std::cout << "expression -> T_TRUE" << std::endl;
    }
|
    T_FALSE
    {
        std::cout << "expression -> T_FALSE" << std::endl;
    }
|
    T_ID opt_tuple_index optindex
    {
        std::cout << "expression -> T_ID opt_tuple_index optindex" << std::endl;
    }
|
    expression T_ADD expression
    {
        std::cout << "expression -> expression T_ADD expression" << std::endl;
    }
|
    expression T_SUB expression
    {
        std::cout << "expression -> expression T_SUB expression" << std::endl;
    }
|
    expression T_MUL expression
    {
        std::cout << "expression -> expression T_MUL expression" << std::endl;
    }
|
    expression T_DIV expression
    {
        std::cout << "expression -> expression T_DIV expression" << std::endl;
    }
|
    expression T_MOD expression
    {
        std::cout << "expression -> expression T_MOD expression" << std::endl;
    }
|
    expression T_LESS expression
    {
        std::cout << "expression -> expression T_LESS expression" << std::endl;
    }
|
    expression T_GR expression
    {
        std::cout << "expression -> expression T_GR expression" << std::endl;
    }
|
    expression T_EQ expression
    {
        std::cout << "expression -> expression T_EQ expression" << std::endl;
    }
|
    expression T_AND expression
    {
        std::cout << "expression -> expression T_AND expression" << std::endl;
    }
|
    expression T_OR expression
    {
        std::cout << "expression -> expression T_OR expression" << std::endl;
    }
|
    T_NOT expression
    {
        std::cout << "expression -> T_NOT expression" << std::endl;
    }
|
    T_OPEN expression T_CLOSE
    {
        std::cout << "expression -> T_OPEN expression T_CLOSE" << std::endl;
    }
|
    expression T_SHL expression
    {
        std::cout << "expression -> expression T_SHL expression" << std::endl;
    }
|
    expression T_SHR expression
    {
        std::cout << "expression -> expression T_SHR expression" << std::endl;
    }
|
    T_OPEN expression T_TERNARY_IF expression T_TERNARY_ELSE expression T_CLOSE
    {
        std::cout << "expression -> T_OPEN expression T_TERNARY_IF expression T_TERNARY_ELSE expression T_CLOSE" << std::endl;
    }
|
    expression T_CONCAT expression
    {
        std::cout << "expression -> expression T_CONCAT expression" << std::endl;
    }
|
    list_expression
    {
        std::cout << "expression -> list_expression" << std::endl;
    }
;

list_expression:
    T_BRACKET_OPEN expression list_elements T_BRACKET_CLOSE
    {
        std::cout << "list_expression -> T_BRACKET_OPEN expression list_element T_BRACKET_CLOSE" << std::endl;
    }
|
    T_BRACKET_OPEN T_BRACKET_CLOSE
    {
       std::cout << "list_expression -> T_BRACKET_OPEN T_BRACKET_CLOSE" << std::endl;
    }
;

list_elements:
    T_COMMA expression list_elements
    {
        std::cout << "list_elements -> T_COMMA expression list_elements" << std::endl;
    }
|
    // empty
    {
        std::cout << "list_elements -> epsilon" << std::endl;
    }
;
