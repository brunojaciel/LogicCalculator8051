#include <SI_EFM8BB3_Defs.inc>


PUBLIC UPDATE_DISP,ENCODE_FSM
	
PUBLIC INDEX,STATE,NEXT_STATE

EXTRN DATA (OP1,OP2,OPX,RESULT,OP1_DEFAULT)

EXTRN CODE (ENCODE_OPERATIONS)

S_READY EQU 00H
S_OP1 EQU 01H
S_OPX EQU 02H
S_OP2 EQU 03H
S_EXECUTE EQU 04H

CHAR_1 EQU 0F9H
CHAR_2 EQU 0A4H
CHAR_R EQU 0AFH
CHAR_A EQU 088H
CHAR_O EQU 0C0H
CHAR_n EQU 10101011B
CHAR_X EQU 11001001B
CHAR_P EQU 10001100B
CHAR_M EQU 10001001B  
CHAR_L EQU 11000111B

STATE_LEN EQU 8
OPLEN EQU 8
DISP EQU P1		
	
INDEX DATA 30H
STATE DATA 31H
NEXT_STATE DATA 32H 
INIT_OPX bit 0
	
CSEG AT 1000H
	
	
ENCODE_FSM:
	MOV DPTR, #TABLE ;Aponta para esse endereço de dados -> Table
	MOV A, STATE ;Armazena no acumulador o estado atual
	ANL A, #(STATE_LEN-1) ;Mascara para previnir o controle da maquina de estados
	RL A ;Rotate Left
	JMP @A+DPTR ;Pula para esse endereço de dados que está apontado

	
TABLE:
	AJMP CODE_READY
	AJMP CODE_OP1
	AJMP CODE_OPX
	AJMP CODE_OP2
	AJMP CODE_EXECUTE
	AJMP CODE_OTHERS
	AJMP CODE_OTHERS
	AJMP CODE_OTHERS	
	
	
CODE_READY:
	MOV DISP, #CHAR_R ; Exibe a letra r no Display
	MOV NEXT_STATE, #S_OP1 ; Define o proximo estado
	SETB INIT_OPX
	MOV R0, #OP1_DEFAULT
	MOV A, INDEX
	ANL A, #1 ; AND immediate data to Accumulator
	PUSH ACC ; Joga para pilha
	ADD A, NEXT_STATE ; Acumulador incremeta o proximo estado
	MOV NEXT_STATE, A ; Armazena o proximo estado
	POP ACC ; Retira da pilha
	ADD A, R0 ; Salva R0 no acumulador
	MOV R0, A ; Salva valor do acumulador no R0
	RET ; Return to Main Program
	
	
CODE_OP1:
	MOV NEXT_STATE, #S_OPX ; Define o proximo estado
	MOV DISP, #CHAR_1 ; Exibe o número 1 no Display
	RET ; Return to Main Program
	
	
CODE_OPX:
	jnb INIT_OPX,OPX_READY ; Jump se caso o INIT_OPX for 0
	MOV A,P3
	anl A,#0FH ; AND para obter os 4 bits menos significativos
	mov OP1_DEFAULT,A
	mov OP1,@r0
	clr INIT_OPX ; limpar INIT_OPX
OPX_READY:
	MOV R7,INDEX
	CALL UPDATE_DISP
	MOV DISP,R7
	MOV NEXT_STATE, #S_OP2 ; Define o proximo estado
	ANL INDEX, #(OPLEN-1) ; AND para pegar os 3 bit menos significativos do INDEX
	MOV A, #4
	SUBB A, INDEX
	MOV A, NEXT_STATE
	ADDC A, #0
	MOV NEXT_STATE, A
	RET ; Return to Main Program
	
	
CODE_OP2:
	MOV NEXT_STATE, #S_EXECUTE ; Define o proximo estado
	ANL INDEX, #(OPLEN-1)
	MOV S_OPX, INDEX
	MOV DISP, #CHAR_2
	RET ; Return to Main Program
	
	
CODE_EXECUTE:
	mov A,P3
	ANL A,#0FH ; AND para obter os 4 bits menos significativos
	MOV OP2,A
	MOV NEXT_STATE, #S_READY ; Define o proximo estado
	CALL ENCODE_OPERATIONS ; CALL para realizar as operacoes
	MOV P2,RESULT ; Move o resultado para P2
	MOV A,#0FFH
	CPL c ; Complemento Carry
	RRC A ; Rotaciona o Carry para direita
	ANL A,DISP
	MOV DISP,A ; Exibe no Display
	MOV STATE,NEXT_STATE
	JMP ENCODE_FSM
	
		
CODE_OTHERS:
	MOV NEXT_STATE, #S_READY ; Define o proximo estado
	MOV STATE, NEXT_STATE ; Define o estado atual para o proximo
	JMP ENCODE_FSM ; Jump para ENCODE_FSM
	
	
;----------------------------------------------------------------------------	
	UPDATE_DISP:
;----------------------------------------------------------------------------
; USA DPTR PARA APONTAR A BASE DO ARRAY
; USA R7 PARA RECEBER O PARAMETRO INDICE
; USA R7 PARA DEVOLVER CARACTER CORRESPONDENTE
;----------------------------------------------------------------------------
		MOV DPTR, #ARRAY_DIGITS
		MOV A, R7
		ANL A,#(OPLEN-1)
		MOVC A, @A+DPTR
		MOV R7,A
		RET
		ARRAY_DIGITS:
		DB CHAR_A,CHAR_O,CHAR_X,CHAR_P,CHAR_M,CHAR_n,CHAR_R,CHAR_L
;----------------------------------------------------------------------------
END