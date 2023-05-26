;==============================================================================
; GRUPO 39
;------------------------------------------------------------------------------
; Inês Paredes (ist1107028)
; Margarida Lourenço (ist1107137)
; Patrí­cia Gameiro (ist1107245)
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
COMANDOS      EQU 6000H	         ; endereço de base dos comandos
DEFINE_LINHA  EQU COMANDOS + 0AH ; comando para definir a linha
DEFINE_COLUNA EQU COMANDOS + 0CH ; comando para definir a coluna
DEFINE_ECRA   EQU COMANDOS + 04H ; comando para definir o ecrã
DEFINE_PIXEL  EQU COMANDOS + 12H ; comando para escrever um pixel
APAGA_AVISO   EQU COMANDOS + 40H ; comando para apagar o aviso 
APAGA_ECRÃ	  EQU COMANDOS + 02H ; comando para apagar ecrã
SELECIONA_FUNDO  EQU COMANDOS + 42H	; comando para selecionar um fundo
TOCA_SOM	  EQU COMANDOS + 5AH ; comando para tocar um som

; Ecrã
ECRA_ALTURA   EQU  32            ; número de linhas do ecrã 
ECRA_LARGURA  EQU  64            ; número de colunas do ecrã 

; Asteróide 
ASTEROIDE_LARGURA EQU  5		 ; largura do asteroide
ASTEROIDE_LIMITE  EQU  22		 ; linha da colisão com nave

; Painel de instrumentos
PAINEL_LINHA     EQU  27        ; primeira linha do painel de instrumentos
PAINEL_COLUNA	 EQU  25        ; primeira coluna do painel de instrumentos
PAINEL_LARGURA	 EQU  15	    ; largura do painel de instrumentos
PAINEL_ALTURA	 EQU  5		    ; altura do painel de instrumentos

; Comandos
DECREMENT0   EQU  00H
INCREMENT0   EQU  01H
ASTEROIDE    EQU  0AH
SONDA        EQU  0BH

; Cores		
LILAS	     EQU  0FA7EH        
PURPURA		 EQU  0F717H  
ROSA         EQU  0FFBCH      
TURQUESA     EQU  0F0DDH

;==============================================================================
; PILHA
;------------------------------------------------------------------------------
PLACE 1000H

pilha:
	STACK 100H			         ; espaço reservado para a pilha 
						
SP_inicial:	

;==============================================================================
; VARIÁVEIS
;------------------------------------------------------------------------------
ENERGIA:      WORD 100

; Asteróide (esquerda)
ASTEROIDE_LINHA:    WORD  0          ; linha inicial       
ASTEROIDE_COLUNA:	WORD  0          ; coluna inicial

; Sonda
EXISTE_SONDA: WORD 0                 ; zero indica que sonda não foi lançada
SONDA_LINHA:  WORD 26                    
SONDA_COLUNA: WORD 32

; Asteróide
DEF_ASTEROIDE:	                 ; tabela que define o asteróide
	WORD		ASTEROIDE_LARGURA                 
	WORD		LILAS, 0, LILAS, 0, LILAS
    WORD        0, LILAS, LILAS, LILAS, 0
    WORD        LILAS, LILAS, 0 , LILAS, LILAS
    WORD        0, LILAS, LILAS, LILAS, 0
    WORD        LILAS, 0, LILAS, 0, LILAS

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

;==============================================================================
PLACE 0

;==============================================================================
; BEYOND_MARS - Inicializa jogo.
;------------------------------------------------------------------------------
beyond_mars:
    MOV  SP, SP_inicial          ; inicializa Stack pointer
    MOV  [APAGA_AVISO], R1	
    MOV  [APAGA_ECRÃ], R1	
	MOV	 R1, 0			         ; cenário de fundo número 0
    MOV  [SELECIONA_FUNDO], R1	 
    CALL desenha_painel		
	CALL desenha_asteroide

;==============================================================================
; TECLADO - Lê input e inicializa display.
;------------------------------------------------------------------------------
teclado:
    MOV  R1, [ENERGIA]  ; energia inicial
    MOV  R2, TEC_LIN    ; endereço do periférico das linhas
    MOV  R3, TEC_COL    ; endereço do periférico das colunas
    MOV  R4, DISPLAYS   ; endereço do periférico dos displays
    MOV  R5, MASCARA    ; isola os 4 bits de menor peso
    CALL atualiza_display
    MOV  R1, TEC_LINHA  ; testa a linha 1 

;==============================================================================
; ESPERA_TECLA - Espera até uma tecla ser premida.
;------------------------------------------------------------------------------
espera_tecla:          
    MOVB [R2], R1       ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]       ; ler do periférico de entrada (colunas)
    AND  R0, R5         ; elimina bits para além dos bits 0-3
    CMP  R0, 0          ; verifica se alguma tecla foi premida   
    JZ   proxima_linha  
    
;==============================================================================
; HA_TECLA -  Espera até nenhuma tecla estar premida.
;------------------------------------------------------------------------------
ha_tecla:           
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
    CALL  comandos
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
; ATUALIZA_DISPLAY - Atualiza o display que mostra a energia da nave.
; Argumentos:  R1 - energia
;              R4 - endereço do periférico dos displays
;------------------------------------------------------------------------------
atualiza_display:
    PUSH R2
    PUSH R3
    PUSH R5       
    MOV  R9, 1
    MOV  R10, 10        
    MOV  R2, R1                  ; guarda energia              
    MOV  R3, R1                  ; guarda energia
    MOV  R1, 0                 
    MOV  R5, 16             
    CALL converte_decimal
    MOV  [R4], R1               ; escreve no periférico dos displays
    POP R5
    POP R3
    POP R2
    RET

;==============================================================================
; CONVERTE_DECIMAL - Converte o valor da energia de hexadecimal para decimal.
; Argumentos:  R2 - energia em hexadecimal
;              R3 - energia em hexadecimal
;              R5 - dezasseis 
;              R9 - um
; Saída:       R1 - energia convertida a decimal
;------------------------------------------------------------------------------
converte_decimal:
    DIV  R2, R10                   
    MOD  R3, R10
    MUL  R3, R9                  ; múltiplica último algarismo da energia 
    ADD  R1, R3                  ; soma resultado à energia
    MUL  R9, R5                  ; múltiplica por 16 
    MOV  R3, R2                  ; move quociente    
    CMP  R2, 0                   ; verifica se a conversão está completa
    JNZ  converte_decimal
    RET

;==============================================================================
; COMANDOS - Aciona comando que corresponde à tecla premida. 
; Argumentos:    R8 - tecla premida
;-----------------------------------------------------------------------------
comandos:
    PUSH R0
    PUSH R1
    MOV  R0, INCREMENT0          ; verifica se é a tecla premida é a tecla
    CMP  R8, R0                  ; que corresponde ao comando incrementa
    JZ   incrementa
    MOV  R0, DECREMENT0          ; verifica se é a tecla premida é a tecla
    CMP  R8, R0                  ; que corresponde ao comando decrementa
    JZ   decrementa
    MOV  R0, SONDA               ; verifica se é a tecla premida é a tecla
    CMP  R8, R0                  ; que corresponde ao comando sonda
    JZ   atualiza_sonda
    MOV  R0, ASTEROIDE           ; verifica se é a tecla premida é a tecla
    CMP  R8, R0                  ; que corresponde ao comando move_asteroide
    JZ   move_asteroide
    POP  R1
    POP  R0
    RET

;==============================================================================
; INCREMENTA - Soma um ao valor da energia.
;------------------------------------------------------------------------------
incrementa:
    MOV  R0, 1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [ENERGIA], R1           ; guarda valor atual da energia
    CALL atualiza_display  
    POP  R1
    POP  R0
    RET

;==============================================================================
; DECREMENTA - Subtrai um ao valor da energia.
;-----------------------------------------------------------------------------  
decrementa:
    MOV  R0, -1
    MOV  R1, [ENERGIA]
    ADD  R1, R0
    MOV  [ENERGIA], R1           ; guarda valor atual da energia
    CALL atualiza_display
    POP  R1
    POP  R0
    RET

;==============================================================================
; ATUALIZA_SONDA - Atualiza posição da sonda.
;------------------------------------------------------------------------------ 
atualiza_sonda:
    PUSH R2
	PUSH R3
    MOV  R1, [EXISTE_SONDA]
    CMP  R1, 0                       ; verifica se sonda existe
    JZ   desenha_sonda               ; se não existir, desenha sonda
    CALL move_sonda                  ; se existir, move sonda
    POP  R3
    POP  R2
    POP  R1
    POP  R0
    RET

;==============================================================================
; MOVE_ASTEROIDE - Desce o asteróide diagonalmente, em direção à nave.
;------------------------------------------------------------------------------ 
 move_asteroide:
    PUSH R6
    PUSH R7
    PUSH R8
    MOV  R8, 0
    MOV  [TOCA_SOM], R8          ; toca som associado ao movimento do asteroide
    CALL apaga_asteroide         
    MOV  R6, [ASTEROIDE_LINHA]    
    MOV  R7, ASTEROIDE_LIMITE
    CMP  R6, R7                  ; verifica se asteróide está na posição limite
    JGE  reset_asteroide         ; atualiza posição de referência do asteróide
    MOV  R7, [ASTEROIDE_COLUNA]
    ADD  R6, 1                   ; incrementa a linha
    ADD  R7, 1                   ; incrementa a coluna                          
    MOV  [ASTEROIDE_LINHA], R6   ; atualiza a linha de referência do asteróide
    MOV  [ASTEROIDE_COLUNA], R7  ; atualiza a coluna de referência do asteróide
    CALL desenha_asteroide
    POP  R8
    POP  R7
    POP  R6
    POP  R1
    POP  R0
    RET

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
    POP  R3
    POP  R2
    POP  R1
    POP  R0
    RET

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
    MOV  R1, 26
    MOV  R2, 32
    MOV  [SONDA_LINHA], R1
    MOV  [SONDA_COLUNA], R2
    MOV  R1, 0
    MOV  [EXISTE_SONDA], R1       ; sonda não existe
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
    MOV  R1, 1
    MOV  [DEFINE_ECRA], R1           ; define o ecrã
    MOV  R1, [ASTEROIDE_LINHA]	     ; linha do asteróide
	MOV  R2, [ASTEROIDE_COLUNA]	     ; coluna do asteróide
	MOV	 R4, DEF_ASTEROIDE	         ; endereço da tabela que define o asteroide
    MOV	 R5, [R4]	                 ; largura do asteróide
    MOV	 R6, [R4]	                 ; altura = largura do asteróide
    CALL desenha_objeto
    POP R6
	POP	R5
	POP	R4
	POP	R3
	POP	R2
    POP	R1
	RET

;==============================================================================
; RESET_ASTEROIDE - Atualiza posição de referência do asteróide.
;------------------------------------------------------------------------------
reset_asteroide:
    PUSH R1
    MOV  R1, 0
    MOV  [ASTEROIDE_LINHA], R1
    MOV  [ASTEROIDE_COLUNA], R1
    CALL desenha_asteroide
    POP  R1
    POP  R8
    POP  R7
    POP  R6
    POP  R1
    POP  R0
    RET

;==============================================================================
; APAGA_ASTEROIDE - Apaga asteróide da posiçãoa atual.
;------------------------------------------------------------------------------
apaga_asteroide:
    PUSH	R1
    PUSH	R2
	PUSH	R3
	PUSH	R4
	PUSH	R5
    MOV  R1, [ASTEROIDE_LINHA]	     ; linha do asteróide
	MOV  R2, [ASTEROIDE_COLUNA]	     ; coluna do asteróide
    MOV  R3, 0                       ; cor transparente
	MOV	 R4, DEF_ASTEROIDE	         ; endereço da tabela que define o asteroide
    MOV	 R5, [R4]	                 ; largura do asteróide
    MOV	 R6, [R4]	                 ; altura = largura do asteróide
    CALL apaga_objeto               
	POP	R5
	POP	R4
	POP	R3
	POP	R2
    POP	R1
	RET

;==============================================================================
; DESENHA_PAINEL - Desenha um painel de instrumentos na posição de referência.
;------------------------------------------------------------------------------
desenha_painel:
    MOV R1, PAINEL_LINHA
    MOV R2, PAINEL_COLUNA
    MOV R4, DEF_PAINEL
    MOV R5, [R4]                     ; largura do painel de instrumentos   
    ADD R4, 2
    MOV R6, [R4]                     ; altura do painel de instrumentos
    CALL desenha_objeto
	RET

;==============================================================================
; DESENHA_OBJETO - Desenha um qualquer objeto.
; Argumentos:   R6 - altura do objeto
;------------------------------------------------------------------------------
desenha_objeto:
    PUSH R2
    PUSH R5
    CMP  R6, 0                       ; verifica se altura é zero
    JNZ  desenha_linha               ; se não for, desenha linha
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
	JNZ  apaga_linha               ; continua até percorrer toda a largura
    SUB  R6, 1                       ; menos uma linha para desenhar
    ADD  R1, 1                       ; próxima linha
    POP  R5
    POP  R2
    JMP  apaga_objeto              ; continua até percorrer toda a altura

;==============================================================================
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R1 - linha
;               R2 - coluna
;               R3 - cor do pixel 
;------------------------------------------------------------------------------
escreve_pixel:
	MOV  [DEFINE_LINHA], R1  ; seleciona a linha
	MOV  [DEFINE_COLUNA], R2 ; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	 ; altera a cor do pixel selecionado
	RET