;	@com.wudsn.ide.asm.hardware=ATARI2600

	icl "vcs.asm"
		
	opt h-f+l+		;Create plain 4k ROM file

	org $f000		;start code at $f000

	.proc Cart		;cart procedure (code segment) 

Start
	sei			;disable interrupts
	cld			;disable BCD math mode
	ldx #$ff		;init stack pointer to $FF
	txs			;transfer X register to S register

	lda #0			;set A register to 0
	ldx #$ff		;set X to #$ff
	
Init	
	sta $0, X		;store A register at address ($0+X)
	dex			;decrement by one
	bne Init		;branch until X is zero
	
	lda #$30		;load value inta A ($30 is deep red)
	sta COLUBK		;store A into the background color
	
	jmp start
	
	.endp			;end of cart procedure

	org $fffc		;cartridge vectors
	.word Cart.Start	;reset vector
	.word $ffff		;inturrupt vector (unused on VCS) 
	
	