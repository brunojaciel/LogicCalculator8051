#include <SI_EFM8BB3_Defs.inc>


PUBLIC OP1,OP2,OPX,RESULT,ENCODE_OPERATIONS,OP1_DEFAULT

OP1 DATA 36H
OP2 DATA 37H
OPX DATA 38H
OP1_DEFAULT data 39H
RESULT DATA 3AH
	
OPLEN EQU 8
	
CSEG AT 2000H
;----------------------------------------------------------------------------------------------	
	ENCODE_OPERATIONS:
;----------------------------------------------------------------------------------------------
; RECEBE PARAMETROS EM OP1,OP2 E OPX
;DEVOLVE RESULTADO EM RESULT
;----------------------------------------------------------------------------------------------
	MOV DPTR, #TABLE
	MOV A, OPX
	ANL A, #(OPLEN-1)
	RL A
	JMP @A+DPTR

	
TABLE:
	AJMP CODE_AND
	AJMP CODE_OR
	AJMP CODE_XOR
	AJMP CODE_ADD
	AJMP CODE_SUBB
	AJMP CODE_NOT
	AJMP CODE_ROTR
	AJMP CODE_ROTL
	
;-----------------------------------------------------------------------------------------------
;   ===============OPERACOES===============
;-----------------------------------------------------------------------------------------------
	 CODE_AND:
	 MOV A,OP1
	 ANL A,OP2
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_OR:
	 MOV A,OP1
	 ORL A,OP2
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_XOR:
	 MOV A, OP1
     XRL A, OP2
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_ADD:
	 MOV A, OP1
	 ADDC A, OP2
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_SUBB:
	 MOV A, OP1
	 SUBB A, OP2
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_NOT:
	 MOV A, OP1
	 CPL A
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_ROTR:
	 MOV A, OP1
	 RRC A 
	 MOV RESULT, A
	 RET
	 
	 
	 CODE_ROTL:
	 MOV A, OP1
	 RLC A
	 MOV RESULT, A
	 RET
	 	
END