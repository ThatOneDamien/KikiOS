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

# ASM_SRCS:=$(shell find $(SRC_DIR) -name "*.asm")
# ASM_OBJS:=$(patsubst $(SRC_DIR)/%.asm, $(INT_DIR)/%.o, $(ASM_SRCS))
# ASM_SRCS:=$(shell find $(SRC_DIR) -name "*.c")
# C_OBJS:=$(patsubst $(SRC_DIR)/%.c, $(INT_DIR)/%.o, $(C_SRCS))
# OBJS:=$(ASM_OBJS) $(C_OBJS)

.PHONY: all run clean

all: $(OUT_DIR)/kikios.img

run: $(OUT_DIR)/kikios.img
	@printf "\nRunning KikiOS...\n"
	qemu-system-x86_64 -drive file=$<,format=raw

clean:
	rm -rf $(OUT_DIR)

$(OUT_DIR)/kikios.img: $(INT_DIR)/boot.bin
	@echo "Combining $@"
	@dd if=/dev/zero of=$@ bs=512 count=65536 # 32 MiB size file
	@mkfs.fat -F 16 -S 512 -s 1 -g 16/63 -R 2 -n "KikiOS Vol" $@ # Make FAT16 fs
	@dd if=$< of=$@ obs=1 ibs=1 oseek=62 iseek=62 conv=notrunc 


$(INT_DIR)/boot.bin: $(BOOT_OBJS)
	@echo "Linking $@"
	@ld -n -T $(SRC_DIR)/boot/linker.ld -o $@ $^

$(BOOT_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.asm
	@mkdir -p build/int/boot
	@echo "Making $@"
	@$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<

# $(C_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.c
# 	$(CC) $(CFLAGS) $(INCLUDES) -o $@ -c $< 
#
# $(ASM_OBJS): $(INT_DIR)/%.o: $(SRC_DIR)/%.asm
# 	$(ASM) $(ASMFLAGS) -f elf64 -o $@ $<

