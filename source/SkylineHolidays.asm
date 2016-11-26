  .inesprg 1   ; 1x 16KB PRG code
  .ineschr 1   ; 1x  8KB CHR data
  .inesmap 0   ; mapper 0 = NROM, no bank swapping
  .inesmir 1   ; background mirroring

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NES Header lines above - these are required

  .bank 0
  .org $C000 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RESET happens on NES reboot.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; First wait for vblank to make sure the PPU is ready. PPU is the graphics
;; chip on the NES.
vblankwait1:
  BIT $2002
  BPL vblankwait1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clear memory routine.
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
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Second wait for vblank, PPU (graphics) chip is ready after this.
vblankwait2:
  BIT $2002
  BPL vblankwait2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads in the color palettes.
LoadPalettes:
  LDA $2002    ; read PPU status to reset the high/low latch
  LDA #$3F
  STA $2006    ; write the high byte of $3F00 address
  LDA #$00
  STA $2006    ; write the low byte of $3F00 address
  LDX #$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loops through the palette and loads it.
LoadPalettesLoop:
  LDA palette, x        ;load palette byte
  STA $2007             ;write to PPU
  INX                   ;set index to next byte
  CPX #$20            
  BNE LoadPalettesLoop  ;if x = $20, 32 bytes copied, all done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loads in the sprites.
LoadSprites:
  LDX #$00              ; start at 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loops through the sprites available below and loads them.
LoadSpritesLoop:
  LDA sprites, x        ; load data from address (sprites +  x)
  STA $0200, x          ; store into RAM address ($0200 + x)
  INX                   ; X = X + 1
  CPX #$80              ; Compare X to hex $80, decimal 128
  BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
                        ; if compare was equal to 128, keep going down
              
  LDA #%10000000   ; enable NMI, sprites from Pattern Table 1
  STA $2000

  LDA #%00010000   ; enable sprites
  STA $2001

Forever:
  JMP Forever     ;jump back to Forever, infinite loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  NMI Routine
NMI:
  LDA #$00
  STA $2003  ; set the low byte (00) of the RAM address
  LDA #$02
  STA $4014  ; set the high byte (02) of the RAM address, start the transfer
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; LatchController Routine
LatchController:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016       ; tell both the controllers to latch buttons

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read A button routine 
ReadA: 
  LDA $4016       ; player 1 - A
  AND #%00000001  ; only look at bit 0
  BEQ ReadADone   ; branch to ReadADone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadADone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read B button routine
ReadB: 
  LDA $4016       ; player 1 - B
  AND #%00000001  ; only look at bit 0
  BEQ ReadBDone   ; branch to ReadBDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadBDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Select button routine
ReadSelect: 
  LDA $4016       ; player 1 - Select button
  AND #%00000001  ; only look at bit 0
  BEQ ReadSelectDone   ; branch to ReadSelectDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadSelectDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Start button routine
ReadStart: 
  LDA $4016       ; player 1 - Start button
  AND #%00000001  ; only look at bit 0
  BEQ ReadStartDone   ; branch to ReadStartDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
ReadStartDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Up button routine
ReadUp: 
  LDA $4016       ; player 1 - Up button
  AND #%00000001  ; only look at bit 0
  BEQ ReadUpDone   ; branch to ReadUpDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200       ; load sprite Y position
  SEC             ; make sure the carry flag is clear
  SBC #$01        ; A = A - 1
  STA $0200       ; save sprite Y position
ReadUpDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Down button routine
ReadDown: 
  LDA $4016       ; player 1 - Down button
  AND #%00000001  ; only look at bit 0
  BEQ ReadDownDone   ; branch to ReadDownDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0200       ; load sprite Y position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0200       ; save sprite Y position
ReadDownDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Left button routine
ReadLeft: 
  LDA $4016       ; player 1 - Left button
  AND #%00000001  ; only look at bit 0
  BEQ ReadLeftDone   ; branch to ReadLeftDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  SEC             ; make sure the carry flag is clear
  SBC #$01        ; A = A - 1
  STA $0203       ; save sprite X position
ReadLeftDone:        ; handling this button is done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read Right button routine
ReadRight: 
  LDA $4016       ; player 1 - Right button
  AND #%00000001  ; only look at bit 0
  BEQ ReadRightDone   ; branch to ReadRightDone if button is NOT pressed (0)
                  ; add instructions here to do something when button IS pressed (1)
  LDA $0203       ; load sprite X position
  CLC             ; make sure the carry flag is clear
  ADC #$01        ; A = A + 1
  STA $0203       ; save sprite X position
ReadRightDone:        ; handling this button is done

  RTI        ; return from interrupt
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
  .bank 1
  .org $E000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Color palette - this gets loaded up above.
palette:
  .db $0F,$31,$32,$33,$0F,$35,$36,$37,$0F,$39,$3A,$3B,$0F,$3D,$3E,$0F
  .db $0F,$1C,$15,$14,$0F,$02,$38,$3C,$0F,$1C,$15,$14,$0F,$02,$38,$3C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprites available - these get loaded up above. These rows point to 
;; positions in the holidays.chr file loaded in at the bottom of this
;; file. There are four values in each row. 
;; 
;; 1.) Vertical position on the screen to display sprite.
;; 2.) Tile number to pull from the .chr file. 
;; 3.) Attributes
;; 4.) Horizontal position on the screen to display sprite.
;;
;; In this demo, we use the first sprite (tile $12) which is the little
;; alien that gets moved around on the screen with the ReadUp, ReadDown,
;; ReadLeft, and ReadRight routines above. The routines above then modify
;; the position (vertical and horizontal) values of the sprite to 
;; simulate movement.
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
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
  .bank 2
  .org $0000
  .incbin "holidays.chr"   ; Sprite file that contains the images and lettering for the demo