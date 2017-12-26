	;@com.wudsn.ide.asm.hardware=ATARI2600
	icl "vcs.asm"
	icl "macro.asm"		
	opt h-f+l+
	org $f000
	
	; We're going to mess with the playfield registers, PF0, PF1 and PF2.
	; Between them, they represent 20 bits of bitmap information
	; which are replicated over 40 wide pixels for each scanline.
	; By changing the registers before each scanline, we can draw bitmaps.

	.proc Cart
	
	Counter = $81
	
Start	Clean_Start

NextFrame
; This macro efficiently gives us 3 lines of VSYNC
	Vertical_Sync
	
; 37 lines of VBLANK
	ldx #37
	
LVBlank
	sta WSYNC
	dex
	bne LVBlank
; Disable VBLANK
	stx VBLANK
; Set foreground color
	lda #182
	sta COLUPF
; Draw the 192 scanlines
	ldx #192
	lda #0			; changes every scanline
	;lda Counter		; uncomment to scroll

ScanLoop
	sta WSYNC		; wait for next scanline
	sta PF0			; set the PF1 playfield pattern register
	sta PF1			; set the PF1 playfield pattern register
	sta PF2			; set the PF2 playfield pattern register
	stx COLUBK		; set the background color
	adc #1			; increment A
	dex
	bne ScanLoop
	
; Reenable VBlank for bottom (and top of next frame)
	lda #2
	sta VBLANK
;30 lines of overscan
	ldx #30
LVOver
	sta WSYNC
	dex
	bne LVOver
	
; go back and do another frame
	inc counter
	jmp NextFrame
	
	.endp 
	
	org $fffc
	.word Cart.Start
	.word $ffff