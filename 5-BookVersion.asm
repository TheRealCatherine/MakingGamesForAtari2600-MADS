	;@com.wudsn.ide.asm.hardware=ATARI2600

	icl "vcs.asm"
	icl "macro.asm"		
	opt h-f+l+		;Create plain 4k ROM file
	org $f000		;start code at $f000
	
	.proc Cart
	BGColor = $81;		;declare local (to Cart procedure) variable BGColor at memory address $81
	
Start
	Clean_Start		;macro to safely clear memory and TIA
	
NextFrame
	lda #2			;same as binary #%00000010
	sta VBLANK		;turn on VBLANK
	sta VSYNC		;turn on VSYNC
	sta WSYNC		;first scanline
	sta WSYNC		;second scanline
	sta WSYNC		;third scanline
	lda #0
	sta VSYNC		;turn off VSYNC
	
	ldx #37			;count 37 scanlines
	
LVBLank
	sta WSYNC		;wait for next scanline
	dex			;decrement X
	bne LVBlank		;loop while X != 0
	lda #0
	sta VBLANK		;turn off VBLANK
	ldx #192		;count 192 scanlines
	ldy BGColor		;load the background color from RAM
	
LVScan
	sty COLUBK		;set the background color
	sta WSYNC		;wait for the next scanline
	iny			;increment the background color
	dex			;decrement X
	bne LVSCAN		;loop while X != 0
	
	lda #2
	sta VBLANK		;turn on VBLANK again
	ldx #30			;count 30 scanlines
	
LVOver
	sta WSYNC		;wait for next scanline
	dex			;decrement X
	bne LVOver		;loop while X != 0
	
	dec BGColor
	jmp NextFrame
	
	.endp
	
	org $fffc
	.word Cart.Start
	.word $ffff
	