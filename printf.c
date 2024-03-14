#include <stdio.h>

extern int print_format(char *format_str, ...);

int main(void)
{
    char str[] = "aboba";
    int n_chars = print_format("%d %s %h %d%%%c%b\n", -1, "love", 3802, 100, 33, 30);

    print_format("\n"
                 "________________\n"
                 "n chars written: %d\n"
                 "________________\n", n_chars);
}