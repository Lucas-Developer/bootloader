CC=clang
CXX=clang++
CFLAGS=-ffreestanding -Wall -Wextra -mno-sse -mno-sse2 -mno-mmx -Os -fPIC
CXXFLAGS=-ffreestanding -Wall -Wextra -fno-exceptions -fno-rtti -mno-sse -mno-sse2 -mno-mmx -O3 -std=c++14 -fPIC
AS=nasm
ASFLAGS=
LD=ld
LDFLAGS=
RM=rm

BS2SRC=$(wildcard src/stage2/*.c)
BS2OBJ=$(patsubst %.c,%.o,$(BS2SRC))
KSRC=$(wildcard src/kernel/*.cpp)
KOBJ=$(patsubst %.cpp,%.o,$(KSRC))

all:bootsector.bin bootstage1.bin bootstage2.bin kernel

bootsector.bin: src/bootsector/bootsector.s
	$(AS) $< -o bin/$@

bootstage1.bin: src/stage1/bootstage1.s
	$(AS) $< -o bin/$@

bootstage2.bin: $(BS2OBJ)
	$(LD) -Tsrc/stage2/link.ld $(BS2OBJ) -o bin/$@

sinclude $(BS2SRC:.c=.d)
%d: %c
	$(CC) -MM $(CFLAGS) $< > $@

kernel:$(KOBJ)
	$(LD) -Tsrc/kernel/link.ld $(KOBJ) -o bin/$@

sinclude $(KSRC:.cpp=.d)
%d: %cpp
	$(CXX) -MM $(CXXFLAGS) $< > $@

clean:clean2 cleank
	rm bin/*.bin

clean2:
	rm src/stage2/*.o
	rm src/stage2/*.d

cleank:
	rm src/kernel/*.o
	rm src/kernel/*.d
