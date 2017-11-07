%{
	#include <stdio.h>
	#include <string.h>
	extern FILE* yyin;
	extern int yylex();
	extern int yyparse();
	void yyerror(const char* s);

	#include "15CS10060_translator.h"
	quad_array *Q_arr = new quad_array;
	symbol_table *GT = new symbol_table;
	symbol_table *curr_symbol_table = GT;
	vector<string> string_lits;
	symbol_table *sym;
	//GT->name = "Global Table";

%}

%union
{
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
}

%token <str_val> IDENTIFIER
%token <str_val>STRING_LITERAL
%token <int_val> INTEGER_CONSTANT
%token <float_val> FLOATING_CONSTANT
%token <char_val> CHARACTER_CONSTANT
%token	<int_val> ZERO_CONSTANT
%token LEFT_CURL RCB
%token  ARROW PLUS_PLUS MINUS_MINUS NEW
%token LEFT_SHIFT RIGHTSH LE GE ET NE 
%token DAND DOR QM COL POW OR SCOL
%token ASSIGN MULTA DIVA REMA POWA PLUSA MINUSA LSA RSA ANDA ORA 
%token BREAK VOID CHAR INT FLOAT SHORT LONG UNSIGNED SIGNED RETURN IF DO SWITCH GOTO CASE
%token FOR WHILE BOOL CONTINUE DEFAULT  ELSE MATRIX DOUBLE
%start translation_unit


%type <char_val> unary_operator 

%type <dec_list> declaration
%type<expr> init_declarator
%type<expr> direct_declarator
%type<expr> declarator
%type  <declara> declaration_specifiers
%type <declara>type_specifiers
%type<dec_list> init_declarator_list
%type<expr> function_definition

%type<f_param_list> argument_expression_list

%type<f_param_list>parameter_type_list
%type<f_param_list>parameter_list
%type<f_par>parameter_declaration

%type <operator_type_> assignment_operator
%type<expr> primary_expression
%type <expr> postfix_expression
%type <expr> assignment_expression
%type <expr> unary_expression 
%type <expr> cast_expression
%type <expr> initializer
%type <expr>multiplicative_expression
%type <expr>additive_expression
%type <expr>shift_expression
%type <expr>relational_expression
%type <expr>and_expression
%type <expr>equality_expression
%type <expr>exclusive_or_expression
%type <expr>inclusive_or_expression
%type <expr>logical_or_expression
%type <expr>logical_and_expression
%type <expr>conditional_expression
%type<expr>expression
%type<expr>constant_expression

%type<expr>expression_statement
%type<expr>selection_statement
%type<expr> statement
%type<expr>iteration_statement
%type<expr>labeled_statement
%type<expr>compound_statement
%type<expr>jump_statement
%type<expr> block_item_list
%type<expr> block_item
%type<expr> M
%type<expr> N


%type <expr_row_list_pt>initializer_row_list
%type <expr_row_pt>initializer_row
%%


M
:   
{
    $$ = new expr_attr;
    $$->instr = Q_arr->index;
}
;

N
:   
{
    //$$ = nextlist
    $$ = new expr_attr;
    $$->nextlist = makelist(Q_arr->index);
    Q_arr -> emit("","","", OP_GOTO);
}
;

primary_expression

			:IDENTIFIER													{
																			$$ = new expr_attr;
																			string t = *($1);
																			symbol_table_entry *s = curr_symbol_table->lookup(t);
																			$$->name= t;
																			////cout <<$$->name <<endl<<endl;
																			//////////////printf("RULE : primary_expression \t->\t\t identifier\n");
																		}
			|INTEGER_CONSTANT

 																		{
 																			////cout <<"b"<<endl;
 																			$$ = new expr_attr;
																			string tmp = curr_symbol_table -> gen_temp(INT_);
																			init_value tmp_init;
																			tmp_init.init_int = $1;
																			symbol_table_entry *ptr = curr_symbol_table->lookup(tmp);
																			ptr->initial_value = tmp_init;
																			ptr-> type = INT_ ;
																			$$->name= tmp;
																			$$ -> int_val = $1;

																			quad * q = Q_arr -> emit(tmp, to_string($1), OP_COPY);
																			//////////////printf("RULE : primary_expression \t->\t\t integer\n");
																		}
			|FLOATING_CONSTANT
 													{////cout <<"ccccc"<<endl;
																			$$ = new expr_attr;
																			string tmp = curr_symbol_table -> gen_temp(DOUBLE_);
																			init_value tmp_init;
																			tmp_init.init_double = $1;
																			symbol_table_entry *ptr = curr_symbol_table->update(tmp, DOUBLE_, tmp_init, 0, NULL); // set offset
																			$$->name = tmp;
																			$$->double_val = $1;


																			quad * q = Q_arr -> emit(tmp, to_string($1), OP_COPY);
																			//////////////printf("RULE : primary_expression \t->\t\t floating point\n");
																			}
			|CHARACTER_CONSTANT 													{////cout <<"d"<<endl;
																			$$ = new expr_attr;
																			string tmp = curr_symbol_table -> gen_temp(CHAR_);
																			init_value tmp_init;
																			tmp_init.init_char = $1;
																			symbol_table_entry *ptr = curr_symbol_table->update(tmp, CHAR_,tmp_init, 0, NULL); // set offset
																			$$->name = tmp;

																			quad * q = Q_arr -> emit(tmp, to_string($1), OP_COPY);

																			//////////////printf("RULE : primary_expression \t->\t\t constant\n");

																			}
			|ZERO_CONSTANT 													{////cout <<"a"<<endl;
																			$$ = new expr_attr;
																			string tmp = curr_symbol_table -> gen_temp(INT_);
																			init_value tmp_init;
																			tmp_init.init_int = $1;
																			$$->addr = curr_symbol_table->update(tmp, INT_, tmp_init, 0, NULL); //  TO BE DONE set offset

																			quad * q = Q_arr -> emit(tmp, to_string($1), OP_COPY);

																			//////////////printf("RULE : primary_expression \t->\t\t constant\n");
																			}
			|STRING_LITERAL												{
																			
																			$$ = new expr_attr;
																			string tmp = curr_symbol_table -> gen_temp(PTR_);
																			$$->name = tmp;
																			$$->addr = curr_symbol_table->lookup(tmp); //  TO BE DONE set offset // TBD, STRING HANDLING!
																			$$->addr->type = PTR_;
																			string_lits.push_back(*$1);

																			quad * q = Q_arr -> emit(tmp, (*($1)), OP_COPY);
																			//////////////printf("RULE : primary_expression \t->\t string_literal\n");
																			}																


																			
																			
			|'(' expression ')'												{$$ = $2;
																			//////////////printf("primary_expression -\t->\t (expression)\n");
																			
																			}
			;

postfix_expression	
			: primary_expression 										{	////cout <<"check"<<endl; //cout << $1->name<<endl;

																				$$ = $1; //////////////printf("RULE:\t postfix_expression \t->\tprimary_expression\n");
																				}

			| postfix_expression '[' expression ']' '[' expression ']' 	{// to be done

																				
																				$$ = new expr_attr;
																				$$->is_matrix = true;
																				$$->name = curr_symbol_table->gen_temp(DOUBLE_);//$1 id matrix type, only double type matrix value

																				//$$->addr -> type = DOUBLE_;
																				string tmp1 = curr_symbol_table->gen_temp(INT_);
																				string tmp2 = curr_symbol_table->gen_temp(INT_);
																				string tmp3 = curr_symbol_table->gen_temp(INT_);

																				string dim2_str = *curr_symbol_table->lookup($1->name)->initial_value.init_matrix -> dim2;
																				int dim2 = curr_symbol_table->lookup(dim2_str)->initial_value.init_int;

																				Q_arr->emit(tmp1,$3->name , dim2_str, OP_MULT);
																				Q_arr->emit(tmp2, tmp1, $6->name, OP_PLUS);
																				Q_arr ->emit(tmp3, tmp2, "SIZE_OF_FLOAT", OP_MULT);
																				$$->offset_for_matrix = tmp3;
																				$$->matrix_base = $1->name;

																				Q_arr -> emit($$->name,$1->name,
																				tmp3,OP_MATRIX_ACCESS);



																				//to be done

																				/* to be done*///////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression [ expression ]\n");
																		}

			| postfix_expression '(' argument_expression_list ')'		{	

			     //	//cout << "we are here"<<endl;
																	        $$ = new expr_attr;
	data_type t = GT->lookup($1->name)->nested_table->lookup("retVal")->type;
																					$$->name = curr_symbol_table->gen_temp(t);
																	        ////cout <<"CHECK1"<<endl;
																	        symbol_table *f_symbol = GT->lookup( $1->name)->nested_table;

																	        func_param_list *flist = ($3);
																	        int i;
																	        ////cout <<"CHECK1"<<endl;	
																	        int c = 0;
																	        ////cout <<&(f_list->vec)<<endl<<endl;;
																	        for(i=0;i < (flist->vec).size() ;i++)
																	        {
																	            c++;
																	            Q_arr->emit("",(flist->vec)[i].name, "",OP_PARAM);
																	        }
																	        ////cout <<"CHECK1"<<endl;	
																	        string s = to_string(c);																        ////cout <<"CHECK2"<<endl;	
																	        ////cout<<"sf"<<endl;
																	        	Q_arr->emit($$->name, $1->name,s, OP_CALL);
																	        		////cout <<"CHECK3"<<endl;	
																	        	//////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression ( argument_expression_list_opt )\n");
																	      }


			| postfix_expression '(' ')'								{
																			$$ = $1;
																			////cout <<"mckam"<<endl<<$1->name<<endl;
																			Q_arr->emit("",$1->name, "0", OP_CALL);

																		//////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression ( )\n");
																		}
			| postfix_expression '.' IDENTIFIER							{$$ =$1;
																			//not supported
																			//////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression . identifier\n");
																			}
			| postfix_expression ARROW IDENTIFIER						{$$ = $1;//////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression -> identifier\n");
			}
			| postfix_expression PLUS_PLUS									{
																				 $$ = new expr_attr;

																		        symbol_table_entry * f = curr_symbol_table->lookup($1->name);
																		        $$->name = curr_symbol_table->gen_temp(f->type);														      

																		        //////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression ++\n");
																		        }
			| postfix_expression MINUS_MINUS									{
																				 $$ = new expr_attr;

																		        symbol_table_entry * f = curr_symbol_table->lookup($1->name);
																		        $$->name =curr_symbol_table->gen_temp(f->type);
																		        /*
																		        if(f->type.array_type.compare("array") == 0)
																		        {
																		            string temp = curr_sym->gentemp(f->type);
																		            Q_arr->emit(temp, $1->addr, *($1->inner), OP_ARRAY_ACCESS);
																		            Q_arr->emit($$->addr, temp, "", OP_COPY);
																		            Q_arr->emit(temp, temp, "1", OP_PLUS);
																		            Q_arr->emit($1->addr, temp, *($1->inner), ARRAY_DEREFERENCE);
																		        }
																		        */
																		        //else check once again
																		        //{
																		            Q_arr->emit( $$->name, $1->name, "", OP_COPY);
																		            Q_arr->emit($1->name, $1->name, "1", OP_MINUS);

																		        //}   //corrected
																		        //////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression --\n");
																		        }
			| postfix_expression NEW									{$$ = $1; //////////////printf(" RULE:\tpostfix_expression \t->\t postfix_expression .'");
			}
			;

argument_expression_list
			: assignment_expression								  		{
			/*func_param *f = new func_param;
        f->param_name = $1->addr->name;
        $$ = new func_param_list;
        f->type = (curr_symbol_table->lookup(f->param_name)->type);
        $$->vec.push_back(f);*/
																				
																				$$ = new func_param_list;
																				func_param f;
																				////cout <<"a"<<endl;
																				f.name = ($1) -> name;
																				////cout <<"b"<<endl;
																				($$->vec).push_back(f);

																				//////////////printf(" RULE:\targument_expression_list \t->\t assignment_expression\n");
																		}

			| argument_expression_list ',' assignment_expression 		{//done
																					
																			$$ = $1 ;
																			func_param f;
																			f.name = ($3) -> name;
																			($$->vec).push_back(f);
																			
																			//////////////printf(" RULE:\targument_expression_list \t->\t argument_expression_list , assignment_expression\n");
																		}
			;

unary_expression
		:postfix_expression												{$$ = $1; //////////////printf(" RULE:\tunary_expression \t->\t postfix_expression\n");
		}
		| PLUS_PLUS unary_expression 										{//Done
																				$$ = new expr_attr;
																				string tmp = curr_symbol_table -> gen_temp(curr_symbol_table->lookup($2->name)->type);
																				init_value tmp_init;
																			
																				$$->addr = curr_symbol_table->update(tmp, $2->addr->type, tmp_init, 0, NULL); /*//  TO BE DONE set offset and initial val and size set size in update ac to type*/
																				quad *q = Q_arr -> emit(tmp, $2->addr->name, OP_UNARY_PLUS);
																				$$->name = $$->addr->name;


																				//////////////printf(" RULE:\tunary_expression \t->\t ++ unary_expression\n");
																				}

		| MINUS_MINUS unary_expression 										{//done
																				$$ = new expr_attr;
																				string tmp = curr_symbol_table -> gen_temp(curr_symbol_table->lookup($2->name)->type);
																				init_value tmp_init;
																			
																				$$->addr = curr_symbol_table->update(tmp, $2->addr->type, tmp_init, 0, NULL); /*//  TO BE DONE set offset and initial val and size set size in update ac to type*/
																				quad *q = Q_arr -> emit(tmp, $2->addr->name, OP_UNARY_MINUS);
																				$$->name = $$->addr->name;
																				//////////////printf(" RULE:\tunary_expression \t->\t -- unary_expression\n");
																				}

		| unary_operator cast_expression								{//done
		////cout <<"GHARWH"<<endl;
																				$$ = new expr_attr;
																				string tmp = curr_symbol_table -> gen_temp(curr_symbol_table->lookup($2->name)->type);
																				init_value tmp_init;
																				$$->name = tmp;							

																				switch($1)
																				{
																					case '&': 
																					{
																						$$->addr = curr_symbol_table->update(tmp, PTR_, tmp_init, 0, NULL); /*//  TO BE DONE set offset and initial val and size set size in update ac to type*/
																						Q_arr ->emit(tmp, $2->name,OP_REFERENCE);
																						break;
																					}
																					case '*': 
																					{
																						$$->addr = curr_symbol_table->update(tmp, PTR_, tmp_init, 0, NULL); /*//  TO BE DONE set offset and initial val and size set size in update ac to type*/
																						Q_arr ->emit(tmp, $2->name,OP_DEREFERENCE);
																						break;
																					}
																					case '-': 
																					{
																						$$->addr = curr_symbol_table->update(tmp, $2->addr-> type, tmp_init, 0, NULL); /*//  TO BE DONE set offset and initial val and size set size in update ac to type*/
																						Q_arr ->emit(tmp, $2->name,OP_UNARY_MINUS);
																						break;
																					}
																					default :
																					$$ = $2;


																				}
																			//////////////printf(" RULE:\tunary_expression \t->\t unary_operator cast_expression\n");
																			}
		;

unary_operator
		: '&' 															{ $$ = '&';//////////////printf(" RULE:\tunary_operator \t->\t & \n");
		}
		| '*' 															{ $$ = '*'; //////////////printf(" RULE:\tunary_operator \t->\t * \n");
		}
		| '+' 															{$$ = '+';//////////////printf(" RULE:\tunary_operator \t->\t + \n");
		}
		| '-' 															{$$ = '-'; //////////////printf(" RULE:\tunary_operator \t->\t - \n");
		}
		;

cast_expression
		: unary_expression 												{
																			$$ = $1;////cout <<$$->name<<" gs "<<endl;
																			//////////////printf(" RULE:\tcast_expression \t->\t unary_expression\n");

																			}
		;

multiplicative_expression
		: cast_expression 									{	////cout <<"im gher1"<<endl;

																/*to be done, doubt  what are cast expression for ?*/
																				$$ = $1;
																				//////////////printf(" RULE:\tmultiplicative_expression \t->\t cast_expression\n");

																				}
		| multiplicative_expression '*' cast_expression 					{	////cout <<"im gher2"<<endl;
																				   $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name = curr_symbol_table->gen_temp(type);

												        Q_arr->emit($$->name, $1->name, $3->name, OP_MULT);

													//////////////printf(" RULE:\tmultiplicative_expression \t->\t multiplicative_expression * cast_expression\n");

													}


		| multiplicative_expression '/' cast_expression 					{//////cout <<"im gher3"<<endl;
																				 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												   
												   /* //array
												   if(type2.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type2);
												            Q_arr.emit(ARRAY_ACCESS, temp, $3->name, *($3->inner));
												            $3->addr->name = temp;
												            $3->type.array_type = ""; //check
												        }
												        
												        if(type1.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type1);
												            Q_arr.emit(ARRAY_ACCESS, temp, $1->addr->name, *($1->inner));
												            $1->addr->name = temp;
												            $1->type.array_type = ""; //check
												        }
												        */
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name = curr_symbol_table->gen_temp(type);
												        Q_arr->emit($$->name, $1->name, $3->name, OP_DIVIDE);


//////////////printf(" RULE:\tmultiplicative_expression \t->\t multiplicative_expression / cast_expression\n");

}


		| multiplicative_expression '%' cast_expression 					{//////cout <<"im gher4"<<endl;

																				 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;							   
												   
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name= curr_symbol_table->gen_temp(type);
												        Q_arr->emit($$->name, $1->name, $3->name, OP_MODULO);


//////////////printf(" RULE:\tmultiplicative_expression \t->\t multiplicative_expression %% cast_expression\n");

}
		;

additive_expression
		: multiplicative_expression											{$$ = $1;//////////////printf(" RULE:\tadditive_expression \t->\t multiplicative_expression\n");
		}

		| additive_expression '+' multiplicative_expression 				{
		//cout <<"check here for addition"<<endl;
																			 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												   
												   /* //array
												   if(type2.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type2);
												            Q_arr.emit(ARRAY_ACCESS, temp, $3->addr->name, *($3->inner));
												            $3->addr->name = temp;
												            $3->type.array_type = ""; //check
												        }
												        
												        if(type1.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type1);
												            Q_arr.emit(ARRAY_ACCESS, temp, $1->addr->name, *($1->inner));
												            $1->addr->name = temp;
												            $1->type.array_type = ""; //check
												        }
												        */
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   //cout <<"type conversion"<<endl;
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												            e->name = t;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												            e->name = t;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;
												            e->name = t;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            e->name = t;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            e->name = t;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;
												            e->name = t;

												        }
												        //cout <<"here"<<endl;
												        
												        $$->name = (curr_symbol_table->gen_temp(type));
												        Q_arr->emit($$->name, $1->name, $3->name, OP_PLUS);

//////////////printf(" RULE:\tadditive_expression \t->\t additive_expression + multiplicative_expression\n");
}
		| additive_expression '-' multiplicative_expression 				{
																				//////////////printf(" RULE:\tadditive_expression \t->\t additive_expression - multiplicative_expression\n");

																				 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												   		
												   		
												   /* //array
												   if(type2.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type2);
												            Q_arr.emit(ARRAY_ACCESS, temp, $3->addr->name, *($3->inner));
												            $3->addr->name = temp;
												            $3->type.array_type = ""; //check
												        }
												        
												        if(type1.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type1);
												            Q_arr.emit(ARRAY_ACCESS, temp, $1->addr->name, *($1->inner));
												            $1->addr->name = temp;
												            $1->type.array_type = ""; //check
												        }
												        */
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name = (curr_symbol_table->gen_temp(type));
												        Q_arr->emit($$->name, $1->name, $3->name, OP_MINUS);
														}
		;

shift_expression
		: additive_expression 												{$$= $1;//////////////printf(" RULE:\tshift_expression \t->\t additive_expression\n");
		}
		| shift_expression LEFT_SHIFT additive_expression 						{
																					 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												   
												   /* //array
												   if(type2.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type2);
												            Q_arr.emit(ARRAY_ACCESS, temp, $3->addr->name, *($3->inner));
												            $3->addr->name = temp;
												            $3->type.array_type = ""; //check
												        }
												        
												        if(type1.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type1);
												            Q_arr.emit(ARRAY_ACCESS, temp, $1->addr->name, *($1->inner));
												            $1->addr->name = temp;
												            $1->type.array_type = ""; //check
												        }
												        */
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name = (curr_symbol_table->gen_temp(type));
												        Q_arr->emit($$->name, $1->name, $3->name, OP_SHIFT_LEFT);


																					//not supported
																					//////////////printf(" RULE:\tshift_expression \t->\t shift_expression << additive_expression\n");
																					}
		| shift_expression RIGHTSH additive_expression 						{//done
																					 $$ = new expr_attr;
												        data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
												   
												   /* //array
												   if(type2.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type2);
												            Q_arr.emit(ARRAY_ACCESS, temp, $3->addr->name, *($3->inner));
												            $3->addr->name = temp;
												            $3->type.array_type = ""; //check
												        }
												        
												        if(type1.array_type.compare("array") == 0)
												        {
												            string temp = curr_sym->gentemp(type1);
												            Q_arr.emit(ARRAY_ACCESS, temp, $1->addr->name, *($1->inner));
												            $1->addr->name = temp;
												            $1->type.array_type = ""; //check
												        }
												        */
												        	//done
												        int flag = 0;
												        if(type1 == type2)
												        {
												            type = type1;
												            flag = 1;
												        }
												        if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convI2D(e,$1);
												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2D(e,$3);
												            type = type1;

												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$1);
												            type = type2;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            expr_attr *e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;

												            
												        }
												        
												        $$->name = (curr_symbol_table->gen_temp(type));
												        Q_arr->emit($$->name, $1->name, $3->name, OP_SHIFT_RIGHT);

																				//////////////printf(" RULE:\tshift_expression \t->\t shift_expression >> additive_expression\n");
																				}
		;

relational_expression
		: shift_expression 													{$$ =$1;

																				//////////////printf(" RULE:\trelational_expression \t->\t shift_expression\n");
																				}
		| relational_expression '<' shift_expression 						{//done

																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp( curr_symbol_table->lookup($$->name)-> type);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_LESS);
																		        Q_arr-> emit("","","", OP_GOTO);

																			//////////////printf(" RULE:\trelational_expression \t->\t relational_expression < shift_expression\n");
																			}
		| relational_expression '>' shift_expression 						{//done

																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp( curr_symbol_table->lookup($$->name)-> type);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_GREATER);
																		        Q_arr-> emit("","","", OP_GOTO);


																		        //////////////printf(" RULE:\trelational_expression \t->\t relational_expression > shift_expression\n");
																		        }
		| relational_expression LE shift_expression 						{//done

																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp( curr_symbol_table->lookup($$->name)-> type);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_LESS_EQUAL);
																		        Q_arr-> emit("","","", OP_GOTO);

																				
																		        //////////////printf(" RULE:\trelational_expression \t->\t relational_expression <= shift_expression\n");
																		        }
		| relational_expression GE shift_expression 						{	//done

																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp( curr_symbol_table->lookup($$->name)-> type);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_GREATER_EQUAL);
																		        Q_arr-> emit("","","", OP_GOTO);

																				//////////////printf(" RULE:\trelational_expression \t->\t relational_expression >= shift_expression\n");
																				}
		;

equality_expression
		:  relational_expression 											{	$$=$1;//////////////printf(" RULE:\tequality_expression \t->\t relational_expression\n");
		}
		| equality_expression ET relational_expression 						{//done
																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp(BOOL_);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_IS_EQUAL);
																		        Q_arr-> emit("","","", OP_GOTO);


																		       	//////////////printf(" RULE:\tequality_expression \t->\t equality_expression == relational_expression\n");
																		       	}

		| equality_expression NE relational_expression 						{//done
																				$$ = new expr_attr;
																				$$ -> name = curr_symbol_table->gen_temp( BOOL_);
																		        $$->addr = curr_symbol_table->lookup($$->name);
																		        $$->addr->type = BOOL_;
																		        $$->truelist = makelist(Q_arr->index);
																		        $$->falselist = makelist(Q_arr->index + 1); // check
																		        Q_arr -> emit("", $1->name, $3->name, OP_IF_NOT_EQUAL);
																		        Q_arr-> emit("","","", OP_GOTO);


																		        //////////////printf(" RULE:\tequality_expression \t->\t equality_expression != relational_expression\n");
																		        }
		;

and_expression
		: equality_expression 												{$$=$1;

        																		//////////////printf(" RULE:\tand_expression \t->\t equality_expression\n");
        																		}
		| and_expression '&' equality_expression 							{//done

																					/*
																					*/																					/*
																		       /*
																		        if(type2.array_type.compare("array") == 0)
																		        {
																		            string temp = curr_sym->gentemp(type2);
																		            Q_arr.emit(ARRAY_ACCESS, temp, $3->loc, *($3->inner));
																		            $3->loc = temp;
																		            $3->type.array_type = ""; //check
																		        }
																		        
																		        if(type1.array_type.compare("array") == 0)
																		        {
																		            string temp = curr_sym->gentemp(type1);
																		            Q_arr.emit(ARRAY_ACCESS, temp, $1->loc, *($1->inner));
																		            $1->loc = temp;
																		            $1->type.array_type = ""; //check
																		        }
																		        */

																		        
																		        $$ = new expr_attr;
																		        symbol_table_entry *f = curr_symbol_table->lookup($1->name);//check
																		        data_type t;
																		        t = f->type;
																		        $$->addr = curr_symbol_table->lookup( curr_symbol_table->gen_temp(t));
																		        $$->name =  $$->addr->name;
																		        Q_arr->emit($$->name, $1->name, $3->name, OP_LOGICAL_AND);//////////////printf(" RULE:\tand_expression \t->\t and_expression & equality_expression\n");
																		        

																		        }
		;

exclusive_or_expression
		:and_expression 													{$$ =$1;//////////////printf(" RULE:\texclusive_or_expression \t->\t and_expression\n");
		}
		| exclusive_or_expression POW and_expression 						{//done
																				
																				$$ = new expr_attr;
																		        symbol_table_entry *f = curr_symbol_table->lookup($1->name);//check
																		        data_type t;
																		        t = f->type;
																		        $$->addr = curr_symbol_table->lookup( curr_symbol_table->gen_temp(t));
																		        $$->name =  $$->addr->name;

																		        Q_arr->emit($$->name, $1->name, $3->name, OP_XOR);
																		        

																		        //////////////printf(" RULE:\texclusive_or_expression \t->\t exclusive_or_expression ^ and_expression\n");
																		       }
		;

inclusive_or_expression
		:exclusive_or_expression 											{$$ = $1;//////////////printf(" RULE:\tinclusive_or_expression \t->\t exclusive_or_expression\n");
		}
		| inclusive_or_expression OR exclusive_or_expression 				{//done
$$ = new expr_attr;
																		        symbol_table_entry *f = curr_symbol_table->lookup($1->name);//check
																		        data_type t;
																		        t = f->type;
																		        $$->addr = curr_symbol_table->lookup( curr_symbol_table->gen_temp(t));
																		        $$->name =  $$->addr->name;

																		        Q_arr->emit($$->name, $1->name, $3->name, OP_OR);

																		        //////////////printf(" RULE:\tinclusive_or_expression \t->\t inclusive_or | exclusive_or_expression\n");
																		        }
		;

logical_and_expression
		: inclusive_or_expression 											{$$ =$1;//////////////printf(" RULE:\tlogical_and_expression \t->\t inclusive_or_expression\n");
		}
		| logical_and_expression N DAND M inclusive_or_expression 	N			{//done
																			        //type.type_name = "bool";
																			        $$ = new expr_attr;
																			        //$$->type = type; // check once, no temporary variable generated
																			        Q_arr->backpatch($2->nextlist, Q_arr -> index);
																			        //Q_arr->convInt2Bool($1);

																			        Q_arr->backpatch($6->nextlist, Q_arr -> index);
																			        Q_arr->convInt2Bool($5);

																			        Q_arr->backpatch($1->truelist, $4->instr);
																			        $$->truelist = $5->truelist;
																			        $$->falselist = my_merge($1->falselist, $5->falselist);


//////////////printf(" RULE:\tlogical_and_expression \t->\t logical_and_expression && inclusive_or_expression\n");
																			}
		;

logical_or_expression
		:	logical_and_expression 											{$$ =$1;//////////////printf(" RULE:\tlogical_or_expression \t->\t logical_and_expression\n");
		}
		| logical_or_expression N DOR M logical_and_expression N 					{//done
		
																						
																			        $$ = new expr_attr;

																			         Q_arr->backpatch($2->nextlist, Q_arr->index);
																			        //Q_arr->convInt2Bool($1);

																			        Q_arr->backpatch($6->nextlist, Q_arr->index);
																			        Q_arr->convInt2Bool($5);
																			        //Q_arr-> emit($$->addr->name, $$->addr->name, $$->addr->name, OP_LOGICAL_OR);
																					Q_arr->backpatch($1->falselist, $4->instr);
																			        $$->truelist = my_merge($1->truelist, $5->truelist);
																			        $$->falselist = $5->falselist;

        //////////////printf(" RULE:\tlogical_or_expression \t->\t logical_or_expression || logical_and_expression\n");
        }
		;

conditional_expression
		: logical_or_expression 											{$$=$1;//////////////printf(" RULE:\tconditional_expression \t->\t logical_or_expression\n");
		}
		| logical_or_expression N QM M expression N COL M conditional_expression {//done
																				////cout <<"\nbackpatching\n\n";
																		        $$ = new expr_attr;
																		        list<int> I;
																		        data_type type;
																		        type = curr_symbol_table->lookup($5->name)->type;
																		        $$->name = curr_symbol_table->gen_temp(type);
																		        Q_arr->emit($$->name, $9->name,"", OP_COPY);
																		        I = makelist(Q_arr->index);
																		        Q_arr->emit("","","",OP_GOTO);
																		        Q_arr->backpatch($6->nextlist, Q_arr->index);
																		        Q_arr->emit( $$->name, $5->name, "", OP_COPY);
																		        I = my_merge(I, makelist(Q_arr->index));
																		        Q_arr->emit("", "", "", OP_GOTO);
																		        Q_arr -> backpatch($2->nextlist, Q_arr -> index);
																		        //Q_arr -> convInt2Bool($1);
																		        Q_arr -> backpatch($1->truelist, $4->instr);
																		        Q_arr -> backpatch($1->falselist, $8->instr);
																		        Q_arr -> backpatch(I, Q_arr -> index);

        //////////////printf(" RULE:\tconditional_expression \t->\t logical_or_expression ? expression : conditional_expression\n");
        }
		;

assignment_expression
		: conditional_expression 											{$$ = $1;//////////////printf(" RULE:\tassignment_expression \t->\t conditional_expression\n");
		}
		| unary_expression assignment_operator assignment_expression {//done except for arrays

																		if($1->is_matrix == true)
																		{

																				Q_arr ->emit( $1->matrix_base,$1->offset_for_matrix ,$3->name,OP_MATRIX_DEREFERENCE);
																			
																		}

																		else
																		{
																			

																		data_type type1, type2, type;
												        type1 = curr_symbol_table->lookup($1->name)->type;
												        type2 = curr_symbol_table->lookup($3->name)->type;
//cout <<"Type here check.."<< type_string(type1)<<endl<<type_string(type2)<<endl<<endl;
//cout <<"$1->name, $3-n "<<$1->name<<endl<<$3->name<<endl;
												   
												        int flag = 0;
																			expr_attr *e;

												        if(type1 == type2)
												        {
																		e = $3;
												            type = type1;
												            flag = 1;
												        }
												        else if(type1 == DOUBLE_ && type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
																		e->name = t;
												            Q_arr->convI2D(e,$3);
												            type = type1;
												        }
												        
												        else if(type1== INT_ && type2== DOUBLE_)
												        {   string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type2;
																		e->name = t;
												            Q_arr->convI2D(e,$1);

												            type = type2;
												        }
												        if(type1== DOUBLE_ && type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
																		e->name = t;
												            Q_arr->convC2D(e,$3);
												            type = type1;


												         
												            
												        }
												        if(type1== CHAR_ && type2 == DOUBLE_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
e ->name = t;
												            e->addr-> type = type2;
												            Q_arr->convC2D(e,$1);
												            type = type2;
												            
												        }
												        if(type1 == CHAR_ && type2 == INT_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type2);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
e ->name = t;
												            Q_arr->convC2I(e,$1);
												            type = type2;
e ->name = t;
												            
												        }
												        if(type1== INT_ && type2== CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
												            Q_arr->convC2I(e,$3);
												            type = type1;
																		e ->name = t;

												            
												        }
										
																			if($2-> assign == true)
																			Q_arr->emit($1->name, $3->name, "", OP_COPY);
																			if($2-> multa == true)
																			Q_arr->emit($1->name, $1->name, $3->name, OP_MULT);
																			if($2-> diva == true)
																			Q_arr->emit($1->name, $1->name,$3->name, OP_DIVIDE);
																			if($2-> rema == true)
																			Q_arr->emit($1->name, $1->name, $3->name, OP_MODULO);
																			if($2-> plusa == true)
																			Q_arr->emit($1->name,$1->name, $3->name, OP_PLUS);
																			if($2-> minusa == true)
																			Q_arr->emit($1->name, $1->name,$3->name, OP_MINUS);
																			if($2-> lsa == true)
																			Q_arr->emit($1->name, $1->name, $3->name, OP_SHIFT_LEFT);
																			if($2-> rsa == true)
																			Q_arr->emit($1->name,$1->name, $3->name, OP_SHIFT_RIGHT);
																			if($2-> anda == true)
																			Q_arr->emit($1->name, $1->name, $3->name, OP_LOGICAL_AND);
																			//if($2-> powa == true)
																			//Q_arr->emit($1->name, $3->name, "", OP_LOGICAL_OR);
																			if($2-> ora == true)
																			Q_arr->emit($1->name,$1->name, $3->name, OP_LOGICAL_OR);




																		}
																        $$ = $1;


        //////////////printf(" RULE:\tassignment_expression \t->\t unary_expression assignment_operator assignment_expression\n");
        }
		;

assignment_operator
		: ASSIGN 							{$$ = new operator_type; $$->assign = true; //////////////printf(" RULE:\tassignment_operator \t->\t = \n");
		}
		| MULTA 							{ $$ = new operator_type; $$->multa = true;//////////////printf(" RULE:\tassignment_operator \t->\t *= \n");
		}
		| DIVA 								{$$ = new operator_type; $$->diva = true;//////////////printf(" RULE:\tassignment_operator \t->\t /= \n");
		}
		| REMA 								{$$ = new operator_type; $$->rema = true;//////////////printf(" RULE:\tassignment_operator \t->\t %%= \n");
		}
		| PLUSA 							{$$ = new operator_type; $$->plusa = true;//////////////printf(" RULE:\tassignment_operator \t->\t += \n");
		}
		| MINUSA 							{$$ = new operator_type; $$->minusa = true;//////////////printf(" RULE:\tassignment_operator \t->\t -= \n");
		}
		| LSA 								{$$ = new operator_type; $$->lsa = true;//////////////printf(" RULE:\tassignment_operator \t->\t <<= \n");
		}
		| RSA 								{$$ = new operator_type; $$->rsa = true;//////////////printf(" RULE:\tassignment_operator \t->\t >>= \n");
		}
		| ANDA 								{$$ = new operator_type; $$->anda = true;//////////////printf(" RULE:\tassignment_operator \t->\t &=  \n");
		}
		| POWA 								{$$ = new operator_type; $$->powa = true;//////////////printf(" RULE:\tassignment_operator \t->\t ^= \n");
		}
		| ORA 								{$$ = new operator_type; $$->ora = true;//////////////printf(" RULE:\tassignment_operator \t->\t |=  \n");
		}
		;

expression
		:  assignment_expression 											{ $$ = $1;

		//////////////printf(" RULE:\texpression \t->\t assignment_expression\n");
		}
		| expression ',' assignment_expression 								{$$ = $1;//////////////printf(" RULE:\texpression \t->\t expression, assignment_expression\n");
		}
		;

constant_expression
		: conditional_expression 											{$$ = $1;//////////////printf(" RULE:\tconstant_expression \t->\t conditional_expression\n");
		}
		;

declaration
		: declaration_specifiers SCOL										{
																					// not supported
																					// consider only 1 declaration specifier
																					// TO BE DONE PERHAPS FOR function
																				//////////////printf(" RULE:\tdeclaration \t->\t declaration_specifiers ;\n");
																				}
		| declaration_specifiers init_declarator_list SCOL					{         															
																	              	//done
																	              	$$ = $2;
																	              	vector<expr_attr>::iterator it;
																	              	symbol_table_entry *ptr;
																	              	
																	              	for(it = ($2->vec).begin() ; it != ($2->vec).end(); ++it )
																	              	{
																	              		if(it->is_function == false)
																	              		{
																		              		ptr = curr_symbol_table->lookup(it->name);
																							if (it->isPointer == true)
																							{
																								ptr->type = PTR_;
																								ptr->offset = curr_symbol_table -> offset;
																								curr_symbol_table -> offset += size_of_type($1.type);
																							}
																							else if(it->is_matrix == true)
																							{////cout <<"x"<<endl;
																							/*
																								int n, m;
																								symbol_table_entry *ptr_x = curr_symbol_table->lookup(it->name);
																								////cout <<"y"<<endl;

																								n = curr_symbol_table-> lookup (*(ptr_x->initial_value).init_matrix.dim1)-> initial_value.init_int ;
																								////cout <<"z"<<endl;
																								////cout <<"n = "<<n<<endl;

																								m = curr_symbol_table-> lookup (*(ptr_x->initial_value).init_matrix.dim2)-> initial_value.init_int ;
																								////cout <<"aa"<<endl;

																								data_type ty = (ptr_x->initial_value).init_matrix.type;

																								ptr_x->offset = curr_symbol_table -> offset;
																								curr_symbol_table -> offset += curr_symbol_table -> offset + 2 * SIZE_OF_INT + n * m * size_of_type(ty) ;
																								

																							*/
																							}
																							else if (ptr->type == UNKNOWN_)
																							{
																								ptr->type = $1.type;
																								ptr->offset = curr_symbol_table -> offset;
																								curr_symbol_table -> offset += size_of_type($1.type);
																							}

																						}
																						else 
																						{

																							curr_symbol_table->lookup("retVal")->type = $1.type;
																						}
																	              	}
																	              	delete $2;
																					////////////////printf(" RULE:\tdeclaration \t->\t declaration_specifiers init_declarator_list ; \n");
																			}
		;

declaration_specifiers
		: type_specifiers declaration_specifiers_opt 						{//done
																				$$ = $1;

																				////////////////printf(" RULE:\tdeclaration_specifiers \t->\t type_specifiers declaration_specifiers_opt\n");
																				}
		;

declaration_specifiers_opt
		:	 																{////////////////printf(" RULE:\tdeclaration_specifiers_opt \t->\t empty\n");
		}
		|declaration_specifiers 											{// not supported
																				////////////////printf(" RULE:\tdeclaration_specifiers_opt \t->\t declaration_specifiers\n");
																				}

init_declarator_list
		: init_declarator 													{//done
		int i;

		
		 
																				$$ = new declar_list;
																				($$->vec).push_back(*($1));
////cout <<"0th elem is " <<($$->vec).begin()->addr	<<endl;
																				////cout <<"Pushing "<<($$->vec)[($$->vec).size()-1].addr->name<<endl<<endl<<endl;

																				////////////////printf(" RULE:\tinit_declarator_list \t->\t init_declarator\n");
																				}
		| init_declarator_list ',' init_declarator 							{//done
		//print symbol table
		int i;
		
																				////cout <<"$1 = "<<$1 <<endl;//cout <<"0th elem is " <<($1->vec).begin()->addr	<<endl;

																					$$ = $1;
																					////cout <<"0th elem is " <<($1->vec).begin()->addr	<<endl;
																					////cout <<"$$ = "<<$$<<endl;
																					($$->vec).push_back(*($3));
      																			  ////cout <<"Pushing "<<($$->vec)[($$->vec).size()-1].addr->name<<endl<<endl<<endl;

																	              	
																	              	
																	              	



																				  

																				////////////////printf(" RULE:\tinit_declarator_list \t->\t init_declarator_list, init_declarator\n");
																				}
		;

init_declarator
		:declarator 														{//done
																				$$ = $1;
																				////cout <<"here loc ="<<$$<<endl;
																				////////////////printf(" RULE:\tinit_declarator \t->\t declarator\n");
																				}
		| declarator ASSIGN initializer 									{//done
		////cout<<"check here "<<endl;
																				 $$ = $1;
																				// to be done typecheck														
																				if($3->is_matrix == false)
																				{////cout <<"isnt matrix"<<endl;
																					Q_arr->emit($1->name, $3->name, OP_COPY);
																				}
																				else
																				{
																				//cout <<"initializing matrix"<<endl;
																					string nm;
																					symbol_table_entry *ptr = curr_symbol_table -> lookup($$ -> name);
																					//ptr -> type = MATRIX_;
																					expr_row_list *r_list = $3 -> row_list;
																					int n = (r_list -> vec).size();

																					int m = (r_list ->vec)[0].vec.size();
																					////cout <<"size here is "<<n<<" "<<m<<endl;
																					int i, j;
																					vector <expr_row> mat = r_list->vec;

																					//data_type  t = curr_symbol_table->lookup(mat[0].vec[0].name)->type;
																					//(ptr -> initial_value).init_matrix;
																					
																					for(i = 0 ; i < n ; i ++)
																					{
																						for(j = 0 ; j < m ; j ++ )
																						{
																							//(ptr -> initial_value).init_matrix->arr_double[i][j] = mat[i].vec[j].double_val;
																							////cout << (ptr -> initial_value).init_matrix->arr_double[i][j]<<endl;
																							//int mat_offset = i*m + j;
expr_attr *tmp_exp = new expr_attr;
tmp_exp->name = mat[i].vec[j].name;
expr_attr *e = new expr_attr;
e->name = mat[i].vec[j].name;
data_type type;
data_type type2 = curr_symbol_table -> lookup(mat[i].vec[j].name)->type ;
data_type type1 = DOUBLE_;
//cout <<"the type is "<<type_string(type2)<<endl;
if(type2 != DOUBLE_)
{

																			expr_attr *e;

												        
												        if(type2 == INT_)
												        {   
												            string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
																		e->name = t;
												            Q_arr->convI2D(e,tmp_exp);
												            type = type1;
												        }
												        
												        
												        if(type2==CHAR_)
												        {   
												        	string t = curr_symbol_table->gen_temp(type1);
												            symbol_table_entry *s = curr_symbol_table->lookup(t);
												            e = new expr_attr;
												            e->addr = curr_symbol_table->lookup(t);
												            e->addr-> type = type1;
																		e->name = t;
												            Q_arr->convC2D(e,tmp_exp);
												            type = type1;

												            
												        }
												        
}

//cout <<"check1"<<endl;

	string tmp1 = curr_symbol_table->gen_temp(INT_);
	string tmp2 = curr_symbol_table->gen_temp(INT_);
	string tmp3 = curr_symbol_table->gen_temp(INT_);
//cout <<"check2"<<endl;

																						Q_arr->emit(tmp1, to_string(i), to_string(m),  OP_MULT);
//cout <<"check1"<<endl;
																						Q_arr->emit(tmp2, tmp1,to_string(j) ,  OP_PLUS);
//cout <<"check1"<<endl;
																						Q_arr->emit(tmp3,tmp2 ,to_string(SIZE_OF_DOUBLE),  OP_MULT);
//cout <<"check1"<<endl;
		
																							Q_arr->emit($1->name ,tmp3, e->name,OP_MATRIX_DEREFERENCE);
//cout <<"check11"<<mat[i].vec[j].name<<endl;
																							// (ptr -> initial_value).init_matrix.arr_double [i*m + j] = curr_symbol_table->lookup(nm)->initial_value.init_double;
																							 

																						}
																					}

																				//	curr_symbol_table->lookup($1->name) ->offset=curr_symbol_table-> offset;
																				//curr_symbol_table-> offset += (2*SIZE_OF_INT + n * m *size_of_type(t));
																				//curr_symbol_table->lookup($1->name) ->size = 2*SIZE_OF_INT + n * m *size_of_type(t);


																				
																				}
																				//////////////printf(" RULE:\tinit_declarator \t->\t declarator = initializer\n");

																				}
		;

type_specifiers
		: VOID 							{
											//done
											$$.type = VOID_;
											$$.width = SIZE_OF_VOID;
											////////////////printf(" RULE:\ttype_specifiers \t->\t  VOID\n");
										}
		| CHAR 						{
											$$.type = CHAR_;
											$$.width = SIZE_OF_CHAR;
										////////////////printf(" RULE:\ttype_specifiers \t->\t CHAR \n");
										}
		| SHORT 						{////////////////printf(" RULE:\ttype_specifiers \t->\t SHORT \n");
		}
		| INT 						{ $$.type = INT_; $$.width = SIZE_OF_INT; //////////////printf(" RULE:\ttype_specifiers \t->\t INT \n");
		}
		| LONG 						{////////////////printf(" RULE:\ttype_specifiers \t->\t LONG \n");
		}
		| FLOAT 						{////////////////printf(" RULE:\ttype_specifiers \t->\t FLOAT \n");
		}
		| DOUBLE 					{ $$.type = DOUBLE_; $$.width = SIZE_OF_DOUBLE; ////////////////printf(" RULE:\ttype_specifiers \t->\t DOUBLE \n");
		}
		| MATRIX 					{$$.type = MATRIX_;/*to be done*/ $$.type = MATRIX_;   //////////////printf(" RULE:\ttype_specifiers \t->\t MATRIX \n");
		}
		| SIGNED 						{// //////////////printf(" RULE:\ttype_specifiers \t->\t SIGNED  \n");
		}
		| UNSIGNED 						{////////////////printf(" RULE:\ttype_specifiers \t->\t UNSIGNED \n");
		}
		| BOOL 						{$$.type = BOOL_; $$.width = SIZE_OF_BOOL; ////////////////printf(" RULE:\ttype_specifiers \t->\t BOOL  \n");
		}
		;

declarator
		:direct_declarator 												{//done
																		$$ = $1;
																		////cout <<"here loc ="<<$$<<endl;
																			 ////////////////printf(" RULE:\tdeclarator \t->\t direct_declarator\n");
																			 }
		| pointer direct_declarator 									{//done	
																			$$ = $2;
																			$$ -> isPointer =true;

																			////////////////printf(" RULE:\tdeclarator \t->\t pointer direct_declarator\n");
																		}
		;

direct_declarator
		: IDENTIFIER 											{//done

																	
																	$$ = new expr_attr;
																	//$$ ->addr = curr_symbol_table->lookup((*$1));
																	$$->name = (*$1);
																	////cout <<$$->addr->name<<endl;
																	////cout << type_string( $$ -> addr -> type)<<endl;
																	////cout <<"here loc ="<<$$<<endl;
																	////////////////printf(" RULE:\tdirect_declarator \t->\t identifier\n");
																	}
		| '(' declarator ')' 									{////////////////printf(" RULE:\tdirect_declarator \t->\t (declarator)");
		}
		| direct_declarator '[' ']' 							{////////////////printf(" RULE:\tdirect_declarator \t->\t direct_declarator[]");
		}
		| direct_declarator '[' assignment_expression ']' '[' assignment_expression ']' {
		//cout <<"declaring matrix"<<endl;
																	$$ = $1;
																	$$ -> is_matrix = true;
																	curr_symbol_table->lookup($1->name)->type =  MATRIX_;//offset

																	(curr_symbol_table->lookup($1->name)->initial_value).init_matrix = new matrix;
																	(curr_symbol_table->lookup($1->name)->initial_value).init_matrix->dim1 = new string($3->name);
																	(curr_symbol_table->lookup($1->name)->initial_value).init_matrix->dim2 = new string($6 ->name);
																	//cout << "dimensions are"<< *(curr_symbol_table->lookup($1->name)->initial_value).init_matrix->dim1<<endl<<*(curr_symbol_table->lookup($1->name)->initial_value).init_matrix->dim2<<endl;

																				symbol_table_entry *ptr = curr_symbol_table -> lookup($1 -> name);
																					//ptr -> type = MATRIX_;

																					int n = $3->int_val;

																					int m = $6 -> int_val;
																					//cout <<"size here is "<<n<<" "<<m<<endl;
																					int i, j;
																					curr_symbol_table->lookup($1->name)->size = SIZE_OF_DOUBLE * n *m+ 2* SIZE_OF_INT;

																					//cout <<endl<<curr_symbol_table->lookup($1->name)->size<<endl<<endl;

																					
																					for(i = 0 ; i < n ; i ++)
																					{
																						for(j = 0 ; j < m ; j ++ )
																						{
																							(ptr -> initial_value).init_matrix->arr_double[i][j] = 0.0;
																							//cout << (ptr -> initial_value).init_matrix->arr_double[i][j]<<endl;

																							 

																						}
																					}
																	


																	// to be done for matrix
																	//////////////printf(" RULE:\tdirect_declarator \t->\t direct_declarator[assignment_expression][' assignment_expression ']'\n\n\n\nn\n\n \n");
																	}
		| direct_declarator '(' parameter_type_list ')' 		{
																symbol_table_entry *tmp;
																vector<func_param> l = $3->vec;
														        
														        symbol_table *new_sym = new symbol_table;
														        new_sym -> name = string("Table for ")+$1->name;
														        $$ = $1;
														        ////cout <<endl<<endl<<$$->name <<endl<<endl<<endl;
														        GT->lookup($$->name)->type = FUNCTION_;
														        $$->no_of_params = l.size();
														        GT->lookup($$->name)-> nested_table = new_sym;
														        curr_symbol_table = new_sym;

														        vector<func_param>::iterator it;
														        for(it = l.begin(); it != l.end(); it++)
														        {
														            tmp = new_sym -> lookup(it->name);
														            if(it->isPointer == false)tmp -> type = it->type;
														            else tmp -> type =PTR_;
														          }

														        Q_arr -> emit($1->name, "","",_FUNCTION_START);
														        $$->is_function = true;

																// to be done for function
																	//////////////printf(" RULE:\tdirect_declarator \t->\t direct_declarator(parameter_type_list)\n");
																}

		| direct_declarator '(' ')' 							{
																        symbol_table *new_sym = new symbol_table;
																        $$ = $1;
																        ////cout <<endl<<endl<<$$->name <<endl<<endl<<endl;
																        GT->lookup($$->name)->type = FUNCTION_;
																        $$->no_of_params = 0;
																        GT->lookup($$->name)-> nested_table = new_sym;
																        curr_symbol_table = new_sym;
																        Q_arr -> emit($1->name, "","",_FUNCTION_START);
																        $$->is_function = true;

																		// to be done for function
																		//////////////printf(" RULE:\tdirect_declarator \t->\t direct_declarator()\n");
																		}
		| direct_declarator '(' identifier_list ')' 			{
																	// to be done for function
																	//////////////printf(" RULE:\tdirect_declarator \t->\t direct_declarator(identifier_list)\n");
																	}
		;

pointer 
		:'*' 																{
																				// to be done - pointer
																				//////////////printf(" RULE:\tpointer \t->\t *\n");
																				}
		|'*' pointer 														{//////////////printf(" RULE:\tpointer \t->\t * pointer\n");
		}
		;

parameter_type_list
		:parameter_list 											{// done
																		$$ = $1;
																		//////////////printf(" RULE:\tparameter_type_list \t->\t parameter_list\n");
																	}
		;

parameter_list
		:parameter_declaration 										{// done;
																		$$ = new func_param_list;
																		$$->vec.push_back(*($1));


																		//////////////printf(" RULE:\tparameter_list \t->\t parameter_declaration\n");
																		}
		| parameter_list ',' parameter_declaration 				{/*done*/
																		$$ = $1;
																		($$ -> vec).push_back(*($3));
																		//////////////printf(" RULE:\tparameter_list \t->\t parameter_list, parameter_declaration\n");
																		}
		;

parameter_declaration
		:declaration_specifiers declarator 							{/*done*/
																		//GT->lookup($2->name)->type = $1.type;

																		$$ = new func_param;
																		$$ -> name = $2->name;
																		$$ ->type = $1.type;
																		$$->isPointer = $2->isPointer;
																		//////////////printf(" RULE:\tparameter_declaration \t->\t declaration_specifiers declarator\n");
																		}
		| declaration_specifiers  									{/*done*/
																		$$ = new func_param;
																		$$ -> name = "";
																		$$ ->type = $1.type;
																		//////////////printf(" RULE:\tparameter_declaration \t->\t declaration_specifiers\n");
																	}
		;

identifier_list
		:IDENTIFIER 													{/*to be done*///////////////printf(" RULE:\tidentifier_list \t->\t identifier\n");
		}
		| identifier_list ',' IDENTIFIER 							{/*to be done*///////////////printf(" RULE:\tidentifier_list \t->\t identifier_list, identifier\n");
		}
		;

initializer
		:assignment_expression 											{$$ = $1; //////////////printf(" RULE:\tinitializer \t->\t assignment_expression \n");
		}
		| LEFT_CURL initializer_row_list RCB  								{
																				$$ = new expr_attr;
																				$$ -> is_matrix = true;
																				$$ -> row_list = $2;

																				//////////////printf(" RULE:\tinitializer \t->\t { initializer_row_list } \n");
																			}
		;

initializer_row_list
		:initializer_row 										{
																	$$ = new expr_row_list;
																	$$->vec.push_back(*($1));
																	//////////////printf(" RULE:\tinitializer_row_list \t->\t initializer_row\n");
																	}
		| initializer_row_list SCOL initializer_row 			{
																	$$ = $1;
																	$$ -> vec.push_back(*($3));
																	//////////////printf(" RULE:\tinitializer_row_list \t->\t initializer_row_list ; initializer_row \n");
																	}
		;

initializer_row
		:initializer 												{
																		$$ = new expr_row;
																		$$->vec.push_back(*($1));
																		//////////////printf(" RULE:\tinitializer_row \t->\t initializer\n");
																		}
		| designation initializer 									{	//not supported
																		//////////////printf(" RULE:\tinitializer_row \t->\t designation initializer\n");
																		}
		| initializer_row ',' initializer 							{
																		$$ = $1;
																		$$->vec.push_back(*($3));
																		//////////////printf(" RULE:\tinitializer_row \t->\t initializer_row, initializer\n");
																		}
		| initializer_row ',' designation initializer 				{// not supported
																		//////////////printf(" RULE:\tinitializer_row \t->\t initializer_row, designation initializer\n");
																		}
		;

designation
		:designator_list ASSIGN 											{//////////////printf(" RULE:\tdesignation \t->\t designator_list = \n");
		}
		;

designator_list
		:designator 													{//////////////printf(" RULE:\tdesignator_list \t->\t designator\n");
		}
		| designator_list designator 								{//////////////printf(" RULE:\tdesignator_list \t->\t designator_list designator\n");
		}
		;

designator
		:'[' constant_expression ']' 									{//////////////printf(" RULE:\tdesignator \t->\t [ constant_expression ] \n");
		}
		| '.' IDENTIFIER 												{//////////////printf(" RULE:\tdesignator \t->\t .identifier\n");
		}
		;

statement
		:labeled_statement 													{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t labeled_statement\n");
		}
		| compound_statement 												{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t compound_statement\n");
		}
		| expression_statement 												{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t expression_statement\n");
		}
		| selection_statement 												{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t selection_statement\n");
		}
		| iteration_statement 												{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t iteration_statement\n");
		}
		| jump_statement 													{$$ = $1;//////////////printf(" RULE:\tstatement \t->\t jump_statement\n");
		}
		;

labeled_statement
		:IDENTIFIER COL statement 							 	{//////////////printf(" RULE:\tlabeled_statement \t->\t identifier : statement\n");
		}
		| CASE constant_expression COL statement 				{//////////////printf(" RULE:\tlabeled_statement \t->\t case constant_expression : statement\n");
		}
		| DEFAULT COL statement 								{//////////////printf(" RULE:\tlabeled_statement \t->\t default : statement\n");
		}
		;

compound_statement 
		:LEFT_CURL RCB 												{//////////////printf(" RULE:\tcompound_statement \t->\t {}\n");
		}
		| LEFT_CURL block_item_list RCB 								{//done
																			$$ = $2;
																			Q_arr -> backpatch($2->nextlist, Q_arr->index);
																			//////////////printf(" RULE:\tcompound_statement \t->\t { block_item_list } \n");
																			}
		;

block_item_list
		:block_item 													{//done
																			////cout <<"XSD"<<endl;
																			$$ = $1;
																			//Q_arr -> backpatch($1->nextlist, Q_arr -> index);
																			////cout <<"\nbackpatching\n\n";
        																	//Q_arr -> backpatch($1->nextlist, Q_arr->index);
        																}
		| block_item_list M block_item 								{//done
		////cout <<"\nbackpatching\n\n";
																			//////cout <<"gdf"<<endl;
																			////cout <<"\nbackpatching\n\n";
																			Q_arr -> backpatch($1->nextlist, $2->instr);
																	        $$ = new expr_attr;
																	        $$->nextlist = $3->nextlist;
																	        //////////////printf(" RULE:\tblock_item_list \t->\t block_item_list block_item\n");
																	     }
		;

block_item
		:declaration 													{
																			$$ = new expr_attr;
																			//////////////printf(" RULE:\tblock_item \t->\t declaration\n");
																			}
		| statement 													{$$ =$1;//////////////printf(" RULE:\tblock_item \t->\t statement\n");
		}
		;

expression_statement
		:SCOL 													{//done
																	$$ = new expr_attr;
																	//////////////printf(" RULE:\texpression_statement \t->\t ;");
																	}
		| expression SCOL 										{$$ = new expr_attr;//////////////printf(" RULE:\texpression_statement \t->\t expression;");
		}
		;
selection_statement
		:IF '(' expression ')' M statement 						{//done
		////cout <<"aaa"<<endl;
																		        $$ = new expr_attr;
																		        ////cout <<"\nbackpatching\n\n";
																		        //Q_arr -> backpatch($4->nextlist, Q_arr->index);
																		        ////cout<<"ccc"<<endl;
																		        Q_arr -> convInt2Bool($3);
																		        ////cout<<"bbbb"<<endl;
																		        Q_arr->backpatch($3->truelist, $5->instr);
																		        //$$->nextlist
																		        
																		        ////cout<<"$7 = "<<($$->nextlist).size()<<endl;
																		        ////cout<<"$8 = "<<($8->nextlist).size()<<endl;

																		$$->nextlist = my_merge($3->falselist, $6->nextlist);
																       // $$->nextlist = my_merge($$->nextlist, );
																		        ////cout <<"xxxx"<<endl;

        																		//////////////printf(" RULE:\tselection_statement \t->\t if(expression) statement\n")
        																		;
        															}

		| IF '(' expression ')'M statement N ELSE M statement    {
																		        $$ = new expr_attr;////cout <<"\nbackpatching\n\n";

																		        //Q_arr->backpatch($4->nextlist , Q_arr -> index);

																		        Q_arr->convInt2Bool($3);

																		        

																		        Q_arr->backpatch($3->truelist, $5->instr);
																		        Q_arr->backpatch($3->falselist, $9->instr);

																		        $$->nextlist = my_merge($6->nextlist, $10->nextlist);
																		        $$->nextlist = my_merge($$->nextlist, $7->nextlist);
																		       // $$->nextlist = my_merge($$->nextlist, $11->nextlist);

        //////////////printf(" RULE:\tselection_statement \t->\t if(expression) statement else statement\n");
        }


		| SWITCH '(' expression ')' M statement 				{

 																						 $$ = new expr_attr;
																		        ////cout <<"\nbackpatching\n\n";
																		        //Q_arr -> backpatch($4->nextlist, Q_arr->index);
																		        ////cout<<"ccc"<<endl;
																		        Q_arr -> convInt2Bool($3);
																		        ////cout<<"bbbb"<<endl;
																		        Q_arr->backpatch($3->truelist, $5->instr);
																		        //$$->nextlist
																		        
																		        ////cout<<"$7 = "<<($$->nextlist).size()<<endl;
																		        ////cout<<"$8 = "<<($8->nextlist).size()<<endl;

																					$$->nextlist = my_merge($3->falselist, $6->nextlist);
//////////////printf(" RULE:\tselection_statement \t->\t switch(expression) statement\n");
		}
		;

iteration_statement
		:WHILE M'(' expression ')' M statement 					{//done test
																	Q_arr->emit("","","", OP_GOTO);
																	////cout <<"\nbackpatching\n\n";
															        Q_arr->backpatch(makelist(Q_arr->index-1),$2->instr);    

															        //Q_arr->backpatch($5->nextlist,Q_arr->index);
															        Q_arr->convInt2Bool($4);

															        $$ = new expr_attr;
															        Q_arr->backpatch($7 ->nextlist, $2->instr);
															        Q_arr -> backpatch($4->truelist, $6->instr);
															        $$->nextlist = $4->falselist;

															        //////////////printf(" RULE:\titeration_statement \t->\t while(expression) statement\n");
															        }
		| DO M statement M WHILE '(' expression ')' 			{//done test
																	$$ = new expr_attr;
															        Q_arr->convInt2Bool($7);
															        Q_arr->backpatch($3->nextlist, $4->instr);
															        Q_arr->backpatch($7->truelist, $2->instr);
															        $$->nextlist = $7->falselist;

															        //////////////printf(" RULE:\titeration_statement \t->\t do statement while (expression)\n");
															        }
		| FOR '(' expression SCOL M expression SCOL M expression N ')' M statement 
																				{//done test
    
        
																				$$ = new expr_attr;
    
																		        Q_arr->emit("","","", OP_GOTO);
																		        Q_arr->backpatch(makelist(Q_arr->index-1),$8->instr);    //
																		        Q_arr->convInt2Bool($6);

																		        Q_arr->backpatch($10->nextlist,$5->instr);//
																		        Q_arr->backpatch($6->truelist,$12->instr);//
																		        Q_arr->backpatch($13->nextlist,$8->instr);
																		    
																		        $$->nextlist = $6->falselist;//
																		        
																				//////////////printf(" RULE:\titeration_statement \t->\t for(expression;expression;expression)\n");
																				}


		| FOR '(' SCOL M expression N SCOL M expression N ')' M statement {

																				$$ = new expr_attr;    
																		        Q_arr->emit("","","", OP_GOTO);
																		        Q_arr->backpatch(makelist(Q_arr->index-1),$8->instr);    //
																		        Q_arr->backpatch($6->nextlist, Q_arr->index);
																		        Q_arr->convInt2Bool($5);

																		        Q_arr->backpatch($10->nextlist,$4->instr);//
																		        Q_arr->backpatch($5->truelist,$12->instr);//
																		        Q_arr->backpatch($13->nextlist,$8->instr);
																		    
																		        $$->nextlist = $5->falselist;//
																		        
																				//////////////printf(" RULE:\titeration_statement \t->\t for(;expression;expression)\n");
		}

		;
jump_statement
		:GOTO IDENTIFIER SCOL 										{//////////////printf(" RULE:\tjump_statement \t->\t goto identifier;\n");
		}
		| CONTINUE SCOL 											{//////////////printf(" RULE:\tjump_statement \t->\t continue;\n");
		}
		| BREAK SCOL 												{//////////////printf(" RULE:\tjump_statement \t->\t break;\n");
		}
		| RETURN SCOL 												{//done
																	$$ = new expr_attr;

															        if(curr_symbol_table->lookup("retVal")->type== VOID_)
															        {
															            Q_arr->emit("","","",OP_RETURN_VOID);
															        }
															        
															        //////////////printf(" RULE:\tjump_statement \t->\t return;\n");
															        }
		| RETURN expression SCOL 									{
																		 $$ = new expr_attr;
																        data_type type1, type2, type3;
																        type1 = curr_symbol_table->lookup("retVal")->type;
																        type2 = curr_symbol_table->lookup($2->name)->type;
																        type3 = curr_symbol_table->lookup($2->name)->type;
																        /*for(int i=0; i<sym->no_of_entries;i++)
																		{
																			if(sym->sym_table[i].id.compare($2->name)==0)
																				type3 = sym->sym_table[i].type;
																		}*/
																	if(type3 == FUNCTION_)
																	{	
																		string t = curr_symbol_table->gen_temp(type1);
																		Q_arr ->emit(t, $2->name, "", OP_COPY);
																		Q_arr->emit(t,"","", OP_RETURN);
																	}
																	else
																        {
																            Q_arr->emit( $2->name, "", "", OP_RETURN);
																        }
																	
																	//////////////printf(" RULE:\tjump_statement \t->\t return expression;\n");
																	}
		;

translation_unit
		:external_decalaration 										{GT->name = string("Global Table");//////////////printf(" RULE:\ttranslation_unit \t->\t external_decalaration\n");
		}
		| translation_unit external_decalaration 					{//////////////printf(" RULE:\ttranslation_unit \t->\t translation_unit external_decalaration\n");
		}
		;

external_decalaration
		:function_definition 								{//////////////printf(" RULE:\texternal_decalaration \t->\t function_definition\n");
		}
		| declaration 										{//////////////printf(" RULE:\texternal_decalaration \t->\t declaration\n");
		}
		;

function_definition
		:declaration_specifiers declarator compound_statement 			{//incomplete
																	        symbol_table_entry *ret;
																	        
																	        expr_attr *new_dec = $2;
																	        data_type type = $1.type;

																	        Q_arr -> emit( $2->name ,"","", _FUNCTION_END);
																	        symbol_table_entry *func = GT->lookup($2->name);

																	        if(func->nested_table != NULL)
																	        {
																	            if(func -> type == PTR_)
																	            {
																	            	type = PTR_;
																	            }
																	            ret = func->nested_table->lookup("retVal");
																	            ret->type = type;
																	            ret->offset = curr_symbol_table->offset;
																	            ret->size = size_of_type(type);
																	        }
																	        curr_symbol_table = GT;
																	        $$ = $2;

      																		  //////////////printf(" RULE:\tfunction_definition \t->\t declaration_specifiers declarator compound_statement\n");
      																		}
		| declaration_specifiers declarator declaration_list compound_statement  {//////////////printf(" RULE:\tfunction_definition \t->\t declaration_specifiers declarator declaration_list compound_statement\n");
		}
		;

declaration_list
		:declaration  												{//////////////printf(" RULE:\tdeclaration_list \t->\t declaration\n");
		}
		| declaration_list declaration 								{//////////////printf(" RULE:\tdeclaration_list \t->\t declaration_list declaration\n");
		}
		;

%%
void yyerror(const char* s)
{
	//cout << s<<endl;
}
