	.inesprg 1
	.ineschr 2
	.inesmir 0
	.inesmap 0

	;bank1のFFFA領域にはファミコンの割り込みベクタが存在する。ここに各種ハードウェアイベントを定義する
	.bank 1
	.org $FFFA

	.dw ON_NMI ; NMI発動時に呼び出すアドレスを指定。 NMIとは Mon-MaskableInterruptの略で、Vブランクの開始時にPPUからトリガーされる。レンダリング開始みたいなイメージ
	.dw START ;リセットベクタ　電源入れたときとリセットボタン押したときに呼び出すアドレスを指定。ここではSTARTラベルを指定している
	.dw 0 ;IRQ割り込みベクタ　カセットに特殊チップなど積んでると発火するとかそういう系っぽい？

	;bank2にリソースを定義
	INCLUDE "resource_init.asm"

	; bank0に切り替えて8000アドレスからプログラム領域になる
	.bank 0
	.org $8000

START:
	
	LDA $2002
	BPL START ; vブランクチェック

;------------------------------------------
; 初期化ロジックここに書く
;------------------------------------------
INITIALIZE:
	JSR RENDER_INIT_INITIALIZE ; 描画初期化
	JSR SOUND_INIT ; サウンド初期化
	JSR PLAYER_INITIALIZE

;------------------------------------------
;　メインループ、NMI割り込みに依存しない計算処理などあればここで
;------------------------------------------
LOOP:
	JSR PLAYER_UPDATE
	JMP LOOP ; メインループへ戻る

;------------------------------------------
; NMI割り込み処理
;------------------------------------------
ON_NMI:
	JSR INPUT_UPDATE_INPUT_STATE
	JSR PLAYER_ON_NMI
	RTS
	

;------------------------------------------
; ソースファイルのインクルードはここで
;------------------------------------------
	INCLUDE "input.asm"
	INCLUDE "render_init.asm"
	INCLUDE "sound.asm"
	INCLUDE "player.asm"


; LDA = PosY
; LDX = PosX
; LDY = Sprite
DRAW_SPRITE:
	;スプライトの描画設定
	STA $2004

	;スプライトのタイル番号
	STY $2004
	
	;属性設定
	LDA #0
	STA $2004
	;x座標
	STX $2004
	RTS