ENTRY(kernel_start)
OUTPUT_FORMAT(binary)

SECTIONS 
{
    . = 0x10000;
    .kernel_entry : {*(.kernel_entry)}
    .text : {*(.text)}
    .data : {*(.data)}
    .rodata : {*(.rodata)}
    .bss : {*(.bss)}
}
