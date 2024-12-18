include Makefile.vars

.PHONY: all run clean disk_img kernel bootloader#tools diskpart

all: disk_img

run: disk_img
	@printf "\nRunning KikiOS...\n\n"
	@qemu-system-x86_64 -drive file=$(DISK_IMG),format=raw

clean:
	rm -rf $(OUT_DIR)


disk_img: $(DISK_IMG)

$(DISK_IMG): $(KERNEL_BIN) $(BOOT_BIN)
	@dd if=/dev/zero of=$@ bs=512 count=65536 &> /dev/null # 32 MiB size file
	@mkfs.fat -F 16 -S 512 -s 1 -g 16/63 -R 4 -n "KikiOS Vol" $@ &> /dev/null # Make FAT16 fs
	@dd if=$(BOOT_BIN) of=$@ obs=1 ibs=1 oseek=62 iseek=62 conv=notrunc &> /dev/null
	@mcopy -i $@ $(KERNEL_BIN) "::kernel.bin"
	@echo "--> Created disk image: $@"

kernel: $(KERNEL_BIN)
bootloader: $(BOOT_BIN)
tools: $(DISKPART_EXE)

include boot/Makefile
include kernel/Makefile
include tools/Makefile
