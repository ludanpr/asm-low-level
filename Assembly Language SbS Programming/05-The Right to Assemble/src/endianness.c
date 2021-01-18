/*
 * Use a debugger like gdb to see endianness of your architecture.
 *
 * In gdb:
 * x/4x &variable
 */
#include <stdio.h>

int main(void)
{
    unsigned int variable = 0x5361;

    printf("%u\n", variable);

    return 0;
}
