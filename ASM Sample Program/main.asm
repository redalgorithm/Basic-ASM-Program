;// Shaanan Curtis
;// CSIS-118B-3104
;// June 27, 2017
;// FINAL

INCLUDE Irvine32.inc
INCLUDE macros.inc

ExitProcess proto, dwExitCode: dword				;// EXITPROCESS PROTOTYPE

FillArray proto,									;// FILLARRAY PROTOTYPE
 address: dword,
 counter: dword,
  typeof: dword

PrintArray proto,									;// PRINTARRAY PROTOTYPE
  address: dword,
  counter: dword,
   typeof: dword,
      col: dword,
	  row: dword,
   spcbnd: dword

FindNegative proto,									;// FINDNEGATIVE PROTOTYPE
   _address: dword,
neg_address: dword,
   _counter: dword,
 neg_typeof: dword,
    _typeof: dword,
neg_counter: dword,
	   cmpz: dword

CalculateSum proto,									;// CALCULATESUM PROTOTYPE
	pointer: dword,
	   posa: dword,
	   posb: dword,
	 typeof: dword

.data
	myarray sdword 12 DUP(?)
	negarray sdword 12 DUP(?)
;/// input
	fprompt byte "Please enter 12 numbers below: ",0dh,0ah,0
;/// display
	processed byte "I have placed your numbers in a table of ",0
	processed2 byte " rows for your convenience...",0dh,0ah,0
;/// search
	nonefound byte "No negative numbers were found in the array",0dh,0ah,0
	found byte "I found ",0
	found2 byte " negative numbers",0dh,0ah,0
	found3 byte "The negative numbers found are: ",0
;/// calculate
	sprompt byte "The sum of the positions 3 and 8 of the array is ",0
;/// vars
	colsize dword 2
	rowsize dword 6
	negcount dword 0
	sum sdword 0

.code
main proc
;/// fill array
	mov edx, offset fprompt							;// display fprompt on console ("Please enter 12 numbers...")		
	call WriteString

	invoke FillArray,								;// Fills array with user's numbers
	  offset myarray,
	lengthof myarray,
		type myarray

;/// print array (6 rows 2 cols)
	mov edx, offset processed						;// display processed on console ("I have placed your numbers in...")
	call WriteString
	mov eax, colsize								;// display colsize on console (2)
	call WriteDec
	mWrite " cols and "								;// add (" cols and ") to console
	mov eax, rowsize								;// display rowsize on console (6)
	call WriteDec
	mov edx, offset processed2						;// display processed2 on console (" rows for your convenience...")
	call WriteString

	invoke PrintArray,								;// Prints array in 2 columns and 6 rows (includes spaces for single digit organization)
				    0,
				  edx,
		 type myarray,
			  colsize,
			  rowsize,
				   10

;/// find negative numbers
	invoke FindNegative,							;// Finds all instances of negative numbers in myarray and displays each along with 
					  0,							;// ...the total that was found
		offset negarray,
	   lengthof myarray,
		  type negarray,
		   type myarray,
	  lengthof negarray,
				      0

;/// find sum
	invoke CalculateSum, 0, 2, 5, type myarray		;// Calculates the sum of positions a and b (2 & 5) in the array, and
	call Crlf										;// ...prints to console

exit
main endp

; // ----------------------------------------------
; // FillArray
; //
; // Receives numbers inputted by user and stores
; // them in myarray.
; // Receives: offset myarray (address), 
; //		   lengthof myarray (counter),
; //		   type myarray (dword)
; // Returns: nothing (filled array)
; // ----------------------------------------------
FillArray proc,
address: dword,
counter: dword,
 typeof: dword

	mov esi, address								;/// point to first element (insertion)
	mov ecx, counter								;/// set loop count
	L1:
		call ReadInt								;/// user input
		mov[esi], eax								;/// store number in array [per element]
		add esi, typeof								;/// point to next element
	loop L1											;/// continue until ecx=0
	call Crlf
ret
FillArray endp

;/// PrintArray proc (invoke)
; // ------------------------------------------------------------------
; // PrintArray
; //
; // Prints recently filled array in a table of 2 columns and 6 rows.
; // Receives: address (ebx=0), edx as counter (convenient storage), 
; //		   type myarray (dword), colsize, and rowsize
; // Returns: printed array via eax
; //		  (includes a space before single digit numbers)
; // -------------------------------------------------------------------
PrintArray proc,
							 address: dword,
							 counter : dword,
							 typeof : dword,
							 col : dword,
							 row : dword,
							 spcbnd : dword

							 mov ebx, address;/// point to first element (extraction)
						 mov ecx, row;/// set row count
					 L2:
						 mov counter, ecx;/// temporarily store counter
						 mov ecx, col;/// set col count
					 L3:
						 mov eax, myarray[ebx];/// extract element and store in eax
						 cmp eax, spcbnd;/// if single digit number, jump to spc to include a space (SDO)
						 jl spc
							 backup :
						 call WriteInt;/// display integer on console
						 mWrite " ";/// add space
						 add ebx, typeof;/// point to next element
						 jmp quit;/// jump to quit
					 spc:
						 mWrite " ";/// initial space for single digit numbers
						 jmp backup;/// return to backup label to complete loop 
					 quit:
						 loop L3;/// loop until col ecx=0
						 mov ecx, counter;/// restore row counter
						 call Crlf
							 loop L2;/// loop until row ecx=0
						 call Crlf
							 ret
							 PrintArray endp

							 ;// FindNegative proc (invoke)
						 ; // -----------------------------------------------------------------
						 ; // FindNegative
						 ; //
						 ; // Finds all instances of negative numbers, stores them,
						 ; // and prints each as well as the number of them found.
						 ; // Receives: address myarray (ebx=0), offset negarray, 
						 ; //           lengthof myarray, type negarray, type myarray,
						 ; //		   lengthof negarray
						 ; // Returns: negcount (number of negs found), printed negs via eax
						 ; // -----------------------------------------------------------------
						 FindNegative proc,
							 _address: dword,
							 neg_address : dword,
							 _counter : dword,
							 neg_typeof : dword,
							 _typeof : dword,
							 neg_counter : dword,
							 cmpz : dword

							 ;// search negs
						 mov ebx, _address;/// point to first element (extraction)
						 mov esi, neg_address;/// point to first element (insertion) [ neg-pos segregation ]
						 mov ecx, _counter;/// set loop count (search)
					 L4:
						 mov eax, myarray[ebx];/// extract element and store into eax
						 cmp eax, cmpz;/// if number is negative, jump to negative label
						 jl negative
							 jmp skiploop;/// otherwise, skip to next element
					 negative:
						 mov[esi], eax;/// store number in negarray
						 add esi, neg_typeof;/// point to next element (negarray)
						 inc negcount;/// increment number of negatives found (starting from 0)
					 skiploop:
						 add ebx, _typeof;/// point to next element (myarray)
						 loop L4;/// loop until ecx=0

						 mov eax, negcount;/// store total of negs found in eax
						 cmp eax, cmpz;/// if none found, jump to noneg label
						 je noneg
							 mov edx, offset found;/// otherwise, display found on console ("I found ")
						 call WriteString
							 call WriteDec;/// display total negatives found on console
						 mov edx, offset found2;/// display found2 on console (" negative numbers")
						 call WriteString
							 mov edx, offset found3;/// display found3 on console ("The negative numbers found are: ")
						 call WriteString

							 ;// display negs
						 mov ebx, _address;/// point to first element (extraction)
						 mov ecx, neg_counter;/// set loop count
					 L6:
						 mov eax, negarray[ebx];/// extract element from negarray and store into eax
						 cmp eax, cmpz;/// if zeroes are found, ignore
						 je skip
							 call WriteInt;/// otherwise, display integer
						 mWrite " ";/// add a space
					 skip:
						 add ebx, neg_typeof;/// point to next element
						 loop L6;/// loop until ecx=0
						 call Crlf
							 call Crlf
							 jmp quit;/// jump to quit

						 ;// if no negative numbers were found...
					 noneg:
						 mov edx, offset nonefound;/// display nonefound on console ("No negative numbers were found...")
						 call WriteString
							 call Crlf
							 quit :
						 ret
							 FindNegative endp

							 ; // ----------------------------------------------------------
						 ; // CalculateSum
						 ; //
						 ; // Displays the sum of positions a and b
						 ; // Receives: pointer (ebx=0), position a, position b, type myarray
						 ; // Returns: sum of positions a & b via eax
						 ; // ----------------------------------------------------------
						 CalculateSum proc,
							 pointer: dword,
							 posa : dword,
							 posb : dword,
							 typeof : dword

							 mov eax, sum;/// store sum in eax (initially 0)
						 mov ebx, pointer;/// point to first element (extraction)

						 ;// point to position a
						 mov ecx, posa;/// set loop count to stop at position a
					 L7:
						 add ebx, typeof;/// point to next element (until posa is reached)
						 loop L7
							 add eax, myarray[ebx];/// add number to sum

						 ;// point to position b
						 mov ecx, posb;/// set loop count to stop at position b
					 L8:
						 add ebx, typeof;/// point to next element (until posb is reached)
						 loop L8
							 add eax, myarray[ebx];/// add number to sum

						 ;// display sum (posa + posb)
						 mov edx, offset sprompt;/// display sprompt on console ("The sum of the positions 3 and 8...")
						 call WriteString
							 call WriteInt;/// display sum
						 call Crlf
							 ret
							 CalculateSum endp
							 end main