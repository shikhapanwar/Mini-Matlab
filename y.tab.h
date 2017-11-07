/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IDENTIFIER = 258,
    STRING_LITERAL = 259,
    INTEGER_CONSTANT = 260,
    FLOATING_CONSTANT = 261,
    CHARACTER_CONSTANT = 262,
    ZERO_CONSTANT = 263,
    LEFT_CURL = 264,
    RCB = 265,
    ARROW = 266,
    PLUS_PLUS = 267,
    MINUS_MINUS = 268,
    NEW = 269,
    LEFT_SHIFT = 270,
    RIGHTSH = 271,
    LE = 272,
    GE = 273,
    ET = 274,
    NE = 275,
    DAND = 276,
    DOR = 277,
    QM = 278,
    COL = 279,
    POW = 280,
    OR = 281,
    SCOL = 282,
    ASSIGN = 283,
    MULTA = 284,
    DIVA = 285,
    REMA = 286,
    POWA = 287,
    PLUSA = 288,
    MINUSA = 289,
    LSA = 290,
    RSA = 291,
    ANDA = 292,
    ORA = 293,
    BREAK = 294,
    VOID = 295,
    CHAR = 296,
    INT = 297,
    FLOAT = 298,
    SHORT = 299,
    LONG = 300,
    UNSIGNED = 301,
    SIGNED = 302,
    RETURN = 303,
    IF = 304,
    DO = 305,
    SWITCH = 306,
    GOTO = 307,
    CASE = 308,
    FOR = 309,
    WHILE = 310,
    BOOL = 311,
    CONTINUE = 312,
    DEFAULT = 313,
    ELSE = 314,
    MATRIX = 315,
    DOUBLE = 316
  };
#endif
/* Tokens.  */
#define IDENTIFIER 258
#define STRING_LITERAL 259
#define INTEGER_CONSTANT 260
#define FLOATING_CONSTANT 261
#define CHARACTER_CONSTANT 262
#define ZERO_CONSTANT 263
#define LEFT_CURL 264
#define RCB 265
#define ARROW 266
#define PLUS_PLUS 267
#define MINUS_MINUS 268
#define NEW 269
#define LEFT_SHIFT 270
#define RIGHTSH 271
#define LE 272
#define GE 273
#define ET 274
#define NE 275
#define DAND 276
#define DOR 277
#define QM 278
#define COL 279
#define POW 280
#define OR 281
#define SCOL 282
#define ASSIGN 283
#define MULTA 284
#define DIVA 285
#define REMA 286
#define POWA 287
#define PLUSA 288
#define MINUSA 289
#define LSA 290
#define RSA 291
#define ANDA 292
#define ORA 293
#define BREAK 294
#define VOID 295
#define CHAR 296
#define INT 297
#define FLOAT 298
#define SHORT 299
#define LONG 300
#define UNSIGNED 301
#define SIGNED 302
#define RETURN 303
#define IF 304
#define DO 305
#define SWITCH 306
#define GOTO 307
#define CASE 308
#define FOR 309
#define WHILE 310
#define BOOL 311
#define CONTINUE 312
#define DEFAULT 313
#define ELSE 314
#define MATRIX 315
#define DOUBLE 316

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 20 "15CS10060.y" /* yacc.c:1909  */

	string *str_val;
	int int_val;
	float float_val;	
	char char_val ;
	expr_attr *expr;
	declar_list *dec_list;
	declar declara;
	func_param *f_par;
	func_param_list *f_param_list;
	expr_row_list *expr_row_list_pt;
	expr_row *expr_row_pt;
	operator_type *operator_type_;

#line 191 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
