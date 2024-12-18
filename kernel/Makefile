CFLAGS=-ffreestanding -mno-red-zone -Wall -Wextra -DKIKI_DEBUG

KERNEL_ASM_SRCS:=$(shell find $(KERNEL_SRC) -name "*.asm")
KERNEL_ASM_OBJS:=$(patsubst %.asm, $(OUT_DIR)/asm/%.o, $(KERNEL_ASM_SRCS))

KERNEL_C_SRCS:=$(shell find $(KERNEL_SRC) -name "*.c")
KERNEL_C_OBJS:=$(patsubst %.c, $(OUT_DIR)/c/%.o, $(KERNEL_C_SRCS))

$(KERNEL_BIN): $(KERNEL_ASM_OBJS) $(KERNEL_C_OBJS)
	@$(LD) -T $(KERNEL_SRC)/linker.ld -o $@ $(KERNEL_ASM_OBJS) $(KERNEL_C_OBJS) -nostdlib
	@echo "--> Linked $@"

$(KERNEL_C_OBJS): $(OUT_DIR)/c/%.o: %.c
	@mkdir -p $(@D) 
	@$(CC) $(INCLUDES) -o $@ -c $< $(CFLAGS)
	@echo "$^"

$(KERNEL_ASM_OBJS): $(OUT_DIR)/asm/%.o: %.asm
	@mkdir -p $(@D) 
	@$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<
	@echo "$^"
