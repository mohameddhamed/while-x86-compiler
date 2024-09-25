%option noyywrap c++ yylineno

%{
#include <iostream>
#include <stdlib.h>
%}

DIGIT  		[0-9]
WS          [ \t\n]
LETTER      [a-zA-Z]

%%

program                             std::cout <<"T_PROGRAM" << std::endl;
begin                               std::cout <<"T_BEGIN" << std::endl;
end                                 std::cout <<"T_END" << std::endl;
integer                             std::cout <<"T_INTEGER" << std::endl; 
boolean                             std::cout <<"T_BOOLEAN" << std::endl;
skip                                std::cout <<"T_SKIP" << std::endl;
if                                  std::cout <<"T_IF" << std::endl;
then                                std::cout <<"T_THEN" << std::endl;
else                                std::cout <<"T_ELSE" << std::endl;
endif                               std::cout <<"T_ENDIF" << std::endl;
while                               std::cout <<"T_WHILE" << std::endl;
do                                  std::cout <<"T_DO" << std::endl;
done                                std::cout <<"T_DONE" << std::endl;
read                                std::cout <<"T_READ" << std::endl;
write                               std::cout <<"T_WRITE" << std::endl;
";"                                 std::cout <<"T_SEMICOLON" << std::endl;
":="                                std::cout <<"T_ASSIGN" << std::endl;
"="                                 std::cout <<"T_EQ" << std::endl;
"<"                                 std::cout <<"T_LESS" << std::endl;
">"                                 std::cout <<"T_GR" << std::endl;
"+"                                 std::cout <<"T_ADD" << std::endl;
"-"                                 std::cout <<"T_SUB" << std::endl;
"*"                                 std::cout <<"T_MUL" << std::endl;
and                                 std::cout <<"T_AND" << std::endl;
or                                  std::cout <<"T_OR" << std::endl;
not                                 std::cout <<"T_NOT" << std::endl;
div                                 std::cout <<"T_DIV" << std::endl; 
mod                                 std::cout <<"T_MOD" << std::endl;
"("                                 std::cout <<"T_OPEN" << std::endl;
")"                                 std::cout <<"T_CLOSE" << std::endl;

(0{DIGIT}+)                         std::cout <<"T_LEADING_ZERO" << std::endl;
({DIGIT}+\.{DIGIT}+)                std::cout <<"T_FRACTIONAL_WITH_DECIMAL" << std::endl;
(\-{DIGIT}+)|(\+{DIGIT}+)           std::cout <<"T_SIGNED_NUM" << std::endl; 
{DIGIT}+	                        std::cout <<"T_NUM" << std::endl;
\/\/.*                              std::cout <<"T_LINE_COMMENT" << std::endl;
\/\*{WS}*(.*)*{WS}*\*\/             std::cout << "T_MULTI_LINE_COMMENT1" << std::endl; 
\/\*({LETTER}|{DIGIT}|{WS})+\*\/    std::cout << "T_MULTI_LINE_COMMENT0" << std::endl; 
true                                std::cout <<"T_TRUE" << std::endl;
false                               std::cout <<"T_FALSE" << std::endl;
([2][0-3]|[01][0-9]):([0-5][0-9])   std::cout <<"T_HOUR" << std::endl;
0b[01]+                             std::cout <<"T_BINARY" << std::endl;
0o[0-7]+                            std::cout <<"T_OCTAL" << std::endl;
0x[0-9A-F]+                         std::cout <<"T_HEXADECIMAL" << std::endl;
([2][2-9]|[3-9][0-9])-([0][0-9]|[1][12])-([0-2][0-9]|[3][01]) std::cout <<"T_DATE" << std::endl;
([0-9][0-9])-([0-9][0-9])-([0-9][0-9]) {
    std::cerr << "Line " << lineno() << ": Wrong Date Format error." << std::endl;
    exit(1);
}
\"((.){3})+\"                       std::cout << "T_3LENGTH_STRING" << std::endl;
\".*\"                              std::cout << "T_NLENGTH_STRING" << std::endl;
"#".*\n    // nothing to do

{LETTER}({LETTER}|{DIGIT}|_)*       std::cout << "T_ID  " << YYText() << std::endl;

{WS}+   // nothing to do

. {
    std::cerr << "Line " << lineno() << ": Lexical error." << std::endl;
    exit(1);
}

%%
