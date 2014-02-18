*****************************************************************************
*
* Title:           LED Light Blinking
* 
* Objective:       CSE472 Homework 2 
*
* Revision         V1.4 
*
* Date:            Jan. 26, 2014
*
* Programmer:      Joshua Kuiros
*
* Company:         The Pennsylvania State University
*                  Department of Computer Science and Engineering
*
* Algorithm:       Simple Parallel I/O in a delay-loop demo
*
* Register use:    A: Light on/off state and switch SW1 on/off state
*                  X,Y: Delay loop counters
*
* Memory use:      RAM Locations from $3000 for data, from $3100 for program
*
* Input:           Paramaters hard coded in the program
*                  Switch SV1 at PORTP bit 0 
*
* Output:          LED 1,2,3,4 at PORTB bit 4,5,6,7 
*
* Observation:     This is a program that blinks LEDS and blinking period can 
*                  be changed with the delay loop counter value. 
*
* Comments:        This program is developed and simulated using CodeWarrior
*                  development software and targeted for Axiom Manufacturing's
*                  APS12C128 board running at 24MHz bus clock 
*
*
*****************************************************************************
* Parameter Declaration Section
*
* Export Symbols
            XDEF        pgstart       ; export 'pgstart' symbol
            ABSENTRY    pgstart       ; for assembly entry point
            
* Symbols and Macros
PORTA       EQU         $0000         ; i/o port addresses
DDRA        EQU         $0002

PORTB       EQU         $0001       
DDRB        EQU         $0003
PUCR        EQU         $000C         ; to enable pull-up node for PORT A, B, E, K

PTP         EQU         $0258         ; PORTP data register
PTIP        EQU         $0259         ; PORTP input register <<====
DDRP        EQU         $025A         ; PORTP data direction register
PERP        EQU         $025C         ; PORTP pull up/down enable
PPSP        EQU         $025D         ; PORTP pull up/down selection

*****************************************************************************
* Data Section
*
            ORG         $3000         ; reserved RAM memory starting address, in RAM
Counter1    DC.W        $4fff         ; X register count number  
Counter2    DC.W        $0020         ; Y register count number
            DS.W        $0020         ; memory space for data stack                                       
StackSP                               ; initial stack pointer position
*
*****************************************************************************
* Program Section
*
            ORG         $3100         ; program start address, in RAM
pgstart     LDS         #StackSP      ; initialize the stack pointer 

            LDAA        #%11110000    ; set PORTB bit 7,6,5,4 as output, 3,2,1,0 as input
            STAA        DDRB          ; LED 1,2,3,4 on PORTB bit 4,5,6,7 
                                      ; DIP switch 1,2,3,4 on PORTB bit 0,1,2,3
            BSET        PUCR,%00000010 ; enable PORTB pull up/down feature for 
                                       ; the DIP switch 1,2,3,4 on the bits 0,1,2,3
            
            BCLR        DDRP,%00000011 ; Push Button Switch 1 and 2 at PORTP bit 0 and 1
                                       ; set PORTP bit 0 and 1 as input
            BSET        PERP,%00000011 ; enable PORTP bit 0 and 1 as input                           
            BCLR        PPSP,%00000011 ; select pull up feature at PORTP bit 0 and 1 for the
                                       ; Push button switch 1 and 2   
                                       
            LDAA        #%11110000     ; Turn off LED 1,2,3,4 at PORTB4 bit 4,5,6,7
            STAA        PORTB
            
mainLoop
            BSET        PORTB,%10000000 ; Turn off LED 4 at PORTB7
            BCLR        PORTB,%00010000 ; Turn on LED 1 at PORTB4
            JSR         delay1sec       ; Wait for 1 second
            BSET        PORTB,%00010000 ; Turn off LED 1 at PORTB4
            BCLR        PORTB,%10000000 ; Turn on LED 4 at PORTB7
            JSR         delay1sec       ; Wait for 1 second
            
            LDAA        PTIP            ; read push buton SW1 at PORTP0
            ANDA        #%00000001      ; check the bit 0 only
            BEQ         sw1notpshed            
sw1pushed   BSET        PORTB,%01000000 ; Turn off LED 3 at PORTB6
            BCLR        PORTB,%00100000 ; Turn on LED 2 at PORTB5
            JSR         delay1sec
            BSET        PORTB,%00100000 ; Turn off LED 2 at PORTB5
            BCLR        PORTB,%01000000 ; Turn on LED 3 at PORTB6
            BRA         mainLoop        ; loop forever!

sw1notpshed BSET        PORTB,%00100000 ; turn ON LED1 at PORTB4 
            BSET        PORTB,%01000000 ; turn ON LED1 at PORTB4
            BRA         mainLoop        ; loop forever!
                     

*****************************************************************************
* Subroutine Section
*

;*****************************************************************
; delay1sec subroutine
;
; Please be sure to include your comments here!
;

delay1sec
             LDY  Counter2          ; long delay by
dly1Loop     JSR  delayMS           ; Y * delayMS
             DEY
             BNE  dly1Loop
             RTS
             
;*****************************************************************
; delayMS subroutine
;
; This subroutine cause few msec. delay
;
; Input:  a 16 bit count number in 'Counter1'
; Output: time delay, cpu cycle waisted
; Registers in use X register as counter
; Memory locations in useL a 16 bit input number in 'Counter1'
;
; Comments: one can add more NOP instructions to lengthen
;           the delay time

delayMS
            LDX   Counter1        ;short delay
dlyMSLoop   NOP                   ;X * NOP
            DEX
            BNE   dlyMSLoop
            RTS  


*
* Add any subroutines here
*       

            end                      ;last line of file



