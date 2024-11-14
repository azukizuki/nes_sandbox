	.inesprg 1
	.ineschr 2
	.inesmir 0
	.inesmap 0

	;bank1のFFFA領域にはファミコンの割り込みベクタが存在する。ここに各種ハードウェアイベントを定義する
	.bank 1
	.org $FFFA

	.dw 0 ; NMI発動時に呼び出すアドレスを指定。 NMIとは Mon-MaskableInterruptの略で、Vブランクの開始時にPPUからトリガーされる。レンダリング開始みたいなイメージ
	.dw START ;リセットベクタ　電源入れたときとリセットボタン押したときに呼び出すアドレスを指定。ここではSTARTラベルを指定している
	.dw 0 ;IRQ割り込みベクタ　カセットに特殊チップなど積んでると発火するとかそういう系っぽい？

	;bank2にリソースを定義
	INCLUDE "resources/sprite.asm"

	; bank0に切り替えて8000アドレスからプログラム領域になる
	.bank 0
	.org $8000

START:
	LDA $2002
	BPL START ; vブランクチェック

	JSR RENDER_INIT_INITIALIZE ; 描画初期化
	JSR SOUND_INIT ; サウンド初期化

	; 4000は矩形波のch1の制御レジスタ(1)
	LDA #%10000000 ;上位2bitがduty比3bit目が長さの有効無効フラグ,4bit目が減衰の切り替えフラグ,5~8bit目で減衰率
	STA $4000

	; 4001は矩形波のch1の制御レジスタ(2)
	LDA #%00001111 ;上位1bitでスイーブの有効無効,2~4bitで変化率,5bitで方向,残り3bitで変化量
	STA $4001

	; 周波数の上位バイト
	LDA #$40
	STA $4002

	; 周波数の下位バイト + 長さ
	LDA #$02
	STA $4003


LOOP:
	JSR INPUT_UPDATE_INPUT_STATE
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

	INCLUDE "input.asm"
	INCLUDE "render_init.asm"
	INCLUDE "sound.asm"


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