.segment "HEADER"
  .byte $4E, $45, $53, $1A  ; iNES header identifier
  .byte 2                   ; 2x 16KB PRG-ROM Banks
  .byte 1                   ; 1x  8KB CHR-ROM
  .byte $00                 ; mapper 0 (NROM)
  .byte $00                 ; System: NES

.segment "VECTORS"
  .addr nmi
  .addr reset
  .addr 0

.segment "STARTUP"

.segment "CHARS"
.incbin "./CHR-ROM.bin"

.segment "CODE"

seed = $30 ; TODO Unsure if I like this method of defining the seed address.
.include "../nes-rng.s"
.include "./ppu.s"

.proc reset
  sei
  cld
  ldx #%01000000
  stx $4017
  ldx #$ff
  txs
  ldx #0
  stx PPU_CTRL
  stx PPU_MASK
  stx $4010
  ; Wait for a VBLANK
  bit PPU_STATUS
: bit PPU_STATUS
  bpl :-
  ldx #0
  ; Initalize the zero page, stack, and sprite memory.
  ; (Note: keep $300-$7FF uninitialized to allow for SRAM seeding)
: lda #0
  sta $0000, x
  sta $0100, x
  lda #$EF
  sta $0200, x
  inx
  bne :-
  ; Wait for a second VBLANK
: bit PPU_STATUS
  bpl :-
  bit PPU_STATUS
  ; Initiate an OAM transfer of the sprite memory
  lda #$00
  sta OAM_ADDR
  lda #$02
  sta OAM_DMA
  ; Clear the initial palettes
  lda #$3F
  sta PPU_ADDR
  lda #$00
  sta PPU_ADDR
  lda #$0F
  ldx #$20
: sta PPU_DATA
  dex
  bne :-
  ; Set random seed to known value
  lda #1
  sta seed
  jmp main
.endproc

.proc generate_test_bytes
  ; Generate 32 bytes with the galios16o routine and write them to ram (for
  ; testing the javascript testing implementation)
  ldx #0
: jsr galois16o
  sta $0040, x
  inx
  cpx #32
  bne :-
  rts
.endproc

.proc generate_simple_bytes
  ; Generate 32 bytes with the galios16_simple routine and write them to RAM.
  ldx #0
: jsr galois16_simple
  sta $0040, x
  inx
  cpx #32
  bne :-
  rts
.endproc

.proc generate_d20_bytes
  ldx #0
: jsr d20
  sta $0040, x
  inx
  cpx #32
  bne :-
  rts
.endproc

.proc main
  jsr generate_d20_bytes

@forever:
  jmp @forever
.endproc

.proc nmi
  rti
.endproc
