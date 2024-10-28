void __attribute__((section(".kernel_entry"))) kernel_start()
{
    unsigned long long* a = (unsigned long long*)0xb8000;
    *a = 0x1F4B1F4B1F4B1F4B;
    asm("hlt");
}
