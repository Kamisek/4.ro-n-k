	org	0
;Nävrhnete program pro pristupovy system s 4 piny a 4 puky s prenastavenim pin
;		*****		*****		*****		*****
;		*   *		*   *		*   *		*   *
;		*****		*****		*****		*****
;		*   *		*   *		*   *		*   *
;		*****		*****		*****		*****
;adresa displeje - horni nibble
;addr1		0011		0010		0001		0000
;adresa video v RAM od 20h
;		23h		22h		21h		20h
;adresa pin	27h		26h		25h		24h
;adresa puk	2bh		2ah		29h		28h

nulovani:
	mov	23h,#0	;video pro zobrazeni	
	mov	22h,#0
	mov	21h,#0
	mov	20h,#0

	mov	27h,#4
	mov	26h,#4
	mov	25h,#4
	mov	24h,#4	;pin - napred dame sama stejna cisla
			;puk - dame opet stejne cisla
	mov	2bh,#6
	mov	2ah,#6
	mov	29h,#6
	mov	28h,#6

	call	 zobraz_video

;	jmp	 nulovani	;na zacatku opakujeme pro kontrolu zobrazeni
				;dame do videa same nuly
				;pokud jsou nuly zmenime skok na klavesnici
	jmp	klavesnice_video

nula_video:
	mov	a,#0	;tvrdá nula
	jmp 	prepocet

klavesnice_video:
;potrebujeme vsechna cisla > Bytova klavesnice
	mov	a,p1	;prectu cely part lavesnice do acc
	jnb	p1.4,nula_video
	cpl	a	;musime udelat negaci
	jz	klavesnice_video ;neni nic zmacknute

prepocet:
	mov	23h,22h
	mov	22h,21h
	mov	21h,20h
	mov	20h,a	;cislo z klavesnice
	call	zobraz_video
	call	zp	;nutne pro dalsi cislo z klavesnice
	jmp	vypocet_pin
zpet:	jmp	klavesnice_video

vypocet_pin:		;zpet opet jmp, tzn na zpět

		
zobraz_video:
	mov	a,23h		;cislo z pameti do acc
	orl	a,#00110000b	;logicke secteni s addr displeje
	mov	p3,a		;dame na vystup portu displeje
	mov	a,22h
	orl	a,#00100000b
	mov	p3,a
	mov	a,21h
	orl	a,#00010000b
	mov	p3,a
	mov	a,20h
	orl	a,#00000000b
	mov	p3,a
	ret		;navrat do programu

zp:	djnz	r7,$	;asi 0.25 vterin
	djnz	r6,$-2
	ret	

	end