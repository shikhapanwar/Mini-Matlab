int add(int a, int b)
{
	return a + b;
}

int main()
{
	int a = 9, b = 18;
	int c = add(a, b);
	switch(c <20) c = c*2;
	switch( c >= 20 ) c = c +2;

	return 0;
}
