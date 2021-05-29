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
; Preconditions:    Uses and restores edx, ecx.
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
; Preconditions: Do not use EDX as an argument.
;
; Postconditions: EDX (used and restored)
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

; (insert constant definitions here)

.data
    ; string array variables
    programTitle                BYTE        "Lower-Level I/O Procedures for Numerical Strings by Ravonne Byrd",0
    programDescription          BYTE        "If you input 10 integers that can each fit in a signed doubleword,",13,10,
                                            "this program will display that list of integers, as well as",13,10,
                                            "report back their sum and rounded average.",13,10,0
    userPrompt                  BYTE        "Please enter your integer: ",0
    errorMessage                BYTE        "Are you sure that was an integer? Maybe it was too large for 32-bits.",13,10,0
    goodbyeMessage              BYTE        "Thank you for your participation, and please enjoy your day.",13,10,0

    ; user inputted variables
    userNum                     BYTE        15 DUP(?)           ; user input buffer
    maxCharUserNum              DWORD       SIZEOF usernum      ; max size of userNum
    byteCount                   DWORD       ?                   ; holds count of actual bytes used in userNum
    

.code
main PROC

    push    offset programTitle
    push    offset programDescription
    call    Introduction

;    mov     ecx, 10
_inputLoop: 
    
    push    offset userPrompt
    push    offset userNum
    push    MaxCharUserNum
    push    offset byteCount
    call    Practice

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
; Preconditions: Uses  mDisplayString - which cannot accept argument using edx. 
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

;----------------------------------------------------------------------
; Name: ReadVal
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
ReadVal PROC
    push    ebp
    mov     ebp, esp

    pop     ebp
    RET
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

;----------------------------------------------------------------------
; Name: Practice
;
; Description:
;
; Preconditions: 
;
; Postconditions:
;
; Receives:
;           [ebp+32]      = reference input parameter, prompt string array
;           [ebp+28]      = reference output parameter, user entered string 
;           [ebp+24]      = value input parameter, max size of array allowed for input
;           [ebp+20]      = reference output parameter, actual size, in bytes, of input
;
; Returns:
;----------------------------------------------------------------------
Practice PROC USES eax ecx edx
    push    ebp
    mov     ebp, esp

    
    mGetString      [ebp+32], [ebp+28], [ebp+24], [ebp+20]
    mDisplayString  [ebp+28]
    mov     eax, [ebp+20]
    call    WriteInt

    pop     ebp
    RET     16
Practice EndP

END main