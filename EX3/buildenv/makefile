PREFIX=/usr/mips

CC=${PREFIX}/bin/mips-elf-gcc -mips1 -msoft-float
LD=${PREFIX}/bin/mips-elf-ld -N -Ttext=0x40000000 --section-start .rodata=4
AR=${PREFIX}/bin/mips-elf-ar
OBJCOPY=${PREFIX}/bin/mips-elf-objcopy

CFLAGS=-02 -DARCH_IS_BIG_ENDIAN

test.elf: test.o
    ${LD} -o $@ crt0.o $^ -L. -lc

lib: crt0 libc.a

libc.a: exceptions.o util.o
    ${AR} rc $@ $^

%.imem.hex: %.elf
    ${OBJCOPY} -j .text -O ihex $< $@

%.dmem.hex: %.elf 
    ${OBJCOPY} -R .text -O ihex $< $@

%.mif: %.hex
    ./hex2mif.pl < $< > $@

