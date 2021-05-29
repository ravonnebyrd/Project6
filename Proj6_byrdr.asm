TITLE String Primitives & MACROs     (Proj6_byrdr.asm)

; Author: Ravonne Byrd
; Last Modified: May 28, 2021
; OSU email address: byrdr@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: June 6, 2021
; Description: TODO

INCLUDE Irvine32.inc

; MACROs should list all registers used, even if restored
;----------------------------------------------------------------------
; Name: mGetString
;
; This MACRO processes strings by using Irvine's ReadString 
;   to get user input.
;
; Preconditions:
;
; Postconditions:
;
; Receives:
;
; Returns:
;----------------------------------------------------------------------
mGetString MACRO

ENDM

;----------------------------------------------------------------------
; Name: mDisplayString
;
; This MACRO processes strings by using Irvine's WriteString 
;   to display/print a memory addressed string.
;
; Preconditions: Do not use EDX as an argument.
;
; Postconditions: EDX (used and restored)
;
; Receives:
;           offsetString = reference input parameter, string array address
;
; Returns: None
;----------------------------------------------------------------------
mDisplayString MACRO offsetString:REQ
    push    edx
    mov     edx, offsetString
    call    WriteString
    call    CrLf
    pop     edx
ENDM

; (insert constant definitions here)

.data

    programTitle                BYTE        "Lower-Level I/O Procedures for Numerical Strings by Ravonne Byrd",0
    programDescription          BYTE        "If you input 10 integers that can fit in a signed doubleword,",13,10,
                                            "this program will display that list of integers, as well as",13,10,
                                            "report back their sum and rounded average.",13,10,0
    userPrompt                  BYTE        "Please enter your integer: ",0
    errorMessage                BYTE        "Are you sure that was and integer? Maybe it was too large for 32-bits.",13,10,0
    goodbyeMessage              BYTE        "Thank you for your participation, and please enjoy your day.",13,10,0
    

.code
main PROC
    push    offset programTitle
    push    offset programDescription
    call    Introduction

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
;           [ebp+12] = reference of string input parameter - program's title
;           [ebp+8] = reference of string input parameter - program's description
;
; Returns: None
;-----------------------------------------------------------------------------------
Introduction PROC
    push    ebp
    mov     ebp, esp

    mDisplayString      [ebp+12]
    call                CrLf
    mDisplayString      [ebp+8]

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
;           [ebp+8] = reference of string input parameter - program's goodbye
;
; Returns: None
;------------------------------------------------------------------------------
Goodbye PROC
    push    ebp
    mov     ebp, esp

    mDisplayString      [ebp+8]

    pop     ebp
    RET
Goodbye EndP

END main
