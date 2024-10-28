CC=gcc
ASM=nasm

CFLAGS=
ASMFLAGS=
INCLUDES=

SRC_DIR=src
OUT_DIR=build
INT_DIR=build/int

BOOT_SRCS:=$(shell find $(SRC_DIR)/boot -name "*.asm")
BOOT_OBJS:=$(patsubst $(SRC_DIR)/%.asm, $(INT_DIR)/%.o, $(BOOT_SRCS))

KERNEL_ASM_SRCS:=$(shell find $(SRC_DIR)/kernel -name "*.asm")
KERNEL_ASM_OBJS:=$(patsubst $(SRC_DIR)/%.asm, $(INT_DIR)/%.o, $(KERNEL_ASM_SRCS))
KERNEL_C_SRCS:=$(shell find $(SRC_DIR)/kernel -name "*.c")
KERNEL_C_OBJS:=$(patsubst $(SRC_DIR)/%.c, $(INT_DIR)/%.o, $(KERNEL_C_SRCS))
KERNEL_OBJS:=$(KERNEL_ASM_OBJS) $(KERNEL_C_OBJS)

.PHONY: all run clean

all: $(OUT_DIR)/kikios.img

run: $(OUT_DIR)/kikios.img
	@printf "\nRunning KikiOS...\n"
	qemu-system-x86_64 -drive file=$<,format=raw

clean:
	rm -rf $(OUT_DIR)

$(OUT_DIR)/kikios.img: $(INT_DIR)/boot.bin $(INT_DIR)/kernel.bin
	@echo "Building $@"
	@dd if=/dev/zero of=$@ bs=512 count=65536 # 32 MiB size file
	@mkfs.fat -F 16 -S 512 -s 1 -g 16/63 -R 3 -n "KikiOS Vol" $@ # Make FAT16 fs
	@dd if=$(INT_DIR)/boot.bin of=$@ obs=1 ibs=1 oseek=62 iseek=62 conv=notrunc 
	@mcopy -i $@ $(INT_DIR)/kernel.bin "::kernel.bin"

$(INT_DIR)/boot.bin: $(BOOT_OBJS)
	@echo "Linking $@"
	@ld -n -T $(SRC_DIR)/boot/linker.ld -o $@ $^

$(BOOT_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(dir $@)
	@echo "Making $@"
	@$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<

$(INT_DIR)/kernel.bin: $(KERNEL_OBJS)
	@echo "Linking $@"
	@ld -n -T $(SRC_DIR)/kernel/linker.ld -o $@ $^

$(KERNEL_C_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@) 
	@echo "Making $@"
	@$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 

$(KERNEL_ASM_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p $(dir $@) 
	@echo "Making $@"
	@$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<

