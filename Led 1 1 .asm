                org 0; adresa zacatku programu 0d  = 00h
           	jmp	zac     
zacatek: ;navesti = adresa pomoci textoveho rezimu

                mov p3,#00111111b	;zaciname od nejvyssiho dipleje cislo 1
                mov p3,#00101111b	;zapis cisla 6
                mov p3,#00011111b	;zapis cisla 2
                mov p3,#00001111b	;zapis cisla 7
         	call zp
         	mov p3,#00110000b	;zaciname od nejvyssiho dipleje cislo 1
                mov p3,#00100000b	;zapis cisla 6
                mov p3,#00010000b	;zapis cisla 2
                mov p3,#00000000b	;zapis cisla 7
         	call zp
                jmp zacatek

zac:		;zobrazte dve dvojciferna cisla 
                ; 42 a 36
                mov	r0,#42
                mov	r1,#36

                ;deleni
                mov	a,r0	;do acc regristr
                mov	b,#10	;pipravim v reg b 10 (budu delit 10)
                div	ab	;deleni, po deleni bude v acc desitky, v b jednotky
                orl	a,#00110000b

zp:		djnz	r7,$
		djnz	r6,$-2
		ret