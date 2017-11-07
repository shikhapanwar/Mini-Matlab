#include "15CS10060_translator.h"
extern int yyparse();
extern quad_array *Q_arr;
extern	symbol_table *GT;
extern	symbol_table *curr_symbol_table;

int main()
{
	yyparse();
	
	cout <<"Printing Q_arr"<<endl;
	Q_arr->print();
}
