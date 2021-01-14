SRC=app.asm

compile: $(SRC)
	yasm -o app.o -felf64 -g dwarf2 $(SRC)
	ld -o app app.o -I/lib64/ld-linux-x86-64.so.2

clean:
	$(RM) app app.o

.SILENT:
