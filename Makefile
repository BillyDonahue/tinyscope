
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

tinyscope.elf: TinyWire.o twi.o tinyscope.o 
	${AVR_CC} ${AVR_LDFLAGS} -Wl,-Map,tinyscope.map $^ -o $@
.DUMMY:

tinyscope.hex: tinyscope.elf
	${AVR_OBJCOPY} -O ihex -R .eeprom $< $@

tinyscope.eep: tinyscope.elf
	${AVR_OBJCOPY} \
          -O ihex \
          -j .eeprom \
          --set-section-flags=.eeprom=alloc,load \
          --no-change-warnings \
          --change-section-lma .eeprom=0 \
          $< $@

tinyscope.o: tinyscope.cpp
	${AVR_CC} ${AVR_CCFLAGS} \
            -c -o $@ $<

tinyscope.lst: tinyscope.elf
	${AVR_OBJDUMP} -S -C --disassemble $< > $@

disasm: tinyscope.lst

flash: tinyscope.hex
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:w:$<:i

flash_read: tinyscope.read.hex

tinyscope.read.hex: .DUMMY
	${AVRDUDE} ${AVRDUDE_FLAGS} -v -Uflash:r:$@:i

TinyWire.o: ${TINYWIRE}/TinyWire.cpp
	${AVR_CC} ${AVR_CCFLAGS} -c -o $@ $<
twi.o: ${TINYWIRE}/twi.cpp
	${AVR_CC} ${AVR_CCFLAGS} -c -o $@ $<

clean:
	rm -f \
          ${TINYWIRE}/TinyWire.o \
          ${TINYWIRE}/twi.o \
          tinyscope.o \
          tinyscope.elf \
          tinyscope.hex \
          tinyscope.eep \
          tinyscope.map \
          tinyscope.elf.disasm
