SOUND_INIT:
	; APUの初期化 これで矩形波1とノイズが有効になる
	LDA #%00010001
	STA $4015
	RTS