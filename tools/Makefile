HOST_CC=gcc
HOST_CFLAGS=-Werror -Wall -O3 

DISKPART_SRCS=$(shell find tools/diskpart -name "*.c")
DISKPART_OBJS=$(patsubst %.c, $(OUT_DIR)/c/%.o, $(DISKPART_SRCS))

$(DISKPART_EXE): $(DISKPART_OBJS)
	@$(HOST_CC) $(HOST_CFLAGS) -o $@ $^
	@echo "--> Linked $@"

$(DISKPART_OBJS): $(OUT_DIR)/c/%.o: %.c
	@mkdir -p $(@D)
	@$(HOST_CC) $(HOST_CFLAGS) -o $@ -c $< 
	@echo "$<"
