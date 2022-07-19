dosseg
.model small
.stack 100h
;======Declaring Structure======;
CellInfo STRUC 
		ASCII db ?
		sX db ?
		sY db ?
		tX db ?
		tY db ?
		color db ?
CellInfo ENDS
;======Declaring Structure======;
.data
;======Declaring Variables======;
	topRow db 5
	leftCol db 20
	lowerRow db 10
	rightCol db 26
	Color1 db 00000111b
	Color2 db 01110000b
	Color3 db ?
	textRow db 6
	textCol db 23
	char db 'A'
	scanCode db ?
	ASCIICode db ?
	cells CellInfo 25 DUP(<>)
	tSize dw ?
	horCoord db ?
	verCoord db ?
	count db 0
;======Declaring Variables======;
.code
main proc
	mov ax, @data
	mov ds,ax
	
;======Video Mode======;
	mov ah, 0
	mov al, 3
	int 10h

;======Printing Grid======;
	mov si, OFFSET cells
	mov tSize, Type CellInfo
	
	mov cx,0
	L1:
		INC cx
		PUSH cx
		mov cx,0
		L2:	
			INC cx
			PUSH cx
			
			;======Printing Square======;
			mov AH, 07h
			mov AL, 03
			mov bh, Color2
			mov ch, topRow   ;upper row num
			mov cl, leftCol  ;left col num
			mov dh, lowerRow ;lower row number
			mov dl, rightCol ;right col number
			int 10H	

			;======Exchanging Colors======;
			PUSH cx
			mov cl,Color1
			mov ch,Color2
			XCHG ch,Color1
			XCHG cl,Color2
			POP cx
		
			;======Setting Cursor Position======;
			mov  ah, 02h	  ;SetCursorPosition
			mov  dh, textRow  ;Row num
			mov  dl, textCol  ;Col num
			mov  bh, 0    	  ;Display page
			int  10h
	
			;======Printing Character======;
			mov  ah, 0Eh  ;Teletype
			mov  al, char
			int  10h
			
			JMP storeInfoInStructure
			setBound4:		
		
		CMP cx,5
		JNE L2
		
		;======Setting Coordinates======;
		add topRow,3
		add lowerRow,3
		mov leftCol,20
		mov rightCol,26
		add textRow,3
		mov textCol,23
		
		POP cx
		
	CMP cx,5
	JNE L1

	JMP KeyPress
	
	;======Storing Info In Structure======;
	storeInfoInStructure:
		mov ah, char
		mov (CellInfo PTR [si]).ASCII, ah
		mov ah, topRow
		mov (CellInfo PTR [si]).sX, ah
		mov ah, leftCol
		mov (CellInfo PTR [si]).sY, ah
		mov ah, textRow
		mov (CellInfo PTR [si]).tX, ah
		mov ah, textCol
		mov (CellInfo PTR [si]).tY, ah
		mov ah, color1
		mov (CellInfo PTR [si]).color, ah
		
		;======Setting Coordinates======;
		add si, tSize
		INC char
		add textCol,7
		add leftcol,7
		add rightCol,7
		POP cx
		JMP setBound4

;======Checking Key Pressed======;
	KeyPress:
		mov ah,0h
		int 16h
		mov scanCode, ah
		mov ASCIICode, al
		mov si, OFFSET cells
		mov count, 0
		
;======Checking If Button Pressed Is Between Alphabets A-Y======;
			CheckAscII:
				mov ch, (CellInfo PTR [si]).ASCII
				CMP ASCIICode, ch
				JE CheckName
				add si, tSize
				INC count
				CMP count, 25
				JE KeyPress
				JMP CheckAscII
				
;======Checks For Printing Name Only======;
			CheckName:
				CMP ASCIICode, 'S'
				JE PrintSquare
				CMP ASCIICode, 'A'
				JE PrintSquare
				CMP ASCIICode, 'M'
				JE PrintSquare
				CMP ASCIICode, 'E'
				JE PrintSquare
				CMP ASCIICode, 'T'
				JE PrintSquare
				JNE KeyPress
		
			setBound2:
				JMP KeyPress
				
;======Printing Square======;
			PrintSquare:
				mov bh, (CellInfo PTR [si]).sX
				mov topRow, bh
				mov bh, (CellInfo PTR [si]).sY
				mov leftCol, bh
			
				mov AH, 07h
				mov AL, 03
				mov bh, 00100111b
				mov ch, topRow 		; upper row num
				mov cl, leftCol  	; left col num
				add topRow, 2
				mov dh, topRow  	;lower row number
				add leftCol, 6
				mov dl, leftCol 	;right col number
				int 10H
					
				mov  ah, 02h		;SetCursorPosition
				mov  dh, (CellInfo PTR [si]).tX  	;Row num
				mov  dl, (CellInfo PTR [si]).tY    ;Col num
				mov  bh, 0    		;Display page
				int  10h

				mov  ah, 0Eh  		;Teletype
				mov  al, (CellInfo PTR [si]).ASCII
				int  10h
				
				CMP ASCIICode, 'T'
				JNE setBound2
			
;======Checking Click Of Mouse======;
	MouseCheck:
		mov ax,01
		int 33h
	
		mov ax,03
		int 33h
	
		CMP bl,1
		JNE MouseCheck
	
		mov ax, cx
		mov bl,8
		div bl
		mov horCoord, al
		mov ax, dx
		div bl
		mov verCoord, al

		mov cx, 0
		mov si, OFFSET cells
		L3:
			INC cx
			
			CMP cx, 25
			JA MouseCheck
			
;======Comparisons To Check Click Is In The Box Or Not======;
			;======For Starting X======;
			mov bh, (CellInfo PTR [si]).sX
			CMP verCoord,bh
			JAE comp1
			add si, tSize
			JMP L3
			
			;======For Starting Y======;
			comp1:
				mov bh, (CellInfo PTR [si]).sY
				CMP horCoord, bh
				JAE comp2
				add si, tSize
				JMP L3
				
			;======For Ending Y======;
			comp2:
				add si, tSize
				mov bh, (CellInfo PTR [si]).sY
				CMP horCoord, bh
				JB comp3
				sub si, tSize
				CMP (CellInfo PTR [si]).ASCII, 'E'
				JE comp5
				CMP (CellInfo PTR [si]).ASCII, 'J'
				JE comp5
				CMP (CellInfo PTR [si]).ASCII, 'O'
				JE comp5
				CMP (CellInfo PTR [si]).ASCII, 'T'
				JE comp5
				CMP (CellInfo PTR [si]).ASCII, 'Y'
				JE comp5
				add si, tSize
				JMP L3
				
			setBound1:
				JMP MouseCheck
				
			setBound5:
				JMP L3
				
			;======For Ending X======;
			comp3:
				sub si, tSize
				CMP (CellInfo PTR [si]).ASCII, 'U'
				JAE comp4
				add si, tSize
				add si, tSize
				add si, tSize
				add si, tSize
				add si, tSize
				mov bh, (CellInfo PTR [si]).sX
				sub si, tSize
				sub si, tSize
				sub si, tSize
				sub si, tSize
				sub si, tSize
				CMP verCoord,bh
				JB PrintSquare1
				add si, tSize
				JMP L3
			
			;======For Last Row======;			
			comp4:
				mov bh, (CellInfo PTR [si]).sX
				add bh, 3
				CMP verCoord, bh
				JB PrintSquare1
				add si, tSize
				JMP L3
				
			;======For Last Col======;
			comp5:
				mov bh, (CellInfo PTR [si]).sY
				add bh, 7
				CMP horCoord, bh
				JB comp6 
				add si, tSize
				JMP L3
			
			;======For Last Col======;			
			comp6:
				add si,tSize
				JMP comp3
		CMP cx,25
		JNE setBound5
		JE setBound1
	
	;======Setting Color Of Black Square======;
	setColor:
		mov Color3, 01000111b
		JMP ContinueToPrint
		
	;======Setting Color Of White Square======;
	setColor1:
		mov Color3, 00010000b
		JMP ContinueToPrint
	
	;======Printing Square======;
	PrintSquare1:
		mov Color1, 00000111b
		mov Color2, 01110000b
		
		mov ch, (CellInfo PTR [si]).color
		CMP ch, Color1
		JE setColor
		JNE setColor1
		
		ContinueToPrint:
		
		mov ch, (CellInfo PTR [si]).sX
		mov topRow, ch
		add ch, 2
		mov lowerRow, ch
		mov ch, (CellInfo PTR [si]).sY
		mov leftCol, ch
		add ch,6
		mov rightCol, ch
		
		mov AH, 07h
		mov AL, 03
		mov bh, Color3
		mov ch, topRow  ; upper row num
		mov cl, leftCol  ; left col num
		mov dh, lowerRow ;lower row number
		mov dl, rightCol ;right col number
		int 10H
	
		mov  ah, 02h		;SetCursorPosition
		mov  dh, (CellInfo PTR [si]).tX  	;Row num
		mov  dl, (CellInfo PTR [si]).tY    ;Col num
		mov  bh, 0    		;Display page
		int  10h

		mov  ah, 0Eh  		;Teletype
		mov  al, (CellInfo PTR [si]).ASCII
		int  10h
	
		JMP MouseCheck
	
	mov ah,4ch
	int 21h

main endP
end main
