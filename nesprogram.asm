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

LOOP:
	JSR UPDATE_INPUT_STATE
	
	LDA $20
	BEQ RELEASE_A
	JSR PRESS_A
RELEASE_A:
	LDA $21
	BEQ RELEASE_B
	JSR PRESS_B
RELEASE_B:
	LDA $22
	BEQ RELEASE_SELECT
	JSR PRESS_SELECT
RELEASE_SELECT
	LDA $23
	BEQ RELEASE_START
	JSR PRESS_START
RELEASE_START:
	LDA $24
	BEQ RELEASE_UP
	JSR PRESS_UP
RELEASE_UP:
	LDA $25
	BEQ RELEASE_DOWN
	JSR PRESS_DOWN
RELEASE_DOWN:
	LDA $26
	BEQ RELEASE_LEFT
	JSR PRESS_LEFT
RELEASE_LEFT:
	LDA $27
	BEQ RELEASE_RIGHT
	JSR PRESS_RIGHT
RELEASE_RIGHT:


	JMP LOOP ; メインループへ戻る


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


;コントローラの入力を管理するルーチン
; $20から + 8までのアドレスに入力状態をセットする
; 20から A,B, Select , Start ,Up, Down ,Left , Rightの順で入る
UPDATE_INPUT_STATE:
	;4016に01を書き込むとコントローラの入力状態をリセットする
	LDA #$01
	STA $4016
	;0を書き込んで読み出しを有効化
	LDA #$00
	STA $4016

	LDY #$00 ;インデックスとしてYレジスタを使う

GET_BUTTON_STATE:
	LDA $4016
	AND #$01

	STA $20,Y
	INY
	CPY #$08
	BNE GET_BUTTON_STATE

	RTS


PRESS_A:
	LDA #$50
	LDX #$80
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_B:
	LDA #$70
	LDX #$80
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_START:
	LDA #$70
	LDX #$80
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_SELECT:
	LDA #$70
	LDX #$90
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_UP:
	LDA #$50
	LDX #$78
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_DOWN:
	LDA #$70
	LDX #$78
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_LEFT:
	LDA #$80
	LDX #$78
	LDY #$1
	JSR DRAW_SPRITE
	RTS

PRESS_RIGHT:
	LDA #$90
	LDX #$78
	LDY #$1
	JSR DRAW_SPRITE
	RTS