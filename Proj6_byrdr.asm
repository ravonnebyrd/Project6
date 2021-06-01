TITLE String Primitives & MACROs     (Proj6_byrdr.asm)

; Author: Ravonne Byrd
; Last Modified: May 28, 2021
; OSU email address: byrdr@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: June 6, 2021
; Description: TODO

INCLUDE Irvine32.inc

;-----------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; This MACRO processes strings by using Irvine's ReadString 
;   to get user input.
;
; Preconditions:    Uses and restores edx, ecx, eax
;                   Uses mDisplayString - which cannot accept argument using edx. 
;
; Postconditions: None
;
; Receives:
;           offsetPrompt                = reference input parameter, prompt string array
;           offsetUserInputStorage      = reference output parameter, user entered string 
;           maxArray                    = value input parameter, max size of array allowed for input
;           lengthInput                 = reference output parameter, actual size, in bytes, of input
;
; Returns:
;            offsetUserInputStorage      = reference output parameter, user entered string
;            lengthInput                 = reference output parameter, actual size, in bytes, of user input
;-------------------------------------------------------------------------------------------------------------
mGetString MACRO offsetPrompt:REQ, offsetUserInputStorage:REQ, maxArray:REQ, lengthInput:REQ
    push    edx
    push    ecx
    push    eax

    ; display prompt
    mDisplayString  offsetPrompt

    ; get user input
    mov     edx, offsetUserInputStorage
    mov     ecx, maxArray
    call    ReadString
    mov     DWORD PTR [lengthInput], eax

    pop     eax
    pop     ecx
    pop     edx
ENDM

;---------------------------------------------------------------------------
; Name: mDisplayString
;
; This MACRO uses Irvine's WriteString to print a memory addressed string.
;
; Preconditions: Do not use edx as an argument.
;
; Postconditions: edx (used and restored)
;
; Receives:
;           offsetString = reference input parameter, string array address
;
; Returns: None
;--------------------------------------------------------------------------
mDisplayString MACRO offsetString:REQ
    push    edx
    mov     edx, offsetString
    call    WriteString
    pop     edx
ENDM


; constant definitions
LO_INT_SDWORD       =   2147483648
HI_INT_SDWORD       =   2147483647

LO_ASCII_DEC_NUM    =   48
HI_ASCII_DEC_NUM    =   57

NEG_SIGN            =   45
POS_SIGN            =   43

ZERO                =   0
ONE                 =   1
TEN                 =   10
ELEVEN              =   11
FORTY_EIGHT         =   48
FIFTY               =   50

.data
    ; string array variables
    programTitle                BYTE        "Lower-Level I/O Procedures for Numerical Strings by Ravonne Byrd",0
    programDescription          BYTE        "If you input 10 integers that can each fit in a signed doubleword,",13,10,
                                            "this program will display that list of integers, as well as",13,10,
                                            "report back their sum and rounded average.",13,10,0
    userPrompt                  BYTE        "Please enter your integer: ",0
    secondUserPrompt            BYTE        "Try again: ",0
    errorMessage                BYTE        "Are you sure that was an integer? Maybe it was too large for 32-bits.",13,10,0
    userEntered                 BYTE        "You entered: ",0
    userSum                     BYTE        "Their sum: ",0
    userAverage                 BYTE        "Their average: ",0
    goodbyeMessage              BYTE        "Thank you for your participation, and please enjoy your day.",13,10,0

    ; variables for user input
    userNum                     BYTE        FIFTY DUP(?)           ; user input buffer
    maxCharUserNum              DWORD       SIZEOF userNum      ; max size of userNum
    byteCount                   DWORD       ?                   ; holds count of actual bytes used in userNum

    ; ReadVal procedure variables
    numInt                      SDWORD      ZERO 
    negate                      DWORD       ZERO                   ; boolean
    tempHoldAL                  SDWORD      ZERO
    
    ; main procedure loop variables
    intArray                    SDWORD      TEN DUP(?)
    lengthIntArray              SDWORD       LENGTHOF intArray
    typeIntArray                SDWORD       TYPE intArray

    sum                         SDWORD      ?
    average                     SDWORD      ?
    comma                       BYTE        ", ",0
    newString                   BYTE        ELEVEN DUP(?)

.code
main PROC
;--------------------------------------------------------------
; A. Introduction
;--------------------------------------------------------------
    push    offset programTitle
    push    offset programDescription
    call    Introduction

;--------------------------------------------------------------
; B. Retrieving user input
;--------------------------------------------------------------
    ;--------------------------------------------------------------
    ; This loop gets ten valid signed integers from the user.
    ;   It will store these integers in the array, intArray.
    ;--------------------------------------------------------------
    ; set up for _getInputLoop
    mov     ecx, LENGTHOF intArray
    mov     esi, offset intArray

_getInputLoop: 
    push    offset tempHoldAL
    push    offset errorMessage
    push    offset negate
    push    offset secondUserPrompt
    push    offset numInt
    push    offset userPrompt
    push    offset userNum
    push    maxCharUserNum
    push    offset byteCount
    call    ReadVal
    
    ; add current numInt into intArray, via ebx
    mov     ebx, numInt                 
    mov     SDWORD PTR [esi], ebx

     ; clear numInt for next iteration
    mov     numInt, ZERO               
    add     esi, typeIntArray          

    LOOP    _getInputLoop

;--------------------------------------------------------------
; C. Display to the user their list of ten valid integers.
;--------------------------------------------------------------
    ; Display Prompt
    mov     eax, offset userEntered
    mDisplayString  eax

    ;--------------------------------------------------------------
    ; This loop displays the integers from intArray as ASCII  
    ;   strings, using the WriteVal procedure.
    ;--------------------------------------------------------------
    ; set up for _displayIntArrayASCII
    mov     ecx, lengthIntArray
    mov     esi, offset intArray

_displayIntArrayASCII:
    ; put element (int) into eax
    mov     eax, [esi]

    ; Write integer as ASCII
    push    offset newString
    push    eax
    call    WriteVal

    ; Inserting comma after number
    mov     eax, offset comma
    mDisplayString  eax

    ; increment esi
    add     esi, TYPE intArray
    LOOP    _displayIntArrayASCII

;--------------------------------------------------------------
; D. Display to the user the sum
;--------------------------------------------------------------
    ; Calculate sum
    push    lengthIntArray
    push    typeIntArray
    push    offset sum
    push    offset intArray
    call    CalculateSum

    ; Display prompt
    mov     eax, offset userSum
    mDisplayString  eax

    ; Display sum
    push    sum
    call    WriteVal

;--------------------------------------------------------------
; E. Display to the user the rounded average.
;--------------------------------------------------------------
    ; Calculate average
    push    lengthIntArray
    push    sum
    push    offset average
    call    CalculateAverage

    ; Display prompt
    mov     eax, offset userAverage
    mDisplayString  eax

    ; Display average
    push    average
    call    WriteVal

;--------------------------------------------------------------
; F. Goodbye
;--------------------------------------------------------------
    push    offset goodbyeMessage
    call    Goodbye

    Invoke ExitProcess,0	; exit to operating system
main ENDP

;---------------------------------------------------------------------------------
; Name: Introduction
;
; This procedure displays the program's title, author, and description
;   to the user.
;
; Preconditions: Uses mDisplayString - which cannot accept argument using edx. 
;
; Postconditions: None
;
; Receives:
;           [ebp+16] = reference of string input parameter - program's title
;           [ebp+12] = reference of string input parameter - program's description
;
; Returns: None
;-----------------------------------------------------------------------------------
Introduction PROC USES edx
    push    ebp
    mov     ebp, esp

    call                CrLf
    mDisplayString      [ebp+16]
    call                CrLf
    call                CrLf
    mDisplayString      [ebp+12]
    call                CrLf

    pop     ebp
    RET     8
Introduction EndP

;----------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure uses mGetString to prompt the user for a number, which is stored in memory as
;   a string. It then uses an algorithm to check that the number th user has inputted is indeed a
;   number, and validates that it is within range. The procedure returns the string as a signed integer.
;
; Preconditions: Uses and restores eax ecx edx esi ebx
;               Uses mGetString, which uses and restores edx, ecx.
;
; Postconditions: None
;
; Receives:
;           [ebp+60]    =   reference output parameter, tempHoldAL
;           [ebp+56]    =   reference input parameter, error message
;           [ebp+52]    =   reference output parameter, negate
;           [ebp+48]    =   reference input parameter, try again prompt
;           [ebp+44]    =   reference output parameter, int to add to array of user inputted values
;       Primarily for mGetString:
;           [ebp+40]    =   reference input parameter, prompt string array
;           [ebp+36]    =   reference output parameter, user entered string 
;           [ebp+32]    =   value input parameter, max size of array allowed for input
;           [ebp+28]    =   reference output parameter, actual size, in bytes, of input
;
; Returns:
;           [ebp+44]    =   reference output parameter, int to add to array of user inputted values
;-----------------------------------------------------------------------------------------------------
ReadVal PROC USES eax ecx edx esi ebx
    push    ebp
    mov     ebp, esp

_firstTry:
    mGetString      [ebp+40], [ebp+36], [ebp+32], [ebp+28]
    jmp     _setUp

;----------------------------------------------------------------------
; Jump to _tryAgain instead of _firstTry after an error because _tryAgain 
;   will display the special error prompt for the user.
;----------------------------------------------------------------------
_tryAgain:
    mGetString      [ebp+48], [ebp+36], [ebp+32], [ebp+28]

;----------------------------------------------------------------------
; Setting Up the Validation Loop
;   Moving esi to point to the user entered string [ebp+36]
;   Moving ecx to equal the actual amount bytes in the user string. 
;----------------------------------------------------------------------
_setUp:
    mov     esi, [ebp+36]
    mov     ecx, [ebp+28]               

;----------------------------------------------------------------------
; Validation Loop
;   The first time the loop iterates, it first checks if there is a neg
;       or pos sign. If there is a neg sign, the loop will deal with  
;       negating the final output. 
;   For both neg or pos, must skip aritmetic and jump to end of loop.
;   After this first iteration, only numbers are allowed...
;       (i.e. _noSymbolsValidationLoop).
;   This loop includes validation - that the user inputted string is
;       indeed a number, and that it's within the correct SDWORD range.
;   While validating, this loop is creating SDWORD from ASCII values.
;----------------------------------------------------------------------
_validationLoop:
    LODSB
    cmp     AL, NEG_SIGN
    je      _negate
    cmp     AL, POS_SIGN
    je      _continueValidationFromNegPosSign
    jmp     _firstValidationContinue

_noSymbolsValidationLoop:
    LODSB
_firstValidationContinue:
    cmp     AL, LO_ASCII_DEC_NUM
    jb      _error
    cmp     AL, HI_ASCII_DEC_NUM
    ja      _error

    ;----------------------------------------------------------------------
    ; Main aritmethic of alogrithm 
    ;   Converts a string into it's SDWORD integer representation.
    ;   1. First, store offset of tempHoldAl in ebx, then store current
    ;       value of AL in tempHoldAL, since we need eax for multiplication.
    ;   2. Next, store offset of numInt in edx, and move current value 
    ;       of numInt into eax. 
    ;   3. Multiply eax by 10.
    ;       Check for any overflow, which is an instant jump to error.
    ;   4. Add value of tempHoldAl to eax
    ;   5. Store new numInt value in numInt (not finalized, and is crucial 
    ;       to aritmethic as long as loop is in effect).
    ;-----------------------------------------------------------------------
    sub     AL, FORTY_EIGHT             ; (AL - 48) - to get non-ASCII value 
    mov     ebx, [ebp+60]               ; 1
    mov     BYTE PTR [ebx], AL            
    mov     edx, [ebp+44]               ; 2
    mov     eax, [edx]                   
    mov     edx, TEN
    imul    edx                         ; 3
    jo      _error
    add     eax, [ebx]                  ; 4

    ;-------------------------------------------------------------------------
    ; Before copying the final value to numInt and
    ;   exiting the loop (when ecx = 0), it is important to check if 
    ;   the number is actually in SDWORD range.
    ;   This why we stop once ecx is still 1, and we have final numInt in eax.
    ;--------------------------------------------------------------------------
    cmp     ecx, ONE
    je      _rangeCheck
_continueValidationFromRangeCheck:
    mov     ebx, [ebp+44]               
    mov     DWORD PTR [ebx], eax        ; 5
_continueValidationFromNegPosSign:
    dec     ecx
    cmp     ecx, ZERO
    ja      _noSymbolsValidationLoop
    
    ;-----------------------------------------------------------------------
    ; After exiting the validation loop:
    ;   Circles back to negate boolean set inside _negate label.
    ;   If set (negate = 1), then must perform negation of numInt.
    ;   Else, procedure is finished.
    ;-----------------------------------------------------------------------
    mov     ebx, [ebp+52]
    cmp     DWORD PTR [ebx], ONE
    je      _performNegate
    jmp     _finish

;----------------------------------------------------------------------
; Error message
;   Displays error message, and clears the slate of both numInt and 
;       negate, in order to get new attempt at valid user input.
;----------------------------------------------------------------------
_error:
    mdisplayString      [ebp+56]

    ; clear numInt
    mov     edx, [ebp+44]                       
    mov     ebx, ZERO
    mov     DWORD PTR [edx], ebx
    
    ; clear negate
    mov     edx, [ebp+52]                       
    mov     ebx, ZERO
    mov     DWORD PTR [edx], ebx

    jmp     _tryAgain

;----------------------------------------------------------------------
; If the value held in AL equals a dash (45d or 2dh), then must update
;   the negation variable boolean. 
;----------------------------------------------------------------------
_negate:
    mov     ebx, [ebp+52]
    mov     DWORD PTR [ebx], ONE
    jmp     _continueValidationFromNegPosSign

;----------------------------------------------------------------------
; After loop has run and numInt is valid but needs negation,
;   this section actually performs the negation required for numInt.
;----------------------------------------------------------------------
_performNegate:
    mov     ebx, [ebp+44]
    mov     edx, [ebx]
    neg     edx
    mov     SDWORD PTR [ebx], edx
    jmp     _finish

;------------------------------------------------------------------------
; Range Check
;   Checking that final eax value generated from algorithm is within SDWORD 
;   range. Perform this check while still in algorithm loop (ecx = 1), but
;   at end of computation algorithm, before storing in numInt. 
;   Before checking range, must first check negate variable boolean 
;   to see which check to perform (either for a positive or negative number)
;       If true, jump to _checkRangeNegative.
;       If false, jump to _checkRangePositive.
;   Once complete either jump to error or jump to finish out the
;       validation loop.
;------------------------------------------------------------------------
_RangeCheck:
    mov     ebx, [ebp+52]                   
    mov     ebx, [ebx]
    cmp     ebx, ONE
    je      _checkRangeNegative
    jmp     _checkRangePositive

_checkRangeNegative:
    cmp     eax, LO_INT_SDWORD
    ja      _error
    jmp     _continueValidationFromRangeCheck

_checkRangePositive:
    cmp     eax, HI_INT_SDWORD
    ja      _error
    jmp     _continueValidationFromRangeCheck

_finish:
    ; clear negate
    mov     edx, [ebp+52]                       
    mov     ebx, ZERO
    mov     DWORD PTR [edx], ebx

    pop     ebp
    RET     36
ReadVal EndP

;--------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure converts an SDWORD integer to its string ASCII representation.
;   It will then print the numeric ASCII string
;
; Preconditions: 
;               Uses mDisplayString to print the ASCII string.
;
; Postconditions: None
;
; Receives:
;           [ebp+12]   =   reference output parameter, ASCII string
;           [ebp+8]    =   value input parameter, the SDWORD value to be converted
;
; Returns: None
;---------------------------------------------------------------------------------
WriteVal PROC
    push    ebp
    mov     ebp, esp


    ; Use AL and STOSB to clear newString [ebp+12]
    
_finish:
    pop     ebp
    RET     8
WriteVal EndP

;---------------------------------------------------------------------------------
; Name: CalculateSum
;
; This procedure calculates the sum of an integer array.
;
; Preconditions: The array must be of TYPE SDWORD
;
; Postconditions: None
;
; Receives:
;           [ebp+36]    =   value input parameter, lengthIntArray
;           [ebp+32]    =   value input parameter, typeIntArray
;           [ebp+28]    =   reference output parameter, sum
;           [ebp+24]    =   reference input parameter, intArray
;
; Returns:
;           [ebp+28]    =   reference output parameter, sum
;-----------------------------------------------------------------------------------
CalculateSum PROC USES ecx esi ebx edx
    push    ebp
    mov     ebp, esp

    ;--------------------------------------------------------------
    ; This loop calculates the sum of an SDWORD array.
    ;--------------------------------------------------------------
    ; set up for _summation
    mov     ecx, [ebp+36]
    mov     esi, [ebp+24]
    mov     ebx, ZERO

_summation:
    add     ebx, [esi]

    ; increment esi
    add     esi, [ebp+32]
    LOOP    _summation

    mov     edx, [ebp+28]
    mov     SDWORD PTR [edx], ebx

    pop     ebp
    RET     16
CalculateSum EndP

;---------------------------------------------------------------------------------
; Name: CalculateAverage
;
; This procedure calculates the average of an integer array.
;
; Preconditions: The array must be of TYPE SDWORD.
;
; Postconditions: None
;
; Receives:
;           [ebp+28]    =   value input parameter, lengthIntArray
;           [ebp+24]    =   value input parameter, sum
;           [ebp+20]    =   reference output parameter, average
;
; Returns:
;           [ebp+20]    =   reference output parameter, average
;-----------------------------------------------------------------------------------
CalculateAverage PROC USES eax edx ebx
    push    ebp
    mov     ebp, esp

    ; divide sum by length of array
    mov     eax, [ebp+24]
    mov     ebx, [ebp+28]
    cdq
    idiv    ebx

    ; store result in average
    mov     ebx, [ebp+20]
    mov     SDWORD  PTR [ebx], eax

    pop     ebp
    RET     12
CalculateAverage EndP

;-----------------------------------------------------------------------------
; Name: Goodbye
;
; This procedure terminates program with a goodbye message.
;
; Preconditions: Uses mDisplayString - which cannot accept argument using edx. 
;
; Postconditions: None
;
; Receives:
;           [ebp+12] = reference of string input parameter - program's goodbye
;
; Returns: None
;------------------------------------------------------------------------------
Goodbye PROC USES edx
    push    ebp
    mov     ebp, esp

    mDisplayString      [ebp+12]

    pop     ebp
    RET
Goodbye EndP

END main