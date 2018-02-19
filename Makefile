
AVR_ROOT=/usr/local
AVR_CC=${AVR_ROOT}/bin/avr-gcc
AVR_LD=${AVR_ROOT}/bin/avr-gcc
AVR_OBJCOPY=${AVR_ROOT}/bin/avr-objcopy
AVR_OBJDUMP=${AVR_ROOT}/bin/avr-objdump

ARDUINO_JAVA=/Applications/Arduino.app/Contents/Java
AVRDUDE_ROOT=${ARDUINO_JAVA}/hardware/tools/avr
AVRDUDE=${AVRDUDE_ROOT}/bin/avrdude
AVRDUDE_CONF=${AVRDUDE_ROOT}/etc/avrdude.conf

AVRDUDE_FLAGS+=-C${AVRDUDE_CONF}
AVRDUDE_FLAGS+=-cusbtiny
AVRDUDE_FLAGS+=-pattiny85 

AVR_LDFLAGS=-Llibraries
AVR_CCFLAGS+=-Os
AVR_CCFLAGS+=-g
AVR_CCFLAGS+=-std=gnu99
AVR_CCFLAGS+=-mmcu=attiny85
AVR_CCFLAGS+=-DF_CPU=8000000UL

tiny_ssd1306.elf: tiny_ssd1306.o
	avr-gcc -Wl,-Map,tiny_ssd1306.map -Wl,--gc-sections  -mmcu=attiny85 $< -o $@

.DUMMY:

tiny_ssd1306.hex: tiny_ssd1306.elf
	${AVR_OBJCOPY} -O ihex -R .eeprom $< $@

tiny_ssd1306.eep: tiny_ssd1306.elf
	${AVR_OBJCOPY} \
          -O ihex \
          -j .eeprom \
          --set-section-flags=.eeprom=alloc,load \
          --no-change-warnings \
          --change-section-lma .eeprom=0 \
          $< $@

tiny_ssd1306.o: tiny_ssd1306.c
	avr-gcc -Os -g -std=gnu99 -Wall \
            -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums  -ffunction-sections -fdata-sections \
            -DF_CPU=8000000UL -DBAUD=9600UL -I. -mmcu=attiny85 -c -o $@ $<

tiny_ssd1306.elf.disasm: tiny_ssd1306.elf
	${AVR_OBJDUMP} -S -C --disassemble $< > $@

disasm: tiny_ssd1306.elf.disasm

flash: tiny_ssd1306.hex
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:w:$<:i

flash_read: tiny_ssd1306.read.hex

tiny_ssd1306.read.hex: .DUMMY
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:r:$@:i

clean:
	rm -f \
          tiny_ssd1306.o \
          tiny_ssd1306.elf \
          tiny_ssd1306.hex \
          tiny_ssd1306.eep \
          tiny_ssd1306.map
