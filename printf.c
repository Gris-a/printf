#include <stdio.h>
#include <limits.h>

extern int print_format(char *format_str, ...);

int main(void)
{
    char str[] = "aboba";
    int n_chars = print_format("%h\n", 0);

    print_format("\n"
                 "________________\n"
                 "n chars written: %d\n"
                 "________________\n", n_chars);
}