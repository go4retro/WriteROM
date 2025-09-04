start
* = $1100
base = $a000

reg_addr_lo = base
reg_addr_hi = base + $100
reg_bank =    base + $200
reg_read =    base + $600
reg_write =   base + $700

MAGIC1 = $5555
MAGIC1D = $aa
MAGIC2 = $2aaa
MAGIC2D = $55
MAGIC3 = $5555

ERASE = $80
ERASEALL = $10
WRITE = $A0

app
  jsr unlock
  jsr erase_all
  jsr lock
  rts

* = $1200
app2
  jsr unlock
  jsr write_one
  jsr lock
  lda base
  jsr hex
  rts

erase_all
  lda #ERASE
  jsr command
  lda #ERASEALL
  jmp command

write_one
  lda #WRITE
  jsr command
  ldx #0
  ldy #8
  lda #0
  jsr set_addy

  lda #$87
  jmp set_data


command
  pha
  lda #0
  sta bank
  lda #<MAGIC1
  sta addr_lo
  lda #>MAGIC1
  sta addr_hi
  lda #MAGIC1D
  sta data
  jsr store_addy
  jsr store_data
  lda #<MAGIC2
  sta addr_lo
  lda #>MAGIC2
  sta addr_hi
  lda #MAGIC2D
  sta data
  jsr store_addy
  jsr store_data
  lda #<MAGIC3
  sta addr_lo
  lda #>MAGIC3
  sta addr_hi
  pla
  sta data
  jsr store_addy
  jmp store_data

set_addy
  stx addr_lo
  sty addr_hi
  sta bank
  jmp store_addy

set_data
  sta data
  jmp store_data

store_addy
  !byte $ad
bank
  !byte 0
  !byte >reg_bank
  jsr hex

  !byte $ad
addr_hi
  !byte 0
  !byte >reg_addr_hi
  jsr hex

  !byte $ad
addr_lo
  !byte 0
  !byte >reg_addr_lo
  jsr hex
  jmp crlf

store_data
  !byte $ad
data
  !byte 0
  !byte >reg_write
  jsr hex
  jmp crlf

unlock
  lda base + $555
  lda base + $aaa
  lda base + $555
  lda base + $2aa
  lda base + 1
  rts

lock
  lda base + $555
  lda base + $aaa
  lda base + $555
  lda base + $2aa
  lda base + 0
  rts

crlf
  lda #13
  jmp $ffd2


hex
  pha
  ror
  ror
  ror
  ror
  and #$0f
  tax
  lda hextable,x
  jsr $ffd2
  pla
  and #$0f
  tax
  lda hextable,x
  jsr $ffd2
  lda #32
  jsr $ffd2
  rts

hextable
  !text "0123456789ABCDEF"

