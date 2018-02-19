#include <avr/interrupt.h>
#include <avr/io.h>
#include <util/delay.h>
// #include <util/twi.h>
#include "TinyWire/TinyWire.h"

int main() {
  uint8_t mask = (1<<PB0) | (1<<PB1) | 0;
  PORTB = 0;
  DDRB = mask;

  TinyWire.begin();

  for (;;) {
    PORTB |= mask;
    _delay_ms(1000);
    PORTB &= ~mask;
    _delay_ms(1000);
  }
}
