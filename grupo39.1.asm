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
PIN           EQU 0E000H   ; endereço do periférico PIN

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

; Sonda
N_SONDAS         EQU  3          ; número de sondas

; Painel de instrumentos
PAINEL_LINHA     EQU  24         ; primeira linha do painel de instrumentos
PAINEL_COLUNA	 EQU  25         ; primeira coluna do painel de instrumentos
PAINEL_LARGURA	 EQU  15	     ; largura do painel de instrumentos
PAINEL_ALTURA	 EQU  8 	     ; altura do painel de instrumentos

; Comandos
TECLA_0          EQU 	00H      ; tecla 0, move sonda para a esquerda
TECLA_1          EQU 	01H      ; tecla 1, move sonda para a frente
TECLA_2          EQU 	02H      ; tecla 2, move sonda para a direita
TECLA_C			 EQU 	0CH		 ; tecla C, inicia o jogo
TECLA_D			 EQU 	0DH      ; tecla D, pausa o jogo
TECLA_E			 EQU 	0EH		 ; tecla E, termina o jogo

; Cores		
AMARELO             EQU  0FFA2H
AMEIXA              EQU  0F727H
BEGE                EQU  0FFDCH
ESPUMA              EQU  0F6DDH  
LARANJA             EQU  0FF84H
OCEANO              EQU  0F133H
PURPURA             EQU  0F616H
ROSA                EQU  0FF9FH
ROSA_CLARO          EQU  0FECEH   
ROXO                EQU  0FA6AH 
TURQUESA            EQU  0F299H
VERMELHO            EQU  0FF05H

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
SP_display:

    STACK TAMANHO_PILHA
SP_nave:

    STACK TAMANHO_PILHA
SP_energia:

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
ENERGIA:         WORD 100     ; energia da nave

; Asteróides
TAB_ASTEROIDE:  ; tabela que define os 4 asteróides
                ; tipo de asteróide, direção, linha, coluna
    WORD 0, 0, 0, 0          ; asteróide 1
    WORD 0, 0, 0, 0          ; asteróide 2
    WORD 0, 0, 0, 0          ; asteróide 3
    WORD 0, 0, 0, 0          ; asteróide 4

DEF_ASTEROIDE:	                ; tabela que define o asteróide
	WORD		ASTEROIDE_LARGURA  
    WORD        0, ESPUMA, OCEANO, 0, 0              
	WORD	    0, OCEANO, TURQUESA, OCEANO, 0
    WORD        ESPUMA, TURQUESA, TURQUESA, TURQUESA, OCEANO
    WORD        ESPUMA, TURQUESA, TURQUESA, TURQUESA, OCEANO
    WORD        0, ESPUMA, TURQUESA, OCEANO, 0

DEF_MINERAVEL:	                ; tabela que define o asteróide
	WORD		ASTEROIDE_LARGURA  
    WORD        0, 0, ROSA_CLARO, 0, 0               
	WORD	    0, LARANJA, ROSA, BEGE, 0 
    WORD        ROSA_CLARO, ROSA, PURPURA, ROSA, ROSA_CLARO
    WORD        0, BEGE, ROSA, LARANJA, 0
    WORD        0, 0, ROSA_CLARO, 0, 0

TIPO_ASTEROIDE:
    WORD 0, 0, 0      ; asteróides comuns
    WORD 1            ; asteróide minerável

PAR_COLUNA_DIRECAO:
    WORD 0,  1           ; asteróide à esquerda
    WORD 30, -1          ; asteróide ao centro que se move na diagonal esquerda
    WORD 30, 0           ; asteróide ao centro que se move na vertical
    WORD 30, 1           ; asteróide ao centro que se move na diagonal direita
    WORD 59, -1          ; asteróide à direita

; Sonda
TAB_SONDA:      ; tabela que define a sonda
                ; estado, linha, coluna, direção, limite
    WORD 0, 24, 25, -1, 12       ; sonda 1 (sonda esquerda)
    WORD 0, 23, 32, 0, 11        ; sonda 2 (sonda central)
    WORD 0, 24, 39, 1, 12        ; sonda 3 (sonda direita)

EXISTE_SONDA: WORD 0             ; zero indica que sonda não foi disparada
SONDA_LINHA:  WORD 23                    
SONDA_COLUNA: WORD 32

; Painel de instrumentos
DEF_PAINEL:	                     ; tabela que define o painel de instrumentos
	WORD	PAINEL_LARGURA
    WORD    PAINEL_ALTURA
    WORD    0, 0, 0, 0, 0, 0, 0, ESPUMA, 0, 0, 0, 0, 0, 0, 0
    WORD    0, AMEIXA, 0, 0, 0, 0, ESPUMA, TURQUESA, TURQUESA, 0, 0, 0, 0, AMEIXA, 0 
    WORD    0, ROXO, ROXO, 0, 0, ROXO, ROXO, ROXO, PURPURA, PURPURA, 0, 0, ROXO, PURPURA, 0  
    WORD    ROXO, ROXO, ROXO, 0, PURPURA, ROXO, ROXO, ROXO, ROXO, PURPURA, PURPURA, 0, ROXO, PURPURA, PURPURA
    WORD    ROXO, ROXO, PURPURA, AMEIXA, ROXO, ROXO, ROXO, ROXO, ROXO, PURPURA, PURPURA, AMEIXA, ROXO, ROXO, PURPURA
    WORD    0, PURPURA, PURPURA, 0, PURPURA, ROXO, ROXO, ROXO, ROXO, PURPURA, PURPURA, 0, ROXO, PURPURA, 0
    WORD    0, LARANJA, AMARELO, 0, 0, ROXO, ROXO, ROXO, PURPURA, PURPURA, 0, 0, AMARELO, LARANJA, 0
    WORD    0, 0, VERMELHO, 0, 0, 0, ROXO, PURPURA, PURPURA, 0, 0, 0, VERMELHO, 0, 0

; Tabela das rotinas de interrupção
tab:
	WORD rot_int_0	
    WORD rot_int_1				
    WORD rot_int_2	

tecla_carregada:
	LOCK 0	            ; LOCK para o teclado comunicar aos restantes processos 
                        ; que tecla detetou

lock_display: 
    LOCK 0              ; LOCK para o display comunicar aos restantes processos 
                        ; que está a ser atualizado

evento_int_asteroides:			
	LOCK 0

evento_int_sonda:			
	LOCK 0
 		
evento_int_energia:
    LOCK 0
;==============================================================================
PLACE 0

;==============================================================================
; BEYOND_MARS - Inicializa jogo.
;------------------------------------------------------------------------------
inicio:
    MOV  [APAGA_AVISO], R1             
    MOV  [APAGA_ECRÃ], R1	        
    MOV  R1, 1                   
    MOV  [SELECIONA_FUNDO], R1
    CALL teclado

inicio_ciclo:
    MOV  R8, [tecla_carregada]   ; bloqueia neste LOCK até uma tecla ser 
                                 ; carregada
    MOV  R9, TECLA_C             ; verifica se a tecla premida corresponde
    CMP  R8, R9                  ; ao comando  que inicia o jogo
    JZ   beyond_mars
    JMP  inicio_ciclo

beyond_mars:
    MOV  SP, SP_inicial          ; inicializa Stack pointer
    MOV  BTE, tab	             ; inicializa BTE	
	MOV	 R1, 0			         ; cenário de fundo número 0
    MOV  [SELECIONA_FUNDO], R1	 
    EI0					         ; permite interrupção 0
    EI1                          ; permite interrupção 1
    EI2                          ; permite interrupção 2
	EI					         ; permite interrupções (geral)	
    CALL teclado
    CALL nave
    CALL display
    CALL energia
    MOV  R10, N_SONDAS           ; inicializa número de sondas
    MOV  R11, N_ASTEROIDES       ; inicializa número de asteroides

loop_sonda:
    SUB  R10, 1
    CALL sonda
    CMP  R10, 0
    JNZ  loop_sonda

loop_asteroides:
    SUB  R11, 1
	CALL asteroide
    CMP  R11, 0
    JNZ  loop_asteroides

;==============================================================================
; COMANDOS - Aciona comando que corresponde à tecla premida. 
;-----------------------------------------------------------------------------
comandos:
    MOV	 R8, [tecla_carregada]	 ; bloqueia neste LOCK até uma tecla ser 
                                 ; carregada
                                 ; verifica se a tecla premida corresponde
    CMP  R8, TECLA_0             ; ao comando  que dispara sonda da esquerda
    JZ   dispara_sonda
                                 ; verifica se a tecla premida corresponde
    CMP  R8, TECLA_1             ; ao comando  que dispara sonda do meio
    JZ   dispara_sonda
                                 ; verifica se a tecla premida corresponde
    CMP  R8, TECLA_2             ; ao comando  que dispara sonda da direita
    JZ   dispara_sonda
    ;CMP  R8, TECLA_D            ; verifica se a tecla premida corresponde
    ;JZ beyond_mars              ; ao comando  que coloca o jogo em pausa
    MOV  R9, TECLA_E
    CMP  R8, R9                  ; verifica se a tecla premida corresponde
    ;JZ fim_jogo                 ; ao comando  que termina o jogo
    JMP  comandos

dispara_sonda: 
    MOV  R2, TAB_SONDA           ; endereço da tabela das sondas
    MOV  R3, 10
    MUL  R8, R3                  ; multiplica por 8 para obter o índice da sonda
    ADD  R2, R8                  ; atualiza endereço da sonda
    MOV  R1, [R2]                
    CMP  R1, 0                   ; verifica se sonda existe
    JZ   desenha_sonda           ; se não existir, desenha sonda
    JMP  comandos

;==============================================================================
; DESENHA_SONDA - Desenha sonda no ecrã.
;------------------------------------------------------------------------------
desenha_sonda:    
    MOV  R1, 1                      ; atualiza estado da sonda 
    MOV  [R2], R1                   ; sonda existe
    MOV  R1, [R2+2]                 ; linha da sonda
    MOV  R2, [R2+4]                 ; coluna da sonda
    MOV  R3, ROSA                   ; endereço da cor da sonda
    CALL escreve_pixel
    MOV  R1, [ENERGIA]
    SUB  R1, 5                      ; decrementa energia em 5
    MOV  [ENERGIA], R1              ; guarda energia
    MOV  [lock_display], R1         ; desbloqueia LOCK do display
    JMP  comandos
     
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


; ESPERA_TECLA - Espera até uma tecla ser premida.
espera_tecla: 
    YIELD         
    MOVB [R2], R1               ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]               ; ler do periférico de entrada (colunas)
    AND  R0, R5                 ; elimina bits para além dos bits 0-3
    CMP  R0, 0                  ; verifica se alguma tecla foi premida   
    JZ   proxima_linha  
						

; HA_TECLA -  Espera até nenhuma tecla estar premida.
ha_tecla: 
    YIELD      
    PUSH R0
    MOVB [R2], R1               ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]               ; ler do periférico de entrada (colunas)
    AND  R0, R5                 ; elimina bits para além dos bits 0-3
    CMP  R0, 0                  ; verifica se alguma tecla da linha foi premida
    POP  R0         
    JNZ  ha_tecla               ; se ainda houver uma tecla premida, 
                                ; espera até não haver
    MOV  R7, R0                 ; guarda coluna
    MOV  R8, -1                 ; inicializa contador
    CALL converte
    MOV  R0, R8                 ; guarda resultado da conversão da coluna  
    MOV  R8, -1                 ; inicializa contador
    MOV  R7, R1                 ; guarda linha
    CALL converte
    SHL  R8, 2                  ; multiplica linha por 4
    ADD  R8, R0                 ; soma linha e coluna
    AND  R8, R5                 ; elimina bits para além dos bits 0-3
    MOV	[tecla_carregada], R8	; informa quem estiver bloqueado neste LOCK que
                                ; uma tecla foi carregada
    JMP  espera_tecla  
 


; PROXIMA_LINHA - Avança para a próxima linha do teclado.
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
    
; Processo
; NAVE
PROCESS SP_nave       

nave:
    MOV R1, PAINEL_LINHA
    MOV R2, PAINEL_COLUNA
    MOV R4, DEF_PAINEL
    MOV R5, [R4]                     ; largura do painel de instrumentos   
    ADD R4, 2
    MOV R6, [R4]                     ; altura do painel de instrumentos
    CALL desenha_objeto

; Process
; DISPLAY - Atualiza o display que mostra a energia da nave.

PROCESS SP_display      

display:        
    MOV  R1, [lock_display]      ; bloqueia neste LOCK
    MOV  R1, [ENERGIA]
    MOV  R2, R1                  ; guarda energia
    MOV  R3, R1                  ; guarda energia
    MOV  R1, 0
    MOV  R5, 16   
    MOV  R9, 1
    MOV  R10, 10          
    CALL converte_decimal
    MOV  [DISPLAYS], R1           ; escreve no periférico dos displays
    JMP display

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

; Processo
; ENERGIA

PROCESS SP_energia       

energia:
    MOV  [lock_display], R1       ; desbloqueia display para energia inicial

ciclo_energia:
    MOV  R1, [evento_int_energia] ; lê o LOCK 
    MOV  R1, [ENERGIA]
    SUB  R1, 3                    ; decrementa energia em 3
    MOV  [ENERGIA], R1            ; guarda energia
    MOV  [lock_display], R1       ; desbloqueia display
    JMP  ciclo_energia

; Processo
; SONDA

PROCESS SP_sonda       

sonda:
    MOV  R1, TAMANHO_PILHA
    MUL  R1, R10            ; TAMANHO_PILHA vezes o nº da instância da sonda
    SUB	 SP, R1             ; inicializa SP deste asteróide
    MOV  R11, R10			; cópia do nº de instância do processo
    MOV  R8, 10              
    MUL  R11, R8            ; avança para a tabela da sonda correspondente
    MOV  R8, TAB_SONDA      ; endereço da tabela que define as sondas
    ADD  R8, R11            ; endereço do estado da sonda

ciclo_sonda:        
    MOV  R0, [evento_int_sonda]      ; lê o LOCK 
    MOV  R3, [R8]                    ; copia estado da sonda
    CMP  R3, 0                       ; verifica se sonda existe
    JNZ  move_sonda                  ; se existir, move sonda
    JMP  ciclo_sonda


; MOVE_SONDA - Movimenta sonda no sentido ascendente. 

move_sonda:
    MOV  R9, 2                      ; inicializa índice da tabela
    MOV  R1, [R8+R9]                ; acede à linha da sonda
    ADD  R9, 2                      ; atualiza índice da tabela
    MOV  R2, [R8+R9]                ; acede à coluna da sonda
    ADD  R9, 2                      ; atualiza índice da tabela
    MOV  R6, [R8+R9]                ; acede à direção da sonda
    ADD  R9, 2                      ; atualiza índice da tabela
    MOV  R7, [R8+R9]                ; acede à linha limite da sonda
    MOV  R3, 0                      ; transparente
    CALL escreve_pixel
    CMP  R1, R7                     ; verifica se sonda está na posição limite
    JZ   reset_sonda
    SUB  R1, 1                      ; sobe uma linha 
    MOV  R9, 2                      ; atualiza índice da tabela
    MOV  [R8+R9], R1			    ; atualiza a linha da sonda
    ADD  R2, R6                     ; move sonda na direção horizontal
    ADD  R9, 2                      ; atualiza índice da tabela para coluna
    MOV  [R8+R9], R2                ; atualiza a coluna da sonda
    MOV  R3, ROSA                   ; endereço da cor da sonda
    CALL escreve_pixel
    JMP  ciclo_sonda


; RESET_SONDA - Atualiza posição de referência da sonda para a posição inicial.

reset_sonda:                
    MOV  R9, 6                    ; atualiza índice da tabela
    MOV  R4, [R8+R9]              ; copia mov horizontal da sonda 
    CMP  R4, -1                   ; verifica se sonda foi disparada da esquerda
    JZ   reset_sonda_esquerda
    CMP  R4, 1                    ; verifica se sonda foi disparada da direita
    JZ   reset_sonda_direita
    MOV  R9, 2                    ; atualiza índice da tabela
    MOV  R1, 23                   ; atualiza a linha da sonda
    MOV  R2, 32                   ; coluna inicial da sonda
    MOV  R3, 0                    ; sonda não existe
    MOV  [R8], R3                 ; atualiza o estado da sonda 
    MOV  [R8+R9], R1              ; atualiza a linha da sonda
    ADD  R9, 2                    ; atualiza índice da tabela
    MOV  [R8+R9], R2              ; atualiza a coluna da sonda
    JMP  ciclo_sonda

reset_sonda_esquerda:
    MOV  R9, 2                    ; atualiza índice da tabela
    MOV  R1, 22                   ; atualiza a linha da sonda
    MOV  R2, 24                   ; coluna inicial da sonda
    MOV  R3, 0                    ; sonda não existe
    MOV  [R8], R3                 ; atualiza o estado da sonda 
    MOV  [R8+R9], R1              ; atualiza a linha da sonda
    ADD  R9, 2                    ; atualiza índice da tabela
    MOV  [R8+R9], R2              ; atualiza a coluna da sonda
    JMP  ciclo_sonda

reset_sonda_direita:
    MOV  R9, 2                    ; atualiza índice da tabela
    MOV  R1, 22                   ; atualiza a linha da sonda
    MOV  R2, 40                   ; coluna inicial da sonda
    MOV  R3, 0                    ; sonda não existe
    MOV  [R8], R3                 ; atualiza o estado da sonda 
    MOV  [R8+R9], R1              ; atualiza a linha da sonda
    ADD  R9, 2                    ; atualiza índice da tabela
    MOV  [R8+R9], R2              ; atualiza a coluna da sonda
    JMP  ciclo_sonda


; Processo
; ASTEROIDE
;------------------------------------------------------------------------------
PROCESS SP_asteroide        

asteroide:
    MOV  R1, TAMANHO_PILHA    
    MUL	 R1, R11            ; TAMANHO_PILHA vezes o nº da instância do asteroide
    SUB	 SP, R1             ; inicializa SP deste asteróide
    MOV  R10, R11			; cópia do nº de instância do processo
    MOV  R2,  8
    MUL  R10, R2            ; avança para a tabela do asteróide correspondente
    MOV  R2, TAB_ASTEROIDE  ; endereço da tabela que define os asteroides
    ADD  R2, R10            ; endereço do tipo de asteróide correspondente

ciclo_asteroide:
    CALL gera_asteroide
    MOV  R3, [R2]           ; copia tipo de asteróide
    MOV  R5, [R2+2]         ; acede à posição da direção na tabela   
    MOV  R6, [R2+4]         ; acede à posição da linha na tabela
    MOV  R7, [R2+6]         ; acede à posição da coluna na tabela
    CALL desenha_asteroide
    MOV  R0, [evento_int_asteroides]   ; lê o LOCK desta instância do asteróide
    CALL move_asteroide
    JMP  ciclo_asteroide

;==============================================================================
; GERA_ASTERÓIDE - Gera um asteróide aleatoriamente.
;------------------------------------------------------------------------------
gera_asteroide:
    MOV  R1, PIN                  
    MOVB R0, [R1]                 ; lê do periférico
    MOV  R10, PAR_COLUNA_DIRECAO  ; endereço da tabela que define combinações
    SHR  R0, 4                    ; elimina os 4 bits menos significativos
    MOV  R3, 5
    MOD  R0, R3                   ; gera um número aleatório entre 0 e 4
    MOV  R3, 2
    MUL  R0, R3                   ; avança para a tabela correspondente
    MOV  R1, [R10+R0]             ; copia coluna gerada aleatoriamente
    MOV  [R2+6], R1               ; atualiza a coluna do asteróide
    ADD  R0, 2                    ; atualiza índice da tabela para direção
    MOV  R1, [R10+R0]             ; copia direção gerada aleatoriamente
    MOV  [R2+2], R1               ; atualiza a direção do asteróide  
    MOV  R1, PIN
    MOVB R0, [R1]                 ; lê do periférico
    MOV  R10, TIPO_ASTEROIDE      ; endereço da tabela que define tipos
    SHR  R0, 4                    ; elimina os 4 bits menos significativos
    MOV  R3, 4
    MOD  R0, R3                   ; gera um número aleatório entre 0 e 3
    MOV  R3, 2
    MUL  R0, R3                   ; avança para a tabela correspondente
    MOV  R1, [R10+R0]             ; copia tipo gerado aleatoriamente
    MOV  [R2], R1                 ; atualiza o tipo do asteróide
    RET

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
    ADD  R7, R5                  ; incrementa a coluna segundo a direção
    MOV  [R2+6], R7              ; atualiza a coluna de referência do asteróide
    MOV  [R2+4], R6              ; atualiza a linha de referência do asteróide
    RET

;==============================================================================
; DESENHA_ASTEROIDE - Desenha um asteróide na posição de referência.
;------------------------------------------------------------------------------
desenha_asteroide:
    PUSH R1
    PUSH R2
    PUSH R3
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
    POP  R3
    POP  R2
    POP  R1
	RET


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
	MOV	 [evento_int_asteroides], R0	                 
	RFE 

;==============================================================================
; ROT_INT_1 - Rotina de atendimento da interrupção 1.
;             Escreve no LOCK que o processo sonda lê. 
;------------------------------------------------------------------------------
rot_int_1:
	MOV	 [evento_int_sonda], R0	           ; desbloqueia processo sonda
	RFE 

;==============================================================================
; ROT_INT_2 - Rotina de atendimento da interrupção 2.
;             Escreve no LOCK que o processo energia lê. 
;------------------------------------------------------------------------------
rot_int_2:
	MOV	 [evento_int_energia], R0	      ; desbloqueia processo energia
	RFE 
