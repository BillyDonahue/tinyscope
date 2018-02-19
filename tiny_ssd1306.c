#include <avr/interrupt.h>
#include <avr/io.h>
#include <util/delay.h>
//#include "tiny1306/tiny1306.h"

uint8_t mask =
  (1<<PB0) |
  (1<<PB1) |
  //(1<<PB2) |
  //(1<<PB3) |
  0;

static void setup() {
  PORTB = 0;
  DDRB = mask;
}

static void loop() {
  PORTB |= mask;
  _delay_ms(1000);
  PORTB &= ~mask;
  _delay_ms(1000);
}

int main() {
  setup();
  for (;;) {
    loop();
  }
}
