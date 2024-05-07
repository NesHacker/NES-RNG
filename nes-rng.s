; nes-rng
; An NES RNG Utility Library written in 6502 assembly.

.importzp seed

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
.proc galois24o:
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

