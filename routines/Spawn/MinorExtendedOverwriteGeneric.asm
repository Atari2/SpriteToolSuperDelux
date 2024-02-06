; Routine used for spawning minor extended sprites with initial speed at the position (+offset)
; of the calling sprite and returns the sprite index in Y
; This routine cannot fail, if the extended sprite table is full, it will overwrite the oldest slot
; by using $185d (https://www.smwcentral.net/?p=memorymap&game=smw&region=ram&address=7E185D)

; For a list of minor extended sprites see here: 
; https://www.smwcentral.net/?p=memorymap&a=detail&game=smw&region=ram&detail=11c9baba28dd

; Input:
;   A   = number
;   $00 = x offset
;   $01 = y offset
;   $02 = x speed
;   $03 = y speed
;   $04-05 = origin (16-bit) x pos  ; since this is a generic routine it can be called from any other sprite
;   $06-07 = origin (16-bit) y pos  ; type, so i opted for adding macros in _header.asm that helps to setup this

; Output:
;   Y = index to minor extended sprite ($FF means no sprite spawned)
;   This routine does not guarantee the carry flag to be clear or set

?main:
    xba
    ldy.b #!MinorExtendedSize-1
?.loop
    lda !minor_extended_num,y
    beq ?.found
    dey 
    bpl ?.loop
    ;; no free slot, overwrite the oldest one
    dec $185d|!addr 
    bpl ?.skip
    lda.b #!MinorExtendedSize-1
    sta.w $185d|!addr
?.skip
    ldy.w $185d|!addr
?.found
    xba 
    sta !minor_extended_num,y
    
    lda $00
    clc 
    adc $04
    sta !minor_extended_x_low,y
    lda #$00
    bit $00
    bpl $01
    dec 
    adc $05
    sta !minor_extended_x_high,y

    lda $01
    clc 
    adc $06
    sta !minor_extended_y_low,y
    lda #$00
    bit $01
    bpl $01
    dec 
    adc $07
    sta !minor_extended_y_high,y

    lda $02
    sta !minor_extended_x_speed,y
    lda $03
    sta !minor_extended_y_speed,y
    rtl
