;コントローラの入力を管理するルーチン
; $20から + 8までのアドレスに入力状態をセットする
; 20から A,B, Select , Start ,Up, Down ,Left , Rightの順で入る
INPUT_UPDATE_INPUT_STATE:
	;4016に01を書き込むとコントローラの入力状態をリセットする
	LDA #$01
	STA $4016
	;0を書き込んで読み出しを有効化
	LDA #$00
	STA $4016

	LDY #$00 ;インデックスとしてYレジスタを使う

INPUT_GET_BUTTON_STATE:
	LDA $4016
	AND #$01

	STA $20,Y
	INY
	CPY #$08
	BNE INPUT_GET_BUTTON_STATE

	RTS