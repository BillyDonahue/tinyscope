
AVR_ROOT=/usr/local/CrossPack-AVR
AVR_CXX=${AVR_ROOT}/bin/avr-g++
AVR_LD=${AVR_ROOT}/bin/avr-ld
AVR_OBJCOPY=${AVR_ROOT}/bin/avr-objcopy
AVRDUDE=${AVR_ROOT}/bin/avrdude -c usbtiny -p attiny85 

AVR_LDFLAGS=-Llibraries
AVR_CXXFLAGS=-std=c++11 -O2 -Ilibraries

AVR_CXXFLAGS+=-mmcu=attiny85
AVR_CXXFLAGS+=-DF_CPU=1000000

tiny_ssd1306.hex: tiny_ssd1306
	${AVR_OBJCOPY} $< -O ihex $@

tiny_ssd1306: tiny_ssd1306.o
	${AVR_LD} ${AVR_LDFLAGS} -o $@ $<

tiny_ssd1306.o: tiny_ssd1306.cc
	${AVR_CXX} ${AVR_CXXFLAGS} -c  -o $@ $<

dump: tiny_ssd1306
	avr-objdump --disassemble $<

list:
	${AVRDUDE}

clean:
	rm tiny_ssd1306.o tiny_ssd1306
