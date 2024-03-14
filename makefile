SRC_DIR = source
OBJ_DIR = obj
LST_DIR = lst

AS = nasm -felf64 -l
LD = gcc -no-pie -lc

.PHONY: printf

printf: obj lst printf.out

obj:
	@mkdir obj

lst:
	@mkdir lst

printf.out: $(OBJ_DIR)/asm_printf.o $(OBJ_DIR)/printf.o $(OBJ_DIR)/numtostr.o
	@$(LD) $^ -o $@

$(OBJ_DIR)/asm_printf.o: $(SRC_DIR)/asm_printf.asm
	@$(AS) $(LST_DIR)/asm_printf.lst $< -o $@

$(OBJ_DIR)/numtostr.o: $(SRC_DIR)/numtostr.asm
	@$(AS) $(LST_DIR)/numtostr.lst $< -o $@

$(OBJ_DIR)/printf.o: printf.c
	@gcc -c $< -o $@