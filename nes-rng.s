; nes-rng
; An NES RNG Utility Library written in 6502 assembly.

; `.proc galois16o`
;
; Brad Smith's overlapped 16-bit galois linear-feedback shift register PRNG
; implementation.
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

; `.proc div8`
;
; Routine for handling 8-bit division and modulo.
; @param $00 dividend Value to be divided.
; @param $01 divsor Value to divide by.
.proc div8
  dividend  = $00
  divisor   = $01
  sub       = $02
  remainder = $03
  lda #0
  sta remainder
  ldx #8
@loop:
  asl dividend
  rol remainder
  lda remainder
  sec
  sbc divisor
  sta sub
  bcc @skip_increment
  sta remainder
  inc dividend
@skip_increment:
  dex
  bne @loop
  rts
.endproc

; `.proc div16`
;
; Routine for handling 16-bit division and modulo.
; @param [$00-$01] dividend Value to be divided.
; @param [$02-$04] divsor Value to divide by.
.proc div16
  dividend  = $00
  divisor   = $02
  sub       = $04
  remainder = $06
  lda #0
  sta remainder
  sta remainder+1
  ldx #16
@loop:
  asl dividend
  rol dividend+1
  rol remainder
  rol remainder+1
  lda remainder
  sec
  sbc divisor
  sta sub
  lda remainder+1
  sbc divisor+1
  sta sub+1
  bcc @skip_increment
  sta remainder+1
  lda sub
  sta remainder
  inc dividend
@skip_increment:
  dex
  bne @loop
  rts
.endproc
