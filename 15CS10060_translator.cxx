#include "15CS10060_translator.h"
extern symbol_table *curr_symbol_table;
symbol_table_entry * symbol_table::lookup(string identifier_name)
{
	int i ;
	int n = table.size();
	symbol_table_entry tmp;
	for(i = 0 ; i < n ; i ++)
	{
		if(table[i].name == identifier_name) 
			{
				//cout <<identifier_name<<" found at "<<i<<endl<<this<<endl;
				return &table[i];
			}

	}
	tmp.name = identifier_name;
	tmp .type = UNKNOWN_;
	init_value x;
	x.init_int = 0;
	tmp.initial_value = x;
	tmp.offset = this->offset;
	tmp.nested_table = NULL;
	 // to be done
	table.push_back(tmp);
	//cout <<endl<<"adding id "<<identifier_name<<endl<<endl;
	return &table[i] ;
}

int size_of_type(data_type t)
{
	switch(t)
	{
		case VOID_ : return SIZE_OF_VOID; break;
		case CHAR_ : return SIZE_OF_CHAR; break;
		case INT_ : return SIZE_OF_INT; break;
		case DOUBLE_ : return SIZE_OF_DOUBLE; break;
		case PTR_ : return SIZE_OF_POINTER; break;
		case MATRIX_ : return 0; break; // to be doe allot size
		case FUNCTION_ : return SIZE_OF_FUNCTION; break;
		case BOOL_ : return SIZE_OF_BOOL; break;
		case UNKNOWN_ : return SIZE_OF_UNKNOWN; break;
	}

}

symbol_table_entry * symbol_table::update(string name_of_identifier, data_type t, init_value i, int sz, symbol_table *nes)
{
	//cout <<"\n\nUpdating "<<name_of_identifier<<"'s data_type' to "<<type_string(t)<<endl<<endl;
	symbol_table_entry *tmp =this -> lookup(name_of_identifier);
	tmp -> type = t;
	tmp -> initial_value = i;
	if(t != MATRIX_ )tmp -> size = size_of_type(t);
	else tmp->size = sz;
	tmp -> nested_table = nes;

	return tmp;
}

string  symbol_table::gen_temp(data_type t)
{
	symbol_table_entry tmp;
	string s = "t"+to_string(tmp_cnt); /*to be done, append a number that gets increamented*/
	tmp_cnt ++;
	tmp.name = s;
	tmp.type = t;
	tmp.offset = offset;
	tmp.nested_table = NULL; // to be done, will not work for 
	switch(t)
	{
		case VOID_ : tmp.size = SIZE_OF_VOID; break;
		case CHAR_ : tmp.size = SIZE_OF_CHAR; break;
		case INT_ : tmp.size = SIZE_OF_INT; break;
		case DOUBLE_ : tmp.size = SIZE_OF_DOUBLE; break;
		case PTR_ : tmp.size = SIZE_OF_POINTER; break;
		case MATRIX_ : tmp.size = 0; break; // to be doe allot size
		case FUNCTION_ : tmp.size = SIZE_OF_FUNCTION; break;
		case BOOL_ : tmp.size = SIZE_OF_BOOL; break;
		case UNKNOWN_ : tmp.size = SIZE_OF_UNKNOWN; break;

	}

	offset = offset  + tmp.size;
	//cout <<"offset changed to "<<offset<<endl;
	table.push_back(tmp);

	return s;

}

string type_string(data_type t)
{
	switch(t)
	{

		case VOID_ : return "VOID";
		case CHAR_: return "CHAR";
		case INT_: return "INT";
		case DOUBLE_: return "DOUBLE_";
		case PTR_: return "Pointer";
		case MATRIX_: return "MATRIX";
		case FUNCTION_: return "FUNCTION";
		case BOOL_: return "BOOL";
		case UNKNOWN_ : return "UNKNOWN";
		default :return "NONE";
	}
}

void symbol_table :: print()
{//incomplete
	cout <<"\t\t\tPrinting table "<<name<<endl;
	int i;
	this->offset = 0;
	cout <<"Index\tname\ttype\tinitial_val\tsize\toffset\tnestedTable"<<endl;
	for (i = 0; i < table.size(); ++i)
	{
		table[i].size = size_of_type(table[i].type);
		cout << i<<"\t"<<table[i].name <<"\t"<<type_string(table[i].type)<<"\t";
		//table[i].initial_value<<"\t"<<
		switch(table[i].type)
		{
			case CHAR_ : cout << table[i].initial_value.init_char; break;
			case INT_ 	: cout <<table[i].initial_value.init_int; break;
			case DOUBLE_ 	: cout <<table[i].initial_value.init_double ; break;
			case MATRIX_ 	: {		//cout <<	"val0 = "<<(table[i].initial_value.init_matrix.arr_double)[0]<<endl;//" "<<table[i].initial_value.init_matrix.arr_int<<endl;
									
												int j, k;
												int n = this->lookup( * (table[i].initial_value.init_matrix -> dim1))->initial_value.init_int;
												int m = this->lookup( * (table[i].initial_value.init_matrix ->dim2))->initial_value.init_int;
												//cout <<n<<" "<<m<<endl;
												//cout << *(table[i].initial_value.init_matrix -> dim2)<<endl;
												cout <<"{";
												for(k = 0; k < n; k ++)
												{
													for (j = 0 ; j <m-1 ; j ++)
													{
														cout << table[i].initial_value.init_matrix->arr_double[k][j] <<", ";
														
													}
													cout << table[i].initial_value.init_matrix->arr_double[k][j];
													cout <<";" ;
												}
												cout <<"}";

												break;
											
								

								}
			default: cout << 0;


		}
		cout << "\t\t" << table[i].size <<"\t"<<table[i].offset<<"\t"<<table[i].nested_table<<endl;
		//this->offset += size_of_type(table[i].type);
	}

	for(i = 0; i < table.size(); ++i )
	{
		if(table[i].nested_table != NULL) table[i].nested_table -> print();
	}
	return;
}


string op_code_string(op_code operat)
{
	switch(operat)
	{
		
	case (OP_PLUS) :  return string("PLUS");
	case  (OP_MINUS):	return string( "MUNUS");
	case (OP_MULT):		return string ("MULT");
	case (OP_DIVIDE):	return string ("DIVIDE");
	case (OP_AND):	return string ("AND");
	case (OP_MODULO) : return string ("MODULO");
	case (OP_SHIFT_LEFT) : return string ("SHIFT_LEFT");
	case (OP_SHIFT_RIGHT) : return string ("SHIFT_RIGHT");
	case (OP_XOR) : return string ("XOR");
	case (OP_OR):return string ("OR");
	case (OP_LOGICAL_AND) : return string ("LOGICAL_AND");
	case (OP_LOGICAL_OR) : return string ("LOGICAL_OR");
	case (OP_LESS) :  return string ("LESS");
	case (OP_GREATER) : return string ("GREATER");
	case (OP_IS_EQUAL) : return string ("IS_EQUAL");
	case (OP_NOT_EQUAL) : return string ("NOT_EQUAL");
	case (OP_LESS_EQUAL) : return string ("LESS_EQUAL");
	case (OP_GREATER_EQUAL) : return string ("GREATER_EQUAL");

	//unary operators.
	case (OP_UNARY_PLUS) : return string ("UNARY_PLUS");
	case (OP_UNARY_MINUS):return string ("UNAR_MINUS");
	case (OP_AMPERSAND):return string ("AMPERSAND");
	case (OP_STAR):return string ("STAR");

	//Conditional jump operators.
	case (OP_IF_LESS):return string ("JUMP_IF_LESS");
	case (OP_IF_GREATER):return string ("JUMP_IF_GREATER");
	case (OP_IF_LESS_EQUAL):return string ("JUMP_IF_EQUAL");
	case (OP_IF_GREATER_EQUAL):return string ("JUMP_IF_GREATER_EQUAL");
	case (OP_IF_IS_EQUAL):return string ("JUMP_IF_IS_EQUAL");
	case (OP_IF_NOT_EQUAL):return string ("JUMP_IF_NOT_EQUAL");
	case (OP_IF_EXPRESSION):return string ("IF_EXPRESSION");
	case (OP_IF_NOT_EXPRESSION):return string ("IF_NOT_EXPRESSION");
	//Unconditional jump.
	case (OP_GOTO):return string ("GOTO");

	//assignment operator.
	case (OP_COPY):return string ("COPY");

	//Array Access and Dereferencing. string
	case (OP_MATRIX_ACCESS):return string ("MATRIX_ACCESS");
	case (OP_MATRIX_DEREFERENCE):return string ("MATRIX_DEREFERENCE");

	//Procedure Call. string
	case (OP_CALL):return string ("CALL");
	case (OP_PARAM):return string ("PARAM");

	//Return Value
	case (OP_RETURN_VOID):return string ("RETURN_VOID");
	case (OP_RETURN):return string ("RETURN");

	//Address and Pointer Assignment Instructions.
	case (OP_REFERENCE):return string ("REFERENCE");	
	case (OP_DEREFERENCE):return string ("DEREFERENCE");
	case (OP_POINTER_ASSIGNMENT):return string  ("POINTER_ASSIGNMENT");

	//Function opcodes.
	case (_FUNCTION_START):return string ("FUNCTION_START");
	case (_FUNCTION_END):return string ("FUNCTION_END");

	//Inc and Dec operators.
	case (_INCREMENT):return string  ("INCREMENT");
	case (_DECREMENT):return string ("DECREMENT");

	//type conversion
	case (OP_C2I):return string ("C2I");
	case (OP_C2D):return string ("C2D");
	case (OP_I2C):return string ("I2C");
	case (OP_D2C):return string ("D2C");
	case (OP_I2D):return string ("I2D");
	case (OP_D2I):return string ("D2I");
	default : return string("op not found");
	}
}


//type conversions
void quad_array :: convD2I(expr_attr * e1, expr_attr *e2)
{
	
	if(curr_symbol_table->lookup(e2 -> name) -> type== INT_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type = INT_;
		emit(e1->name, e2->name, OP_D2I);
	}
}

void quad_array :: convD2C(expr_attr * e1, expr_attr *e2)
{
	if(curr_symbol_table->lookup(e2 -> name) -> type== CHAR_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type =CHAR_;
		emit(e1->name, e2->name, OP_D2C);
	}
}


void quad_array :: convI2D(expr_attr * e1, expr_attr *e2)
{
	if(curr_symbol_table->lookup(e2 -> name) -> type== DOUBLE_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type = DOUBLE_;
		emit(e1->name, e2->name, "", OP_I2D);
	}
}

void quad_array :: convI2C(expr_attr * e1, expr_attr *e2)
{
	if( curr_symbol_table->lookup(e2 -> name) -> type == CHAR_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type = CHAR_;
		emit(e1->name, e2->name, "", OP_I2C);
	}


}

void quad_array :: convC2D(expr_attr * e1, expr_attr *e2)
{
	if(curr_symbol_table->lookup(e2 -> name) -> type == DOUBLE_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type = DOUBLE_;
		emit(e1->name, e2->name, "", OP_C2D);
	}

	
}

void quad_array :: convC2I(expr_attr * e1, expr_attr *e2)
{
	if(curr_symbol_table->lookup(e2 -> name) -> type== INT_)
		return;
	else
	{
		e1 = e2;
		curr_symbol_table->lookup(e1 -> name) -> type = INT_;
		emit(e1->name, e2->name, "", OP_C2I);
	}


}


void quad_array :: convInt2Bool(expr_attr *exp)
{
	data_type bool_type;
	bool_type = BOOL_;
	if( curr_symbol_table -> lookup(exp->name)->type== BOOL_)
		return;
	else
	{
		backpatch(exp->truelist, index);
		backpatch(exp->falselist,index);
		exp->falselist = makelist(index);
		emit("",exp->name,"", OP_IF_NOT_EXPRESSION);
		//emit(COPY, exp->loc, "~1","");
		exp->truelist = makelist(index);
		emit("","","", OP_GOTO);
	}
	curr_symbol_table -> lookup(exp->name)->type = BOOL_;

}

void quad_array :: backpatch(list<int> bp_list, int i)
{
	string s = to_string(i);
	list<int>::iterator it;
	for(it = bp_list.begin(); it != bp_list.end(); it++)
	{
		array[*it].result = s; 
	}
}



quad* quad_array::emit(string res, string a1, string a2, op_code operat)
{	
	//if(operat == OP_GOTO) cout<< "\n\n\n\n\n"<<"goto here"<<endl;
	quad tmp;
	tmp.result = res;
	tmp.arg1 = a1;
	tmp.arg2 = a2;
	tmp.op = operat;
	(this->array).push_back(tmp);
	this->index ++;
	return &(this->array [(this->array).size() - 1] ) ;
}
quad* quad_array::emit(string res, string a1, op_code operat)
{
	quad tmp;
	tmp.result = res;
	tmp.arg1 = a1;
	//tmp.arg2 = arg2;
	tmp.op = operat;
	(this->array).push_back(tmp);
	this->index ++;

	return &(this->array [(this->array).size() - 1] ) ;
}
quad* quad_array::emit(string res, string a1)
{
	quad tmp;
	tmp.result = res;
	tmp.arg1 = a1;
	(this->array).push_back(tmp);
	this->index ++;
	return &(this->array [(this->array).size() - 1] ) ;
}
void quad_array::print() /*to be done, the unary ioperators should not print arg2 and copy should not print op too , right now printing all*/
{
	int i ;
	int n = this->array.size();

	cout << "Index\top" <<"\t"<<"Result" <<"\targ1"<<"\targ2"<<endl;

	for(i = 0 ; i < n ; i++)
	{
		cout << i<<"\t"<<op_code_string(array[i].op)<<"\t"<<array[i].result <<"\t"<<array[i].arg1 <<"\t"<<array[i].arg2<<endl;
	}
	return;
}


bool typeCheck(expr_attr * e1, expr_attr * e2, bool isAssignment = false)
{
	if(e1->addr->type == e2 -> addr -> type)
	{
		return true;
	}
	else if(isAssignment == true)  // e1 = e2
	{
		if ( convert_type(e2, curr_symbol_table->lookup(e2 -> name) -> type ,curr_symbol_table->lookup(e1 -> name) -> type) == 1 ) // converting bigger to smaller
			return true;
		else return false;
	}
	else
	{
		if(e1->addr->type > e2 -> addr -> type)
		{
			if(convert_type(e2, curr_symbol_table->lookup(e2 -> name) -> type , curr_symbol_table->lookup(e1 -> name) -> type) == 1) // converting bigger to smaller
				return true;
			else return false;
		}
		else
		{
			if(convert_type(e1, curr_symbol_table->lookup(e1 -> name) -> type , curr_symbol_table->lookup(e2 -> name) -> type) == 1) // converting bigger to smaller
				return true;
			else return false;
		}

	}

}

bool convert_type(expr_attr *e, data_type t1, data_type t2)
{
			switch(t1)
			{
				case CHAR_:	{
								switch(t2)
								{
									case CHAR_:	{
													return true;

												}
									case INT_:	{
													e-> addr -> type = INT_;
													int x = (e -> addr -> initial_value).init_char;
													(e -> addr -> initial_value). init_int =x ;
													return true;
												}
									case DOUBLE_:{

												}

								}
								break;
							}
				default : return false;

			}
}


list<int> makelist(int index)
{
    list<int> temp;
    temp.push_back(index);
    return temp;
}

list<int> my_merge(list<int> a, list<int> b)
{
	//cout << "fghtyjt"<<endl;
    list<int> temp;
    //cout <<"check1"<<endl;
    temp.merge(a);
    //cout <<"check2"<<endl;
    temp.merge(b);
    //cout <<"check1"<<endl;
    return temp;
}
