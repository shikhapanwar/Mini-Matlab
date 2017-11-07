
a.out : lex.yy.c y.tab.c 15CS10060_translator.h 15CS10060_translator.cxx
	g++  -std=c++11   15CS10060_translator.cxx y.tab.c lex.yy.c ass5_15CS10060_target_translator.cxx -lfl -o a.out 

y.tab.c: 15CS10060.y lex.yy.c
	yacc 15CS10060.y
lex.yy.c: 15CS10060.l y.tab.h
	flex 15CS10060.l
y.tab.h: 15CS10060.y
	yacc -dtv 15CS10060.y 

clean:
	rm a.out y.tab.h y.tab.c lex.yy.c y.output
