		org	 0
;sestavte program pro hodiny se zobrazenim bod hod a min
;postup:
;1. nulovani - nastaveni promennych, zobrazeni
;2. nastaveni - min, hod, nulovani, spusteni hodin, min budiku, hod budiku
;3. spusteni - vraceni zpet do nastaveni, nulovani, citani vterin, minut, hodin
;		zobrazeni mnin vt,
nulovani:
	mov	r0,#0		;vteriny
	mov	r1,#0		;minuty, zatim nejake cislo, pak0
	mov 	r2,#0		;hodiny
	mov	r3,#0		;minuty buduiku
	mov	r4,#0		;hodiny budiku
	call	zobraz_h_m
	jmp	nastaveni	;az je-li zobrazeni ok, jinak nulovani
	

nastav_minuty:
	inc	r1	;r1+1
	call	zobraz_h_m
	call 	zp
	cjne	r1,#59, nastaveni
	mov	r1,#255		;0 nespravně!!!
				;je tam ta inkrementace, což znamená, že musíme dát 255
	jmp	nastaveni

nastav_hodiny:
	inc	r2	;r1+1
	call	zobraz_h_m
	call 	zp
	cjne	r2,#23, nastaveni
	mov	r2,#255		;0 nespravně!!!
				;inkrementace(pridava se jednicka), což znamená, že musíme dát 255
	jmp	nastaveni
nastav_hodiny_budiku:
	inc	r4	;r1+1
	call	zobraz_h_m_budiku
	call 	zp
	cjne	r4,#23, nastaveni
	mov	r4,#255		;0 nespravně!!!
				;inkrementace(pridava se jednicka), což znamená, že musíme dát 255
	jmp	nastaveni
nastav_minuty_budiku:
	inc	r3	;r1+1
	call	zobraz_h_m_budiku
	call 	zp
	cjne	r3,#23, nastaveni
	mov	r3,#255		;0 nespravně!!!
				;inkrementace(pridava se jednicka), což znamená, že musíme dát 255
	jmp	nastaveni
nastaveni:	;bitova klavesnice, jen pro maly pocet klaves
	;jnb	p1.0,nastav_minuty	;kl 1
	;jnb	p1.2,nastav_hodiny	;kl 4
	;jnb	p1.5,nulovani		;kl *+#
	;jnb	p1.4,start		;kl S
	;jmp	nastaveni
	
	;bytova klavesnice - cteme cisla klavesnice
	mov	a,p1	;cely port klavesnice do acc	
	cpl	a	;negace - klavesnice je v negativnim rezimu
	cjne	a,#1,qwert	;kl 1 = kdyz acc = cislu, tak program pokracuje dale
				;kdyz acc se nerovna cislu, tak jde na navesti
	jmp	nastav_minuty	
qwert:	cjne	a,#4,werty	;kl 4
	jmp	nastav_hodiny
werty:	cjne	a,#32,rtyu	;kl *+# binarne = 0010 0000 2na5 = 32!!!
	jmp	nulovani
rtyu:	cjne	a,#16,tyui	;kl S binarne = 0001 0000 2na4 = 16
	jmp	start
tyui:	cjne	a,#3,yuio	;kl 3
	jmp	nastav_hodiny_budiku
yuio:	cjne	a,#6,uiop	;kl 6
	jmp	nastav_minuty_budiku
uiop:
	jmp	nastaveni
	
start:
		;pouzijeme Bytovou klavesnici
	mov	a,p1 		;cely port klavesnice do acc
	cpl	a		;negace acc - klavesnice je v negativnim rezimu
	cjne	a,#32,ssss	;kl *+#
	jmp	nulovani	
ssss:	cjne	a,#8,ffff
	jmp	nastaveni	;zastaveni hodin a znovu jejich prestaveni



ffff:	cjne	a,#2,dddd
	call	zobraz_min_vte	;musim zobrazit jen minuty a vteriny!
	jmp	preskoc		;preskocim zobraz hod a min

dddd:	cjne	a,#5,poiuy
	call	zobraz_h_m
	jmp	preskoc
poiuy:
	call	zobraz_h_m
preskoc:
	jmp	vypocet_budiku
zpet:	mov	p3,#01101111b	 ;desetina tecka 2 des tecka 4 = 0100,
	call	zp		;0.25 vterin
	mov	p3,#01011111b	;des tecka 3       des tecka 1 = 0111,
	call	zp		;0.25 vterin
	;vlastni citani hodin
zpet1:	inc	r0		;+1
	cjne	r0,#60,start
	mov	r0,#0
	inc	r1
	cjne	r1,#60,start
	mov	r1,#0
	inc	r2
	cjne	r2,#24,start
	mov	r2,#0
	jmp	start

vypocet_budiku:
	;porovname odectem jak minuty, tak hodiny
	;do acc dame hodiny
	mov	a,r2
	;do b dame hodiny budiku
	mov	b,r4

	;odectem
	subb	a,b	;pozor stane se a-b-cy,
	jnz	zpet	;skok zpet, neni-li nula
	mov	a,r1
	mov	b,r3
	clr	cy
	subb	a,b
	jnz	zpet
	jmp	blikani

blikani:
	call	zobraz_h_m
	call	zp
	mov	p3,#00111111b		;displej nesviti
	mov	p3,#00101111b
	mov	p3,#00011111b
	mov	p3,#00001111b

	call	zp
	jmp	zpet1			;kam?

zobraz_min_vte:
	mov	a,r1	;minuty do acc
	mov	b,#10	;nachystame 10 pro dělení
	div	ab	;delime a/b, pak v acc=desítky, v reg b=jednotky
	orl	a,#00110000b	;disfunkce addr(horní nibble) a dat (dolní nibble)
	mov 	p3,a	;dame na port
	orl	b,#00100000b
	mov	p3,b

	mov	a,r0	;vteriny do acc
	mov	b,#10
	div	ab
	orl	a,#00010000b
	mov	p3,a	
	mov	a,b
	orl	a,#00000000b
	mov	p3,a
	ret		;navrat do podprogramu

zobraz_h_m:
	mov	a,r2	;hodiny do acc
	mov	b,#10	;nachystame 10 pro dělení
	div	ab	;delime a/b, pak v acc=desítky, v reg b=jednotky
	orl	a,#00110000b	;disfunkce addr(horní nibble) a dat (dolní nibble)
	mov 	p3,a	;dame na port
	orl	b,#00100000b
	mov	p3,b

	mov	a,r1	;minuty do acc
	mov	b,#10
	div	ab
	orl	a,#00010000b
	mov	p3,a	
	mov	a,b
	orl	a,#00000000b
	mov	p3,a
	ret		;navrat do podprogramu
zobraz_h_m_budiku:
	mov	a,r4	;hodiny do acc
	mov	b,#10	;nachystame 10 pro dělení
	div	ab	;delime a/b, pak v acc=desítky, v reg b=jednotky
	orl	a,#00110000b	;disfunkce addr(horní nibble) a dat (dolní nibble)
	mov 	p3,a	;dame na port
	orl	b,#00100000b
	mov	p3,b

	mov	a,r3	;minuty do acc
	mov	b,#10
	div	ab
	orl	a,#00010000b
	mov	p3,a	
	mov	a,b
	orl	a,#00000000b
	mov	p3,a
	mov	p3,#01111111b	;desetinna tecka vlevo
	ret		;navrat do podprogramu

zp:	djnz	r7,$
	djnz	r6,$-2
	ret

	end