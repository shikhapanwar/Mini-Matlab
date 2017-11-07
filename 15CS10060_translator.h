#ifndef __ASS6_14CS10060_TRANSLATOR_H
#define __ASS6_14CS10060_TRANSLATOR_H
#include <bits/stdc++.h>
using namespace std;

#define SIZE_OF_VOID 0
#define SIZE_OF_CHAR 1
#define SIZE_OF_INT 4
#define SIZE_OF_DOUBLE 8
#define SIZE_OF_BOOL 1
#define SIZE_OF_POINTER 4
#define SIZE_OF_FUNCTION 0
#define SIZE_OF_UNKNOWN 0

class symbol_table;
struct matrix;
enum data_type
{
	VOID_ = 1,
	CHAR_,
	INT_,
	DOUBLE_,
	PTR_,
	MATRIX_,
	FUNCTION_,
	BOOL_,
	UNKNOWN_
	//STRING_ // to be done
};

struct matrix
{
	string *dim1;
	string *dim2;
	data_type type;
	int *arr_int;
	double arr_double[100][100];
	char *arr_char;

/*
	int arr_int[200][200];
	double arr_double[200][200];
	char arr_char[200][200];

	matrix()
	{

		arr_char = new char[200];
		arr_double = new double [200];
		arr_int = new int[200];
	}
*/	
};
union init_value
{
	double init_double; 
	int init_int;
	//void init_void;
	char init_char;
	matrix *init_matrix;
	int *ptr;

};
//enum op_code;

struct declar_list ;// used for init_declarator_list
struct declar; // type_specifiers  declaration_specifiers
struct expr_attr ;//direct_declarator initializer declarator
struct func_param;
struct func_param_list;
struct expr_row_list;
struct expr_row;

class symbol_table_entry ;
class quad_array;
class quad;

class symbol_table
{
public:
		string name;
		int tmp_cnt = 0;
		vector<symbol_table_entry> table;
		int offset = 0;
		symbol_table_entry * lookup(string identifier_name); //
		string gen_temp(data_type t); // generates temp, inserts into table and returns back the pointer to the symbol table entry
		symbol_table_entry * update(string name_of_identifier, data_type t, init_value i, int sz, symbol_table *nes);
		 // to be completed
		void print(); // prints the table

};



	//binary operators
	//unary operators
	//copy assignment
	//unconditional jump
	//conditional  jump - value based
	//consitional jump - comparison based
	//procedure call
	//return value
	//indexed copy instruction
	//addr and pointer assignment

	enum op_code{
	//binary operators.
	OP_PLUS = 1,
	OP_MINUS,
	OP_MULT,
	OP_DIVIDE,
	OP_AND,
	OP_MODULO,
	OP_SHIFT_LEFT,
	OP_SHIFT_RIGHT,
	OP_XOR,
	OP_OR,
	OP_LOGICAL_AND,
	OP_LOGICAL_OR,
	OP_LESS,
	OP_GREATER,
	OP_IS_EQUAL,
	OP_NOT_EQUAL,
	OP_LESS_EQUAL,
	OP_GREATER_EQUAL,

	//unary operators.
	OP_UNARY_PLUS,
	OP_UNARY_MINUS,
	OP_AMPERSAND,
	OP_STAR,

	//Conditional jump operators.
	OP_IF_LESS,
	OP_IF_GREATER,
	OP_IF_LESS_EQUAL,
	OP_IF_GREATER_EQUAL,
	OP_IF_IS_EQUAL,
	OP_IF_NOT_EQUAL,
	OP_IF_EXPRESSION,
	OP_IF_NOT_EXPRESSION,
	//Unconditional jump.
	OP_GOTO,

	//assignment operator.
	OP_COPY,

	//matrix Access and Dereferencing.
	OP_MATRIX_ACCESS,
	OP_MATRIX_DEREFERENCE,

	//Procedure Call.
	OP_CALL,
	OP_PARAM,

	//Return Value
	OP_RETURN_VOID,
	OP_RETURN,

	//Address and Pointer Assignment Instructions.
	OP_REFERENCE,
	OP_DEREFERENCE,
	OP_POINTER_ASSIGNMENT,

	//Function opcodes.
	_FUNCTION_START,
	_FUNCTION_END,

	//Inc and Dec operators.
	_INCREMENT,
	_DECREMENT,

	//type conversion
	OP_C2I,
	OP_C2D,
	OP_I2C,
	OP_D2C,
	OP_I2D,
	OP_D2I

	
};
list<int> makelist(int index);
list<int> merge(list<int> a, list<int> b);


class symbol_table_entry 
{
	public:
		string name;
		data_type type;
		init_value initial_value;
		int size = 0;
		int offset = 0;
		symbol_table *nested_table;
		symbol_table_entry ()
		{
			initial_value.ptr = NULL;
			nested_table = NULL;
		}


};

class quad_array
{
public:
	std::vector<quad> array;

	int index = 0;


	quad* emit(string res, string a1, string a2, op_code operat);
	quad* emit(string res, string a1, op_code operat);
	quad* emit(string res, string a1);  // should not be used , use copy as op
	void print();

	void convD2I(expr_attr *e1, expr_attr *e2);
	void convD2C(expr_attr *e1, expr_attr *e2);
	void convI2D(expr_attr *e1, expr_attr *e2);
	void convI2C(expr_attr *e1, expr_attr *e2);
	void convC2I(expr_attr *e1, expr_attr *e2);
	void convC2D(expr_attr *e1, expr_attr *e2);

		//function responsible for backpatch
	void backpatch(list<int> bp_list, int i);
	void convInt2Bool(expr_attr *e);


};

class quad
{
public:
	int index;
	op_code op;
	string arg1; // can be constant as well as check properly
	string arg2; //name as in symbol tabel entry
	string result; // name as in symbol table entry


};

struct expr_row_list
{
	std::vector<expr_row> vec;
	data_type type;
};
struct expr_row
{
	std::vector<expr_attr> vec;
	data_type type ;
};
struct declar_list // used for init_declarator_list
{
	std::vector<expr_attr> vec;
	int type;
	int width;

};
struct declar // type_specifiers  declaration_specifiers
{
	int width;
	data_type type; 
};
struct expr_attr //direct_declarator initializer declarator 
{
	symbol_table_entry *addr;
	string name;
	list<int> truelist, falselist, nextlist;
	int instr;
	int no_of_params;
	bool isPointer = false;
	bool is_function = false;
	bool is_matrix = false;
	int int_val;
	double double_val;
	string matrix_base = "";
	string offset_for_matrix = "";

	expr_row_list *row_list = NULL; // to deal with initializer->{initializer row list}
};

class operator_type
{
public :
	bool multa =false;
	bool assign = false; 
bool diva =false;
bool rema =false;
bool plusa =false;
bool minusa =false;
bool lsa =false;
bool rsa =false;
bool anda =false;
bool powa =false;
bool ora =false;

};

class func_param //parameter_declaration = func_param
{
public:
	string name;
	data_type type;
	bool isPointer =false;

};
class func_param_list // parameter_list = *func_param_list
{
public:
	std::vector<func_param> vec;
};

string type_string(data_type t);
int size_of_type(data_type t);
string op_code_string(op_code operat);
list<int> my_merge(list<int> a, list<int> b);

bool typeCheck(expr_attr * e1, expr_attr * e2, bool isAssignment);
bool convert_type(expr_attr *e, data_type t1, data_type t2);

#endif
