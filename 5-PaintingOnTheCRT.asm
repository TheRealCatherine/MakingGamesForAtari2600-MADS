; @com.wudsn.ide.asm.hardware=ATARI2600

	icl "vcs.asm"
	icl "macro.asm"
	opt h-f+
	org $f000

	.proc Cart
	
; Now we're going to drive the TV signal properly.
; Assuming NTSC standards, we need the following:
; - 3 scanlines of VSYNC
; - 37 blank lines
; - 192 visible scanlines
; - 30 blank lines

; We'll use the VSYNC register to generate the VSYNC signal,
; and the VBLANK register to force a blank screen above
; and below the visible frame (it'll look letterboxed on
; the emulator, but not on a real TV)

; Let's define a variable to hold the starting color
; at memory address $81
; Using the MADS Assembler we are defining this variable local to the Cart procedure
; within the procedure code we can refer to it simply as BGColor, but outside of the
; procedure we would need to write Cart.BGColor
	BGColor	= $81
	
; The Clean_Start macro zeroes RAM and registers
; Note: The MADS Assembler does not care how you capitalize labels
; so this is the same as writing CLEAN_START
Start	Clean_Start

NextFrame
; Enable VBLANK (disable output)
	lda #2
        sta VBLANK
; At the beginning of the frame we set the VSYNC bit...
	lda #2
	sta VSYNC
; And hold it on for 3 scanlines...
	sta WSYNC
	sta WSYNC
	sta WSYNC
; Now we turn VSYNC off.
	lda #0
	sta VSYNC

; Now we need 37 lines of VBLANK...
	ldx #37
LVBlank	sta WSYNC	; accessing WSYNC stops the CPU until next scanline
	dex		; decrement X
	bne LVBlank	; loop until X == 0

; Re-enable output (disable VBLANK)
	lda #0
        sta VBLANK
; 192 scanlines are visible
; We'll draw some rainbows
	ldx #192
	lda BGColor	; load the background color out of RAM
ScanLoop
	adc #2		; add 1 to the current background color in A
	sta COLUBK	; set the background color
	sta WSYNC	; WSYNC doesn't care what value is stored
	dex
	bne ScanLoop

; Enable VBLANK again
	lda #2
        sta VBLANK
; 30 lines of overscan to complete the frame
	ldx #30
LVOver	sta WSYNC
	dex
	bne LVOver
	
; The next frame will start with current color value - 1
; to get a downwards scrolling effect
	dec BGColor

; Go back and do another frame
	jmp NextFrame
	
	.endp		; end the Cart procedure definition
	
	org $fffc
	.word Cart.Start
	.word Cart.Start
	