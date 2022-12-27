#include <SI_EFM8BB3_Defs.inc>

EXTRN CODE (UPDATE_DISP, ENCODE_FSM)
EXTRN DATA (INDEX,STATE,NEXT_STATE)

S_READY EQU 00H
		
K_SET EQU P0.6
K_LOAD EQU P0.7


CSEG 	AT 	0H
	SJMP 	INIT
	;INTERRUPÇÕES
CSEG 	AT 	50H
;---------------------------------------------------------------------------------
INIT:
;---------------------------------------------------------------------------------
	; desligar Watch Dog Timer ( WDT )
	MOV WDTCN , #0DEH
	MOV WDTCN , #0ADH
	; ligar Portos I / O do microcontrolador
	MOV XBR2 , #40H
	MOV P3,#0FFH; ABRIR SWITCHS ACTIVA PULL-UPS
	MOV P0,#0FFH;
	mov p1,#0ffh
	MOV INDEX,#0
START_LOOP:
	MOV STATE, #S_READY ; Estado Atual recebe o primeiro estado
ENC_LOOP:
	CALL ENCODE_FSM ; call----Jump to Encode_FSM
	
KEY_LOOP:
	JNB K_LOAD, KLOAD_PRESSED;KSET_PRESSED
 	JB K_SET, KEY_LOOP
	
KSET_PRESSED:
	JNB K_SET, $
	INC INDEX
	SJMP ENC_LOOP
	
KLOAD_PRESSED:
	JNB K_LOAD, $
	MOV STATE, NEXT_STATE
	MOV INDEX, #0
	SJMP ENC_LOOP
	
;---------------------------------------------------------------------------------	
END ; End Assembly