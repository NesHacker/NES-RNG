; nes-rng
; An NES RNG Utility Library written in 6502 assembly.

; `.proc galois16o`
;
; Brad Smith's overlapped 16-bit galois linear-feedback shift register PRNG
; implementation.
.proc galois16o
	lda seed+1
	tay ; store copy of high byte
	; compute seed+1 ($39>>1 = %11100)
	lsr ; shift to consume zeroes on left...
	lsr
	lsr
	sta seed+1 ; now recreate the remaining bits in reverse order... %111
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0 ; recombine with original low byte
	sta seed+1
	; compute seed+0 ($39 = %111001)
	tya ; original high byte
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

; `.proc galois24o`
;
; Brad Smith's overlapped 24-bit galois linear-feedback shift register PRNG
; implementation.
.proc galois24o
	ldy seed+1
	lda seed+2
	lsr
	lsr
	lsr
	lsr
	sta seed+1
	lsr
	lsr
	eor seed+1
	lsr
	eor seed+1
	eor seed+0
	sta seed+1
	lda seed+2
	asl
	eor seed+2
	asl
	asl
	eor seed+2
	asl
	eor seed+2
	sty seed+2
	sta seed+0
	rts
.endproc

.proc div8
  dividend  = $00
  divisor   = $01
  sub       = $02
  remainder = $03
  ; Zero-out the Remainder memory
  lda #0
  sta remainder
  ; for (int x = 8; x > 0; x--)
  ldx #8
@loop:
  ; Shift the next bit off the front of the dividend
  asl dividend
  rol remainder
  ; Perform the test subtraction
  lda remainder
  sec
  sbc divisor
  sta sub
  bcc @skip_increment
  ; Record a "1" and store the resulting remainder
  sta remainder
  inc dividend
@skip_increment:
  dex
  bne @loop
  rts
.endproc

.proc div16
  dividend  = $00
  divisor   = $02
  sub       = $04
  remainder = $06
  ; Zero-out the Remainder memory
  lda #0
  sta remainder
  sta remainder+1
  ; for (int x = 16; x > 0; x--)
  ldx #16
@loop:
  ; Shift the next bit off the front of the dividend
  asl dividend
  rol dividend+1
  rol remainder
  rol remainder+1

  ; Perform the test subtraction
  lda remainder
  sec
  sbc divisor
  sta sub

  lda remainder+1
  sbc divisor+1
  sta sub+1

  bcc @skip_increment

  ; Record a "1" and store the resulting remainder
  ; lda sub+2
  sta remainder+1
  lda sub
  sta remainder
  inc dividend

@skip_increment:
  dex
  bne @loop
  rts
.endproc

.proc div24
  dividend  = $00
  divisor   = $03
  sub       = $06
  remainder = $09
  ; Zero-out the Remainder memory
  lda #0
  sta remainder
  sta remainder+1
  sta remainder+2
  ; for (int x = 24; x > 0; x--)
  ldx #24
@loop:
  ; Shift the next bit off the front of the dividend
  asl dividend
  rol dividend+1
  rol dividend+2
  rol remainder
  rol remainder+1
  rol remainder+2

  ; Perform the test subtraction
  lda remainder
  sec
  sbc divisor
  sta sub

  lda remainder+1
  sbc divisor+1
  sta sub+1

  lda remainder+2
  sbc divisor+2
  sta sub+2

  bcc @skip_increment

  ; Record a "1" and store the resulting remainder
  ; lda sub+2
  sta remainder+2
  lda sub+1
  sta remainder+1
  lda sub
  sta remainder
  inc dividend

@skip_increment:
  dex
  bne @loop
  rts
.endproc

