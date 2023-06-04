;==============================================================================
; GRUPO 39
;------------------------------------------------------------------------------
; Inês Paredes (ist1107028)
; Margarida Lourenço (ist1107137)
; Patrícia Gameiro (ist1107245)
;
;==============================================================================
; CONSTANTES
;------------------------------------------------------------------------------
DISPLAYS      EQU 0A000H   ; endereço dos displays (periférico POUT-1)

; Teclado
TEC_LIN       EQU 0C000H   ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL       EQU 0E000H   ; endereço das colunas do teclado (periférico PIN)
TEC_LINHA     EQU 01111H   ; primeira linha do teclado
MASCARA       EQU 0FH      ; para isolar os 4 bits de menor peso
 
; MediaCenter
COMANDOS         EQU 6000H	        ; endereço de base dos comandos
DEFINE_LINHA     EQU COMANDOS + 0AH ; comando para definir a linha
DEFINE_COLUNA    EQU COMANDOS + 0CH ; comando para definir a coluna
DEFINE_ECRA      EQU COMANDOS + 04H ; comando para definir o ecrã
DEFINE_PIXEL     EQU COMANDOS + 12H ; comando para escrever um pixel
APAGA_AVISO      EQU COMANDOS + 40H ; comando para apagar o aviso 
APAGA_ECRÃ	     EQU COMANDOS + 02H ; comando para apagar ecrã
SELECIONA_FUNDO  EQU COMANDOS + 42H	; comando para selecionar um fundo
TOCA_SOM	     EQU COMANDOS + 5AH ; comando para tocar um som

; Ecrã
ECRA_ALTURA       EQU  32        ; número de linhas do ecrã 
ECRA_LARGURA      EQU  64        ; número de colunas do ecrã 

; Asteróide 
N_ASTEROIDES      EQU  4		 ; número máximo de asteróides
ASTEROIDE_LARGURA EQU  5		 ; largura do asteroide
ASTEROIDE_LIMITE  EQU  22		 ; linha da colisão com nave

; Painel de instrumentos
PAINEL_LINHA     EQU  27         ; primeira linha do painel de instrumentos
PAINEL_COLUNA	 EQU  25         ; primeira coluna do painel de instrumentos
PAINEL_LARGURA	 EQU  15	     ; largura do painel de instrumentos
PAINEL_ALTURA	 EQU  5		     ; altura do painel de instrumentos

; Comandos
TECLA_0          EQU 	00H      ; tecla 0, move sonda para a esquerda
TECLA_1          EQU 	01H      ; tecla 1, move sonda para a frente
TECLA_2          EQU 	02H      ; tecla 2, move sonda para a direita
TECLA_C			 EQU 	0CH		 ; tecla C, inicia o jogo
TECLA_D			 EQU 	0DH      ; tecla D, pausa o jogo
TECLA_E			 EQU 	0EH		 ; tecla E, termina o jogo

; Cores		
LILAS	            EQU  0FA7EH        
PURPURA		        EQU  0F717H  
ROSA                EQU  0FFBCH      
TURQUESA            EQU  0F0DDH

TAMANHO_PILHA		EQU  100H     

;==============================================================================
; PILHA
;------------------------------------------------------------------------------
PLACE 1000H

    STACK TAMANHO_PILHA
SP_beyond_mars:

    STACK TAMANHO_PILHA
SP_teclado:

    STACK TAMANHO_PILHA
SP_nave:

    STACK TAMANHO_PILHA
SP_sonda:

    STACK N_ASTEROIDES * TAMANHO_PILHA
SP_asteroide:

pilha:
	STACK 100H			         ; espaço reservado para a pilha 
						
SP_inicial:	


;==============================================================================
; VARIÁVEIS
;------------------------------------------------------------------------------
ENERGIA:      WORD 100

; Asteróides
TAB_ASTEROIDE:  ; tabela que define os 4 asteróides
                ; tipo de asteróide, tipo de movimento, direção, linha, coluna
    WORD 0, 0, 0, 0, 0          ; asteróide 1
    WORD 0, 0, 0, 0, 0          ; asteróide 2
    WORD 0, 0, 0, 0, 0          ; asteróide 3
    WORD 0, 0, 0, 0, 0          ; asteróide 4

DEF_ASTEROIDE:	                ; tabela que define o asteróide
	WORD		ASTEROIDE_LARGURA                 
	WORD		LILAS, 0, LILAS, 0, LILAS
    WORD        0, LILAS, LILAS, LILAS, 0
    WORD        LILAS, LILAS, 0 , LILAS, LILAS
    WORD        0, LILAS, LILAS, LILAS, 0
    WORD        LILAS, 0, LILAS, 0, LILAS

TIPO_ASTEROIDE:
    WORD 0            ; asteróide comum
    WORD 1            ; asteróide minerável

COLUNA_INICIAL_ASTEROIDE:
    WORD 0            ; asteróide à esquerda
    WORD 30           ; asteróide ao centro
    WORD 59           ; asteróide à direita
   
DIRECAO_ASTEROIDE: 
    WORD -1           ; diagonal esquerda
    WORD 0            ; linha reta
    WORD 1            ; diagonal direita

; Sonda
EXISTE_SONDA: WORD 0             ; zero indica que sonda não foi lançada
SONDA_LINHA:  WORD 26                    
SONDA_COLUNA: WORD 32

; Painel de instrumentos
DEF_PAINEL:	                     ; tabela que define o painel de instrumentos
	WORD		PAINEL_LARGURA
    WORD        PAINEL_ALTURA
    WORD        0, 0, TURQUESA, TURQUESA, TURQUESA, TURQUESA, TURQUESA,         
            TURQUESA, TURQUESA, TURQUESA, TURQUESA, TURQUESA, TURQUESA, 0, 0
	WORD		0, TURQUESA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, 
            PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, TURQUESA, 0
    WORD		TURQUESA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, 
            PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, TURQUESA
    WORD		TURQUESA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, 
            PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, TURQUESA
    WORD		TURQUESA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, 
            PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, PURPURA, TURQUESA

; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0	
    WORD rot_int_1					

tecla_carregada:
	LOCK 0	            ; LOCK para o teclado comunicar aos restantes processos 
                        ; que tecla detetou

evento_int_asteroides:			
	LOCK 0

evento_int_sonda:			
	LOCK 0
 		
;==============================================================================
PLACE 0

;==============================================================================
; BEYOND_MARS - Inicializa jogo.
;------------------------------------------------------------------------------
beyond_mars:
    MOV  SP, SP_inicial          ; inicializa Stack pointer
    MOV  BTE, tab	             ; inicializa BTE
    MOV  [APAGA_AVISO], R1	
    MOV  [APAGA_ECRÃ], R1	
	MOV	 R1, 0			         ; cenário de fundo número 0
    MOV  [SELECIONA_FUNDO], R1	 
    EI0					         ; permite interrupção 0
    EI1                          ; permite interrupção 1
	EI					         ; permite interrupções (geral)	
    CALL teclado
    CALL nave
    CALL sonda
    MOV  R11, N_ASTEROIDES

loop_asteroides:
    SUB  R11, 1
	CALL asteroide
    CMP  R11, 0
    JNZ  loop_asteroides

;==============================================================================
; COMANDOS - Aciona comando que corresponde à tecla premida. 
; Argumentos:    R8 - tecla premida
;-----------------------------------------------------------------------------
comandos:
    MOV	 R8, [tecla_carregada]	 ; bloqueia neste LOCK até uma tecla ser 
                                 ; carregada
                                 ; verifica se é a tecla premida
    CMP  R8, TECLA_1             ; que corresponde ao comando  que lança sonda
    JZ   lança_sonda
    JMP  comandos

lança_sonda: 
    PUSH R1
    MOV  R1, [EXISTE_SONDA]
    CMP  R1, 0                       ; verifica se sonda existe
    JZ   desenha_sonda               ; se não existir, desenha sonda
    POP  R1

;==============================================================================
; DESENHA_SONDA - Desenha sonda no ecrã.
;------------------------------------------------------------------------------
desenha_sonda:
    MOV  R1, 1
    MOV  [EXISTE_SONDA], R1         ; sonda existe
    MOV  R1, [SONDA_LINHA]			; linha da sonda
	MOV  R2, [SONDA_COLUNA]			; coluna da sonda
    MOV  R3, ROSA                   ; endereço da cor da sonda
    CALL escreve_pixel
 
;==============================================================================
; Processo
; TECLADO
;------------------------------------------------------------------------------
PROCESS SP_teclado     

teclado:
    MOV  R2, TEC_LIN    ; endereço do periférico das linhas
    MOV  R3, TEC_COL    ; endereço do periférico das colunas
    MOV  R5, MASCARA    ; isola os 4 bits de menor peso
    MOV  R1, TEC_LINHA  ; testa a linha 1 

;==============================================================================
; ESPERA_TECLA - Espera até uma tecla ser premida.
;------------------------------------------------------------------------------
espera_tecla: 
    YIELD         
    MOVB [R2], R1               ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]               ; ler do periférico de entrada (colunas)
    AND  R0, R5                 ; elimina bits para além dos bits 0-3
    CMP  R0, 0                  ; verifica se alguma tecla foi premida   
    JZ   proxima_linha  
						
;==============================================================================
; HA_TECLA -  Espera até nenhuma tecla estar premida.
;------------------------------------------------------------------------------
ha_tecla: 
    YIELD          
    PUSH R0
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; verifica se alguma tecla da linha foi premida
    POP  R0         
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    MOV  R7, R0        ; guarda coluna
    MOV  R8, -1        ; inicializa contador
    CALL converte
    MOV  R0, R8        ; guarda resultado da conversão da coluna  
    MOV  R8, -1        ; inicializa contador
    MOV  R7, R1        ; guarda linha
    CALL converte
    SHL  R8, 2         ; multiplica linha por 4
    ADD  R8, R0        ; soma linha e coluna
    AND  R8, R5        ; elimina bits para além dos bits 0-3
    MOV	[tecla_carregada], R8	; informa quem estiver bloqueado neste LOCK que
                                ; uma tecla foi carregada
    JMP  espera_tecla  
 

;==============================================================================
; PROXIMA_LINHA - Avança para a próxima linha do teclado.
;------------------------------------------------------------------------------
proxima_linha:
    ROL  R1, 1         
    JMP  espera_tecla

;==============================================================================
; CONVERTE - Conta o número de deslocamentos à direita de 1 bit que se tem de   
;            fazer ao valor da linha (ou da coluna) até este ser zero. 
; Argumentos:   R7 - linha ou coluna
;               R8 - contador
;------------------------------------------------------------------------------
converte:
    ADD  R8, 1
    SHR  R7, 1
    JNZ  converte
    RET    

;==============================================================================
; Processo
; NAVE
;------------------------------------------------------------------------------
PROCESS SP_nave       

nave:
    MOV R1, PAINEL_LINHA
    MOV R2, PAINEL_COLUNA
    MOV R4, DEF_PAINEL
    MOV R5, [R4]                     ; largura do painel de instrumentos   
    ADD R4, 2
    MOV R6, [R4]                     ; altura do painel de instrumentos
    CALL desenha_objeto

;==============================================================================
; Processo
; SONDA
;------------------------------------------------------------------------------
PROCESS SP_sonda       

sonda:
    MOV  R1, [EXISTE_SONDA]

ciclo_sonda:
    MOV  R9, evento_int_sonda        
    MOV  R0, [R9]                    ; lê o LOCK 
    CMP  R1, 0                       ; verifica se sonda existe
    JZ   comandos                    ; se existir continua a executar comandos 
    CALL move_sonda
    JMP  ciclo_sonda

;==============================================================================
; MOVE_SONDA - Movimenta sonda no sentido ascendente. 
;------------------------------------------------------------------------------
move_sonda:
    MOV  R1, [SONDA_LINHA]			; linha da sonda
	MOV  R2, [SONDA_COLUNA]         ; coluna da sonda
    MOV  R3, 0                      ; transparente
    CALL escreve_pixel
    CMP  R1, 0                      ; verifica se sonda está na posição limite
    JZ   reset_sonda
    SUB  R1, 1                      ; sobe uma linha 
    MOV  [SONDA_LINHA], R1			; atualiza a linha da sonda
    MOV  R3, ROSA                   ; endereço da cor da sonda
    CALL escreve_pixel
    RET

;==============================================================================
; RESET_SONDA - Atualiza posição de referência da sonda.
;------------------------------------------------------------------------------
reset_sonda:
    MOV  R1, 26                   ; linha inicial da sonda
    MOV  R2, 32                   ; coluna inicial da sonda
    MOV  [SONDA_LINHA], R1
    MOV  [SONDA_COLUNA], R2
    MOV  R1, 0
    MOV  [EXISTE_SONDA], R1       ; sonda não existe

;==============================================================================
; Processo
; ASTEROIDE
;------------------------------------------------------------------------------
PROCESS SP_asteroide        

asteroide:
    MOV  R1, TAMANHO_PILHA    
    MUL	 R1, R11            ; TAMANHO_PILHA vezes o nº da instância do asteroide
    SUB	 SP, R1             ; inicializa SP deste asteróide
    MOV  R10, R11			; cópia do nº de instância do processo
    MOV  R2,  10
    MOV  R8,  2
    MUL  R10, R2            ; avança para a tabela do asteróide correspondente
    MOV  R2, TAB_ASTEROIDE  ; endereço da tabela que define os asteroides
    ADD  R2, R10            ; endereço do tipo de asteróide correspondente
    MOV  R3, [R2]           ; copia tipo de asteróide
    MOV  R4, [R2+R8]        ; acede à posição do tipo de mov na tabela 
    ADD  R8, 2              ; atualiza índice da tabela
    MOV  R5, [R2+R8]        ; acede à posição da direção na tabela  
    ADD  R8, 2              ; atualiza índice da tabela     
    MOV  R6, [R2+R8]        ; acede à posição da linha na tabela
    ADD  R8, 2              ; atualiza índice da tabela
    MOV  R7, [R2+R8]        ; acede à posição da coluna na tabela

ciclo_asteroide:
    CALL desenha_asteroide
    MOV  R9, evento_int_asteroides
    MOV  R0, [R9]           ; lê o LOCK desta instância do asteróide
    CALL move_asteroide
    JMP  ciclo_asteroide

;==============================================================================
; MOVE_ASTEROIDE - Desce o asteróide diagonalmente, em direção à nave.
;------------------------------------------------------------------------------ 
 move_asteroide:
    MOV  [DEFINE_ECRA], R11      ; define o ecrã do asteróide
    MOV  R9, ASTEROIDE_LIMITE
    CALL apaga_asteroide 
    MOV  R9, ASTEROIDE_LIMITE
    CMP  R6, R9                  ; verifica se asteróide está na posição limite
    JGE  reset_asteroide         ; atualiza posição de referência do asteróide
    ADD  R6, 1                   ; incrementa a linha
    ADD  R7, 1                   ; incrementa a coluna                          
    MOV  [R2+R8], R7             ; atualiza a coluna de referência do asteróide
    SUB  R8, 2                   ; acede à posição da linha na tabela
    MOV  [R2+R8], R6             ; atualiza a linha de referência do asteróide
    RET

;==============================================================================
; DESENHA_ASTEROIDE - Desenha um asteróide na posição de referência.
;------------------------------------------------------------------------------
desenha_asteroide:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    MOV  [DEFINE_ECRA], R11          ; define o ecrã do asteróide
    MOV  R1, R6               	     ; linha do asteróide
	MOV  R2, R7	                     ; coluna do asteróide
	MOV	 R4, DEF_ASTEROIDE	         ; endereço da tabela que define o asteroide
    MOV	 R5, [R4]	                 ; largura do asteróide
    MOV	 R6, [R4]	                 ; altura = largura do asteróide
    CALL desenha_objeto
    POP  R6
    POP  R5
    POP  R4
    POP  R3
    POP  R2
    POP  R1
	RET

;==============================================================================
; RESET_ASTEROIDE - Atualiza posição de referência do asteróide.
;------------------------------------------------------------------------------
reset_asteroide:
    PUSH R1
    MOV  R1, 0
    MOV  R6, R1                   ; atualiza a linha de referência do asteróide
    SHL  R6, 1                    ; acede à posição da coluna na tabela
    MOV  R7, R6                   ; copia coluna do asteróide
    MOV  R6, R1                   ; atualiza a coluna de referência do asteróide
    CALL desenha_asteroide
    POP  R1

;==============================================================================
; APAGA_ASTEROIDE - Apaga asteróide da posição atual.
;------------------------------------------------------------------------------
apaga_asteroide:	
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    MOV  R1, R6	                    ; linha do asteróide
	MOV  R2, R7	                    ; coluna do asteróide
    MOV  R3, 0                      ; cor transparente
	MOV	 R4, DEF_ASTEROIDE	        ; endereço da tabela que define o asteroide
    MOV	 R5, [R4]	                ; largura do asteróide
    MOV	 R6, [R4]	                ; altura = largura do asteróide
    CALL apaga_objeto
    POP  R6
    POP  R5
    POP  R4
    POP  R3
    POP  R2
    POP  R1               
	RET

;==============================================================================
; DESENHA_OBJETO - Desenha um qualquer objeto.
; Argumentos:   R6 - altura do objeto
;------------------------------------------------------------------------------
desenha_objeto:
    PUSH R2
    PUSH R5
    CMP  R6, 0                      ; verifica se altura é zero
    JNZ  desenha_linha              ; se não for, desenha linha
    POP  R5
    POP  R2
    RET

;==============================================================================
; DESENHA_LINHA - Desenha uma linha de um qualquer objeto.
; Argumentos:   R1 - linha a desenhar
;               R2 - coluna a desenhar
;               R4 - tabela do objeto
;               R5 - largura do objeto
;               R6 - altura do objeto
;------------------------------------------------------------------------------
desenha_linha:
    ADD  R4, 2
    MOV	 R3, [R4]	                 ; obtém a cor do próximo pixel 
	CALL escreve_pixel	        
	ADD  R2, 1                       ; próxima coluna
	SUB  R5, 1		                 ; menos uma coluna para desenhar
	JNZ  desenha_linha               ; continua até percorrer toda a largura
    SUB  R6, 1                       ; menos uma linha para desenhar
    ADD  R1, 1                       ; próxima linha
    POP  R5
    POP  R2
    JMP  desenha_objeto              ; continua até percorrer toda a altura

;==============================================================================
; APAGA_OBJETO - Apaga um qualquer objeto.
; Argumentos:   R6 - altura do objeto
;------------------------------------------------------------------------------
apaga_objeto:
    PUSH R2
    PUSH R5
    CMP  R6, 0                       ; verifica se altura é zero
    JNZ  apaga_linha                 ; se não for, desenha linha
    POP  R5
    POP  R2
    RET

;==============================================================================
; APAGA_LINHA - Aapaga uma linha de um qualquer objeto.
; Argumentos:   R1 - linha a apagar
;               R2 - coluna a apagar
;               R5 - largura do objeto
;               R6 - altura do objeto
;------------------------------------------------------------------------------
apaga_linha:
	CALL escreve_pixel	        
	ADD  R2, 1                       ; próxima coluna
	SUB  R5, 1		                 ; menos uma coluna para desenhar
	JNZ  apaga_linha                 ; continua até percorrer toda a largura
    SUB  R6, 1                       ; menos uma linha para desenhar
    ADD  R1, 1                       ; próxima linha
    POP  R5
    POP  R2
    JMP  apaga_objeto                ; continua até percorrer toda a altura

;==============================================================================
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel 
;------------------------------------------------------------------------------
escreve_pixel:
	MOV  [DEFINE_LINHA], R1          ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2         ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	         ; altera a cor do pixel selecionado
	RET

;==============================================================================
; ROT_INT_0 - Rotina de atendimento da interrupção 0.
;             Escreve no LOCK que o processo asteroide lê. 
;------------------------------------------------------------------------------
rot_int_0:
	PUSH R1
	MOV  R1, evento_int_asteroides
	MOV	 [R1], R0	                 ; desbloqueia processo asteroide
    POP  R1
	RFE 

;==============================================================================
; ROT_INT_1 - Rotina de atendimento da interrupção 1.
;             Escreve no LOCK que o processo sonda lê. 
;------------------------------------------------------------------------------
rot_int_1:
	PUSH R1
	MOV  R1, evento_int_sonda
	MOV	 [R1], R0	                 ; desbloqueia processo sonda
    POP  R1
	RFE 
