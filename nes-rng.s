; nes-rng
; An NES RNG Utility Library written in 6502 assembly.

; `.proc galois16`
;
; Simple 16-bit Galios LFSR random number generator implementation as explained
; in the "8-bit RNG" video.
.proc galois16_simple
  lda seed+1
  ldy #8
  ; for (y = 8; y > 0; y--) {
@loop:
  ; Shift the binary state data one bit to the right
  lsr
  ror seed
  ; The `ror` instruction shifts the last bit into the carry flag on the 6502.
  ; So here we test if that flag was set, and apply the exclusive-OR on the
  ; tap positions if the last bit was a `1` (the `bcc` instructions means
  ; "Brach if Carry is Clear", so we "skip" the exclusive or if we shift off
  ; a zero).
  bcc @skip_eor
  ; The `eor` or "Exclusive OR" instruction handles each of the operations in
  ; one fell swoop. Since the A register holds the "high byte" for the 16-bit
  ; state all we need to do is perform a single EOR to update all the taps in
  ; one fell swoop.
  eor #$B4
@skip_eor:
  sta seed+1
  dey
  bne @loop
  ; }
  ; The random bits were all shifted into the lower byte of the state, so load
  ; that into the A register and return from the routine.
  lda seed
  rts
.endproc

; `.proc galois16o`
;
; Brad Smith's optimized 16-bit galois linear-feedback shift register PRNG
; implementation.
;
; Note: the output bytes for this method will differ from those of the simple
; implementation above as the shift direction is reversed and it uses a
; different set of taps.
;
; @see https://github.com/bbbradsmith/prng_6502
.proc galois16o
  lda seed+1
	tay
	lsr
	lsr
	lsr
	sta seed+1
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0
	sta seed+1
	tya
	sta seed+0
	asl
	eor seed+0
	asl
	eor seed+0
	asl
	asl
	asl
	eor seed+0
	sta seed+0
  rts
.endproc

; `.proc d20`
;
; D20 die rolling routine using the optimized galois routine with rejection
; sampling, as explained in the "8-bit RNG" video.
.proc d20
@loop:
  ; Generate a random byte
  jsr galois16o
  ; Cut off the bits we don't need with an and operation
  and #%00011111
  ; Compare the result to 20 and retry if it's out of bounds
  cmp #20
  bpl @loop
  ; Add one (since the result is from 0 through 19)
  clc
  adc #1
  rts
.endproc
