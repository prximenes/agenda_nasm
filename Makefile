bootdisk=disk.img
blocksize=512
disksize=100

boot1=menu

# preencha esses valores para rodar o segundo estágio do bootloader
boot2=agenda
boot2pos=1
boot2size=50

# preencha esses valores para rodar o kernel
kernel=real
kernelpos=2
kernelsize=5

ASMFLAGS=-f bin
file = $(bootdisk)

# adicionem os targets do kernel e do segundo estágio para usar o make all com eles

all: clean mydisk boot1 write_boot1 boot2 write_boot2 hexdump launchqemu

mydisk:
	dd if=/dev/zero of=$(bootdisk) bs=$(blocksize) count=$(disksize)

boot1:
	nasm $(ASMFLAGS) $(boot1).asm -o $(boot1).bin

boot2:
	nasm $(ASMFLAGS) $(boot2).asm -o $(boot2).bin

write_boot1:
	dd if=$(boot1).bin of=$(bootdisk) bs=$(blocksize) count=1 conv=notrunc

write_boot2:
	dd if=$(boot2).bin of=$(bootdisk) bs=$(blocksize) seek=$(boot2pos) count=$(boot2size) conv=notrunc 
	dd if=$(boot2).bin of=$(bootdisk) bs=$(blocksize) seek=$(boot2pos) count=$(boot2size) conv=notrunc

hexdump:
	hexdump $(file)

disasm:
	ndisasm $(boot1).asm

launchqemu:
	qemu-system-x86_64 -fda $(bootdisk)

clean:
	rm -f *.bin $(bootdisk) *~
