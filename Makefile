
TINYWIRE=libraries/TinyWire

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

MCU=attiny85

AVR_LDFLAGS=-Llibraries
AVR_CCFLAGS=-Ilibraries
AVR_CCFLAGS+=-Os
AVR_CCFLAGS+=-g
AVR_CCFLAGS+=-std=c++11
AVR_CCFLAGS+=-mmcu=${MCU}
AVR_CCFLAGS+=-DF_CPU=8000000UL
AVR_CCFLAGS+=-Wall
AVR_CCFLAGS+=-funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums
AVR_CCFLAGS+=-ffunction-sections -fdata-sections
AVR_CCFLAGS+=-DBAUD=9600UL
AVR_CCFLAGS+=-I.


AVR_LDFLAGS+=-Wl,--gc-sections -mmcu=${MCU}

tiny_ssd1306.elf: TinyWire.o twi.o tiny_ssd1306.o 
	${AVR_CC} ${AVR_LDFLAGS} -Wl,-Map,tiny_ssd1306.map $^ -o $@
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

tiny_ssd1306.o: tiny_ssd1306.cpp
	${AVR_CC} ${AVR_CCFLAGS} \
            -c -o $@ $<

tiny_ssd1306.elf.disasm: tiny_ssd1306.elf
	${AVR_OBJDUMP} -S -C --disassemble $< > $@

disasm: tiny_ssd1306.elf.disasm

flash: tiny_ssd1306.hex
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:w:$<:i

flash_read: tiny_ssd1306.read.hex

tiny_ssd1306.read.hex: .DUMMY
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:r:$@:i

TinyWire.o: ${TINYWIRE}/TinyWire.cpp
	${AVR_CC} ${AVR_CCFLAGS} -c -o $@ $<
twi.o: ${TINYWIRE}/twi.cpp
	${AVR_CC} ${AVR_CCFLAGS} -c -o $@ $<

clean:
	rm -f \
          ${TINYWIRE}/TinyWire.o \
          ${TINYWIRE}/twi.o \
          tiny_ssd1306.o \
          tiny_ssd1306.elf \
          tiny_ssd1306.hex \
          tiny_ssd1306.eep \
          tiny_ssd1306.map \
          tiny_ssd1306.elf.disasm
