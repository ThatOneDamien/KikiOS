BOOT_SRCS:=$(shell find $(BOOT_SRC) -name "*.asm")
BOOT_OBJS:=$(patsubst %.asm, $(OUT_DIR)/%.o, $(BOOT_SRCS))

$(BOOT_BIN): $(BOOT_OBJS)
	@$(LD) -nostdlib -T $(BOOT_SRC)/linker.ld -o $@ $^
	@echo "--> Linked $@"

$(BOOT_OBJS): $(OUT_DIR)/%.o: %.asm
	@mkdir -p $(@D)
	@$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<
	@echo "$^"
