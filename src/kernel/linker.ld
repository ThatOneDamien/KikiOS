OUTPUT_FORMAT(binary)

INCLUDE "build/env.ld"

SECTIONS 
{
    . = 0x10000;
    .kernel_entry : {*(.kernel_entry)}
    .text : {*(.text)}
    .bss : {*(.bss)}
    .data : {*(.data)}
    .rodata : {*(.rodata)}
}
