OUTPUT_FORMAT(binary)

SECTIONS 
{
    . = 0x10000;
    .kernel_entry : {*(.kernel_entry)}
    .text : {*(.text)}
    .bss : {*(.bss)}
    .data : {*(.data)}
    .rodata : {*(.rodata)}
}
