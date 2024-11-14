	.inesprg 1
	.ineschr 2
	.inesmir 0
	.inesmap 0

	.bank 1
	.org $FFFA

	.dw 0
	.dw START
	.dw 0

	; スプライトデータ（CHR-ROMに必要なデータを配置）
	.bank 2
	.org $0000
    .db $3C, $42, $42, $7E, $42, $42, $42, $42,$00,$00,$00,$00,$00,$00,$00,$00
	.db $7E, $02, $04, $08, $10, $20, $40, $7E,$00,$00,$00,$00,$00,$00,$00,$00
	.db $42, $42, $42, $42, $42, $42, $42, $3C ,$00,$00,$00,$00,$00,$00,$00,$00
	.db $42, $44, $48, $70, $48, $44, $42, $42 ,$00,$00,$00,$00,$00,$00,$00,$00
	.db $3C, $08, $08, $08, $08, $08, $08, $3C , $00,$00,$00,$00,$00,$00,$00,$00

	.bank 0
	.org $8000

START:
	LDA $2002
	BPL START ; vブランクチェック


	; パレットの設定　ファミコンのPPUは$2006に指定したアドレスに$2007のデータを書き込むという挙動をするっぽい
	LDA #$3F ; 上位バイト
	STA $2006
	LDA #$10 ; 下位バイト
	STA $2006 ;これで書き込み先が決まる
	
	;ここからパレット内の色を設定していく
	LDA #$0F ; 背景色
	STA $2007
	LDA #$30 ; Color1
	STA $2007
	LDA #$36 ; Color2
	STA $2007
	LDA #$11 ; Color3
	STA $2007

	;PPUコントロールレジスタを設定する
	;これでスプライトパターンテーブル0を使用するってことになるらしい
	lda #%00000000
	STA $2000
	;PPUマスクレジスタを設定する
	;1になってるビットが「Sprite有効化」フラグ
	LDA #%00010000
	STA $2001

	;OAMアドレスを初期化する
	LDA #0
	STA $2003

	; A
	LDA #80
	LDX #80
	LDY #0
	JSR DRAW_SPRITE

	;Z
	LDA #100
	LDX #100
	LDY #1
	JSR DRAW_SPRITE

	;U
	LDA #120
	LDX #120
	LDY #2
	JSR DRAW_SPRITE

	;K
	LDA #100
	LDX #140
	LDY #3
	JSR DRAW_SPRITE

	;I
	LDA #80
	LDX #160
	LDY #4
	JSR DRAW_SPRITE
	

LOOP:
	INC $0
	JMP LOOP


; LDA = PosY
; LDX = PosX
; LDY = Sprite
DRAW_SPRITE:
	;スプライトの描画設定
	STA $2004

	;スプライトのタイル番号
	STY $2004
	
	;属性設定（よくわからん）
	LDA #0
	STA $2004
	;x座標
	STX $2004

	RTS
