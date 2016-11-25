  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring
  

;;;;;;;;;;;;;;;

    
  .bank 0
  .org $C000 
RESET:
  SEI          ; disable IRQs
  CLD          ; disable decimal mode
  LDX #$40
  STX $4017    ; disable APU frame IRQ
  LDX #$FF
  TXS          ; Set up stack
  INX          ; now X = 0
  STX $2000    ; disable NMI
  STX $2001    ; disable rendering
  STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x    ;move all sprites off screen
  INX
  BNE clrmem
   
vblankwait2:      ; Second wait for vblank, PPU is ready after this
  BIT $2002
  BPL vblankwait2
 
LoadPalettes:
  LDA $2002    ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006    ; write the high byte of $3F00 address
  LDA #$00
  STA $2006    ; write the low byte of $3F00 address
  LDX #$00

LoadPalettesLoop:
  LDA palette, x        ;load palette byte
  STA $2007             ;write to PPU
  INX                   ;set index to next byte
  CPX #$20            
  BNE LoadPalettesLoop  ;if x = $20, 32 bytes copied, all done

LoadSprites:
  LDX #$00              ; start at 0

LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$80              ; Compare X to hex $20, decimal 32
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 32, keep going down
              
              

  LDA #%10000000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000   ; enable sprites
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop
  
NMI:
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer
  
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons

ReadA: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadADone:        ; handling this button is done

ReadB: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadBDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadBDone:        ; handling this button is done

ReadSelect: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelectDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadSelectDone:        ; handling this button is done

ReadStart: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadStartDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadStartDone:        ; handling this button is done

ReadUp: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadUpDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200       ; load sprite X position
  SEC             ; make sure the carry flag is clear
  SBC #$01        ; A = A - 1
  STA $0200       ; save sprite X position
ReadUpDone:        ; handling this button is done

ReadDown: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadDownDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0200       ; save sprite X position
ReadDownDone:        ; handling this button is done

ReadLeft: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadLeftDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  SEC             ; make sure the carry flag is clear
  SBC #$01        ; A = A - 1
  STA $0203       ; save sprite X position
ReadLeftDone:        ; handling this button is done

ReadRight: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadRightDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0203       ; save sprite X position
ReadRightDone:        ; handling this button is done

  RTI        ; return from interrupt
 
;;;;;;;;;;;;;;  
  
  .bank 1
  .org $E000
palette:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
  .db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

sprites:
     ;vert tile attr horiz
  .db $40, $12, $00, $58   ;sprite - WEE LIL MONSTER     
  .db $10, $00, $00, $10   ;sprite - H
  .db $10, $01, $00, $18   ;sprite - A
  .db $10, $02, $00, $20   ;sprite - P
  .db $10, $02, $00, $28   ;sprite - P
  .db $10, $03, $00, $30   ;sprite - Y
  .db $20, $00, $00, $10   ;sprite - H 
  .db $20, $04, $00, $18   ;sprite - O
  .db $20, $05, $00, $20   ;sprite - L
  .db $20, $06, $00, $28   ;sprite - I
  .db $20, $07, $00, $30   ;sprite - D
  .db $20, $01, $00, $38   ;sprite - A
  .db $20, $03, $00, $40   ;sprite - Y
  .db $20, $08, $00, $48   ;sprite - S
  .db $30, $11, $00, $10   ;sprite - -
  .db $30, $08, $00, $28   ;sprite - S
  .db $30, $0E, $00, $30   ;sprite - K
  .db $30, $03, $00, $38   ;sprite - Y
  .db $30, $05, $00, $40   ;sprite - L
  .db $30, $06, $00, $48   ;sprite - I
  .db $30, $10, $00, $50   ;sprite - N   
  .db $30, $0D, $00, $58   ;sprite - E

  .org $FFFA     ;first of the three vectors starts here
  .dw NMI        ;when an NMI happens (once per frame if enabled) the 
                   ;processor will jump to the label NMI:
  .dw RESET      ;when the processor first turns on or is reset, it will jump
                   ;to the label RESET:
  .dw 0          ;external interrupt IRQ is not used in this tutorial
  
;;;;;;;;;;;;;;  
  
  .bank 2
  .org $0000
  .incbin "holidays.chr"   ;includes 8KB graphics file from SMB1