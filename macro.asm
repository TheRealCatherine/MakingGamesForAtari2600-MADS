.MACRO Clean_Start
                sei
                cld
            
                ldx #0
                txa
                tay
                
ClearStack
		dex
                txs
                pha
                bne ClearStack
.ENDM

.MACRO Vertical_Sync
                lda #%1110          ; each '1' bits generate a VSYNC ON line (bits 1..3)
VSLOOP		sta WSYNC           ; 1st '0' bit resets Vsync, 2nd '0' bit exit loop
                sta VSYNC
                lsr
                bne VSLOOP          ; branch until VYSNC has been reset
.ENDM