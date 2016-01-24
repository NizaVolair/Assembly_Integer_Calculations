TITLE Integer Calculations      (NizaVolairIntegerCalculations.asm)

; Name: Niza Volair
; Email: nizavolair@gmail.com
; Date: 11 - 22 - 15
; Description: Program to generate an array of random numbers, sort them, print them and find the median

INCLUDE Irvine32.inc

; upper and lower limits for input range checking of input and randomly generated numbers
; min, max, lo, and hi must be declared and used as global constants.
MIN = 10
MAX = 200
LO = 100
HI = 999

.data

intro		BYTE	"Sorting Random Integers Programmed by Niza Volair", 0ah, 0dh, 0ah, 0dh
			BYTE 	"This program generates random numbers in the range[100 .. 999],", 0ah, 0dh
			BYTE	"displays the original list, sorts the list, and calculates the median value.", 0ah, 0dh
			BYTE	"Finally, it displays the list sorted in descending order.", 0
	

inst		BYTE	"How many numbers should be generated ? [10 .. 200]: ", 0

error		BYTE	"Invalid input", 0

title1		BYTE	"The unsorted random numbers: ", 0

median		BYTE	"The median number: ", 0

title2		BYTE	"The sorted list: ", 0

spaces		BYTE	"   ", 0

request		DWORD	?

numArray	DWORD	MAX DUP(? )

curCol		DWORD	0

.code
main PROC

; Introduce the program.The title, programmer's name, and brief instructions must be displayed on the screen.
	push	OFFSET intro
	call	introduction

; Get a user request in the range[min = 10 ..max = 200].The program must validate the user’s request.
	push	OFFSET inst
	push	OFFSET error
	push	OFFSET request
	call	getData					; { parameters: request(reference)}

	; Test Code for request
		;mov	eax, request
		;call	WriteDec
		;call	Crlf

; Generate request random integers in the range[lo = 100 ..hi = 999], storing them in consecutive elements of an array.
	call	randomize	

	push	OFFSET numArray
	push	request
	call	fillArray				; fill array {parameters: request(value), array(reference)}


; Display the list of integers before sorting, 10 numbers per line.
		; display list{ parameters: array(reference), request(value), title(reference) }
		push	OFFSET title1
		push	curCol
		push	OFFSET spaces
		push	OFFSET numArray
		push	request

		call	showArray

	; Test Code for display
		; mov	edi, OFFSET numArray
		; mov	ecx, request

		testPrint :
			;mov	eax, [edi]
			;call	WriteDec
			;call	Crlf
			;add	edi, 4

			;loop	testPrint
					
; Sort the list in descending order(i.e., largest first).
	; sort list{ parameters: array(reference), request(value) }
	push	OFFSET numArray
	push	request
	call	sortArray
	
; Calculate and display the median value, rounded to the nearest integer.
	; display median{ parameters: array(reference), request(value) }
	push	OFFSET median
	push	OFFSET numArray
	push	request
	call	getMedian

; Display the sorted list, 10 numbers per line.
	; display list again{ parameters: array(reference), request(value), title(reference) }
	push	OFFSET title2
	push	curCol
	push	OFFSET spaces
	push	OFFSET numArray
	push	request

	call	showArray
 

exit; exit to operating system
main ENDP

; Procedure to display introduction of program
; receives: intro(ref)
; returns: displays intro to screen
; preconditions: intro is initialized
; registers changed: edx, ebp, esp
introduction	PROC

; set up stackframe
	push	ebp
	mov		ebp, esp

; introduce the program	
	mov		edx, [ebp + 8]
	call	WriteString
	call	Crlf
	call	Crlf

	pop		ebp
	ret 4

introduction	ENDP


; Procedure to get user input and validates input
; receives: address of num and offset of inst and error pushed on stack, MAX and MIN are global
; returns: instructions printed to screen and valid integer in num
; preconditions:  inst, error are initialized and num is pushed on stack
; registers changed: eax, edx, ebx, ebp
getData	PROC

; set up stackframe
	push	ebp
	mov		ebp, esp

getNum:								; prompt for and get integer and put in num variable
	mov		edx, [ebp + 16]
	call	WriteString
	call	ReadInt

; validate input by comparing integer to MAX and MIN limits
	cmp		eax, MAX				; if greater than upper limit jump to error message and reprompt
	jg		rangeError

	cmp		eax, MIN				; if lower than lower limit jump to error message and reprompt
	jl		rangeError

	call	Crlf
	jmp		valid					; procedure should skip over rangeError unless there is an issue


	rangeError :
		mov		edx, [ebp + 12]
		call	WriteString
		call	Crlf
		jmp		getNum				; user should be prompted to re-enter the number

valid:								; input was valid so put it in the address of the num variable on the stack and return
	mov		ebx, [ebp + 8]
	mov		[ebx], eax

	pop ebp
	ret 12

getData	ENDP

; Procedure to fill an array with random numbers
; receives: value of request pushed onstack, offset of array pushed on stack
; returns: an array of the amount of requested random numbers
; preconditions:  array and request are initialized
; registers changed: eax, edx, ebc, ecx, edi
fillArray	PROC

; set up stackframe
	push	ebp
	mov		ebp, esp

; put the request(count) in ecx and the starting address of the array in the edi
	mov		ecx, [ebp + 8]			
	mov		edi, [ebp + 12]			
	
addRandomNumToArray:				;gets the amount of random numbers requested in the eax and add each to the array 
	mov		eax,HI
	sub		eax,LO
	inc		eax
	call	RandomRange
	add		eax, LO

	mov		[edi], eax
	add		edi, 4

	loop	addRandomNumToArray

	pop ebp
	ret 8

fillArray	ENDP

; Procedure to display numbers aligned in lines and rows
; receives: title(ref), current column(val), spaces(ref), array(ref), request(val)
; returns: a title and up to 200 numbers aligned in lines and rows
; preconditions: title, curCol, spaces, array, and count are initialized
; registers changed : eax, ecx, edx, ebx, ebp, esi
showArray	PROC

; set up stackframe
	push	ebp
	mov		ebp, esp

; display title
	mov		edx, [ebp + 24]
	call	WriteString
	call	Crlf

; put the request(count) in ecx and the starting address of the array in the edi
	mov		ecx, [ebp + 8]
	mov		esi, [ebp + 12]
	mov		ebx, [ebp + 20]

print:									
	mov		eax, [esi]
	call	writeDec

	mov		edx, [ebp + 16]
	call	WriteString					; print spaces

	add		esi, 4	
	
	; check if row needs to be increased
		inc		ebx						; The results should be displayed 10 composites per line
		cmp		ebx, 10					; check if new row is needed
		je		newRow					; make new row if needed
		jl		loopAgain
			
		newRow :						; rows and columns for display
		call	Crlf
		mov		ebx, 0

	loopAgain :							; loop back to print another composite
	loop	print						

	call	Crlf
	call	Crlf

	pop		ebp
	ret		20

showArray	ENDP


; Procedure to sort an array in decending order (source: IRVINE 375)
; receives: array(ref), request(val)
; returns: sorts up to 200 numbers in decending order in an array
; preconditions: array, and request are initialized
; registers changed : eax, ecx, edx, ebx, ebp, esi
sortArray	PROC

; set up stackframe
	push	ebp
	mov		ebp, esp
	
	mov		ecx, [ebp + 8]
	dec		ecx

L1:										; outter loop saves the count and gets the first value for comparison
	push	ecx
	mov		esi, [ebp+12]
	
L2:										; inner loop compares current value to following values and exchanges if needed
	mov		eax, [esi]
	cmp		[esi + 4], eax
	jl		L3
	xchg	eax, [esi+4]
	mov		[esi], eax

L3:										; continues the inner loop through all following unsorted values, when finished jumps to outer loop to check next value
	add		esi, 4
	loop	L2

	pop		ecx
	loop	L1

	pop ebp
	ret 8

sortArray	ENDP


; Procedure to show the median value in a sorted array
; receives: median display string(ref), array(ref), request(val)
; returns: prints a label and median value
; preconditions: median display, array, and request are initialized
; registers changed : eax, ecx, edx, ebx, ebp, esi
getMedian	PROC

; set up stackframe and put offset of array in esi
	push	ebp
	mov		ebp, esp

	mov		esi, [ebp + 12]

; display title
	mov		edx, [ebp + 16]
	call	WriteString

; divide request and 2 
	mov		edx, 0
	mov		eax, [ebp + 8]
	mov		ebx, 2
	div		ebx

	;Test code to display registers and check median calculation
		;call	WriteDec
		;call	Crlf
		;mov		ebx, eax

		;mov		eax, edx
		;call	WriteDec
		;call	Crlf
		
		;mov		eax, ebx

	cmp		edx, 1						; if edx has 1 the number is odd if not, it is even so jump to the correct calculations
	je		oddRequest
	jmp		EvenRequest

OddRequest:								; if the request is odd then get the value at the location of request/2 (the middle) and print
	mov		ebx, [esi + eax * 4]		; this moves in the address and the next line dereferences it
	mov		eax, ebx
	call	WriteDec
	call	Crlf
	call	Crlf

	jmp		Finish

EvenRequest:							; if the request is even, get the value before request/2 and the value at request/2
	mov		ebx, [esi + eax * 4]
	mov		edx, ebx
	dec		eax
	mov		ebx, [esi + eax * 4]
	add		edx, ebx
	mov		eax, edx
	;Test code to check calculations
		;call	WriteDec
		;call	Crlf
	mov		edx, 0
	mov		ebx, 2						; now divide the total by 2 to get the average which is the median
	div		ebx
	call	WriteDec
	call	Crlf
	call	Crlf

Finish:
	pop ebp
	ret 12

getMedian	ENDP


END main