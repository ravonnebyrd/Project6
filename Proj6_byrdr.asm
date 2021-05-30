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
    call    CrLf
    pop     edx
ENDM


; constant definitions
LO_INT_SDWORD       =   -2147483648
HI_INT_SDWORD       =   2147483647

LO_ASCII_DEC_NUM    =   48
HI_ASCII_DEC_NUM    =   57

NEG_SIGN            =   45
ZERO                =   0
ONE                 =   1
TEN                 =   10
FORTY_EIGHT         =   48

.data
    ; string array variables
    programTitle                BYTE        "Lower-Level I/O Procedures for Numerical Strings by Ravonne Byrd",0
    programDescription          BYTE        "If you input 10 integers that can each fit in a signed doubleword,",13,10,
                                            "this program will display that list of integers, as well as",13,10,
                                            "report back their sum and rounded average.",13,10,0
    userPrompt                  BYTE        "Please enter your integer: ",0
    secondUserPrompt            BYTE        "Try again: ",0
    errorMessage                BYTE        "Are you sure that was an integer? Maybe it was too large for 32-bits.",13,10,0
    goodbyeMessage              BYTE        "Thank you for your participation, and please enjoy your day.",13,10,0

    ; variables for user input
    userNum                     BYTE        15 DUP(?)           ; user input buffer
    maxCharUserNum              DWORD       SIZEOF usernum      ; max size of userNum
    byteCount                   DWORD       ?                   ; holds count of actual bytes used in userNum

    ; ReadVal procedure variables
    numInt                      SDWORD      0 
    negate                      DWORD       0
    

.code
main PROC

    push    offset programTitle
    push    offset programDescription
    call    Introduction

;    mov     ecx, 10
_inputLoop: 
    
    push    offset errorMessage
    push    offset negate
    push    offset secondUserPrompt
    push    offset numInt
    push    offset userPrompt
    push    offset userNum
    push    MaxCharUserNum
    push    offset byteCount
    call    ReadVal

;    LOOP    _inputLoop

_error:

_continue:

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
    mDisplayString      [ebp+12]

    pop     ebp
    RET     8
Introduction EndP

;----------------------------------------------------------------------------------------------------
; Name: ReadVal
;
; Description:
;
; Preconditions: Uses and restores esi, eax, ecx, edx
;               Uses mGetString, which uses and restores edx, ecx.
;               Uses mDisplayString - which cannot accept argument using edx. 
;
; Postconditions:
;
; Receives:
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
;           [ebp+40]    =   reference output parameter, int to add to array of user inputted values
;-----------------------------------------------------------------------------------------------------
ReadVal PROC USES eax ecx edx esi ebx
    push    ebp
    mov     ebp, esp

_firstTry:
    mGetString      [ebp+40], [ebp+36], [ebp+32], [ebp+28]
    jmp     _validationLoop

_tryAgain:
    mGetString      [ebp+48], [ebp+36], [ebp+32], [ebp+28]

    ; set up for _validationLoop
    mov     esi, [ebp+36]
    mov     ecx, [ebp+28]       ; setting up counter for loop
    
_validationLoop:
    LODSB
    cmp     AL, NEG_SIGN
    je      _negateY
_continueValidation:
    cmp     AL, LO_ASCII_DEC_NUM
    jb      _error
    cmp     AL, HI_ASCII_DEC_NUM
    ja      _error
    sub     AL, FORTY_EIGHT          ; (numChar - 48)
    mov     ebx, ZERO
    add     ebx, AL                  ; store current value of AL in ebx, since need AL to multiply
    mov     edx, [ebp+44]            ; store offset of numInt in edx
    mov     eax, [edx]               ; move value of numInt to eax
    mov     edx, 10
    mul     edx
    add     eax, ebx
    mov     DWORD PTR [ebp+44], eax  ; store new numInt value
    LOOP    _validationLOOP
    
    ; check if value needs to be negated
    mov     ebx, [ebp+52]
    cmp     DWORD PTR [ebx], ONE
    je      _performNegate
    jmp     _finish

_error:
    mdisplayString      [ebp+56]
    jmp     _tryAgain

_negateY:
    mov     ebx, [ebp+52]
    mov     DWORD PTR [ebx], ONE
    jmp     _continueValidation

_performNegate:
    neg     numInt

_finish:
    pop     ebp
    RET     32
ReadVal EndP

;----------------------------------------------------------------------
; Name: WriteVal
;
; Description:
;
; Preconditions: 
;
; Postconditions:
;
; Receives:
;
; Returns:
;----------------------------------------------------------------------
WriteVal PROC
    push    ebp
    mov     ebp, esp

    pop     ebp
    RET
WriteVal EndP

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