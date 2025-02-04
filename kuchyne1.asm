	org	0 ;adresa nula
;navrhnete program pro kuchynske hodiny v minutach a vterinach
;postup:
;1. nulovani promennych a zobrazeni na displeji
;2. nastaveni promennych, nulovani a spusteni programu
;3. chod hodin - odecet minut a vterin do nuly, vypocet nulity
;4. blikani - ukonceni programu a vynulovani

nulovani: ;adresa nulovani

	;zvolime promenne v registrech
	mov	r0,#0 ;vteriny - na zacatku vlozime cislo	registr jedna nam háže nulu
	mov	r1,#0 ;minuty - vlozit napred cislo
	call	zobraz ;odskok na zobrazeni

	;skočí na zobraz a vezne sebou poslední hodnotu s registrem(r1,#0), vratí se 
	 	
	;zatim dame zpet na nulovani pro kontrolu zobrazeni
	jmp	nastaveni	;nulovani 
	
	
nastav_minuty:
	inc	r1	;r1+1
	call	zobraz
	call 	zp
	cjne	r1,#59, nastaveni
	mov	r1,#255		;0 nespravně!!!
				;je tam ta inkrementace, což znamená, že musíme dát 255
	jmp	nastaveni

nastav_vteriny:
	cjne	r0,#59,vdale
	mov	r0,#255
vdale:	
	inc	r0	;r0+1
	call	zobraz
	call 	zp
;	cjne	r0,#59, nastaveni ;porovnavá pokud není stejné skoč to na nastavení
;	mov	r0,#255
	jmp	nastaveni
;************************************** nstaveni *************************************
nastaveni:
;bitovy typ klavesnice
	;vyresime typ klavesnice - kl1 - nast vterin, kl4, - minuty
	;			 - kls - start hodin, kl *+# - nulovani
	jnb 	p1.0,nastav_vteriny ;kl1

	;jnb pokud není stisknutá klavesa (bit) skáču
	
	;	bit		7   6   5   4   3   2   1   0
	;	cislo 2na2    128 64   32  16   8   4   2   1	klavesnice
	jnb	p1.2,nastav_minuty	;kl 4
	jnb	p1.5,nulovani		;kl *+#
	jnb	p1.4,start		;kl S
	jmp	nastaveni



start:
	jnb	p1.5,nulovani	;kl *+#
	jnb	p1.3,nastaveni	;k1 8
	call	zobraz
	mov	p3,#01111111b	;desetinna tecka vlevo
	call 	zp1s	;posleze dame 1 vterinu
	jmp	vypocet
dale:	dec	r0	;vteriny - 1
	cjne	r0,#255,start
	mov	r0,#59
	dec	r1
	cjne	r1,#255,start
	mov	r1,#59
	jmp	start

vypocet:	;kontrolovat in=0,vter=0
	cjne	r0,#0,dale
	cjne	r1,#0,dale
	jmp	blikani

blikani:
	jnb	p1.5,nulovani
	mov	p3,#00111111b
	mov	p3,#00101111b
	mov	p3,#00011111b
	mov	p3,#00001111b
	call	zp
	mov	p3,#30h
	mov	p3,#20h
	mov	p3,#10h
	mov	p3,#00h
	call	zp
	jmp	blikani
		
		
zobraz:
	;napred zobrazeime minuty
	;minuty dame do acc
	mov	a,r1	;minuty do acc 

	;45:10=4,5  	4=a,	5=b

	
			;nachystame 10 pro deleni - ziskani desitek
	mov	b,#10	; b je pomocny vypocetni registr, budeme delit 10
	div	ab	;deleni, v acc zustane desitky, v b jednotky
			;logicky secteme acc s adresou dipleje
			;horni nibble= adresa displeje, dolni nibble = cislo
			
	orl	a,#00110000b ;prava cast toho bytu displey, leva cast toho čísla 
	
	mov 	p3,a	;dame na vystup
	orl	b,#00100000b	;jednotky logicky secteme a dalsim displejem
	mov	p3,b	;dame na vystup

	mov	a,r0	;vteriny do acc
	mov	b,#10
	div	ab
	orl	a,#00010000b
	mov	p3,a
			;druha moznost = vratime jednotky do acc
	mov	a,b
	orl	a,#00000000b
	mov	p3,a
	ret	;vracení zpět

zp:	djnz	r7,$	;asi 0,25 vteriny 	dolar adresa aktualního příkazu
	djnz	r6,$-2
	ret
zp1s:
	mov	r5,#4	;asi 1 vterina
	djnz	r7,$
	djnz	r6,$-2
	djnz	r5,$-4
	ret
	
	end
	
	 