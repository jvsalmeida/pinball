;------------------------------------------------------------------------------
; ZONA I: Definicao de constantes
;         Pseudo-instrucao : EQU
;------------------------------------------------------------------------------
CONFIG_TIMER          EQU     FFF6h
ACTIVATE_TIMER        EQU     FFF7h
OFF                   EQU    0d
ON                    EQU    1d
WRITE                 EQU     FFFEh   ; permite escrever um caracter
FIM_TEXTO             EQU     '@'
INITIAL_SP            EQU     FDFFh
CURSOR                EQU     FFFCh   ; permite por o cursor em uma dada posicao
CURSOR_INIT           EQU    FFFFh   ; permite ler o ultimo caracter
ROW_SHIFT             EQU    8d

ROW_WALL              EQU    4d
MAX_ROW_WALL          EQU    21d    ;20d
COLUMN_WALL           EQU    30d
MAX_COLUMN_WALL       EQU    55d    ;60

ROW_UP_ROOF           EQU    3d
ROW_DOWN_ROOF         EQU    20d
COLUMN_ROOF           EQU    31d
MAX_COLUMN_ROOF       EQU    55d   ;59d

ROW_RAMP              EQU    13d
COLUMN_LEFT_RAMP      EQU   31d
MAX_COLUMN_LEFT_RAMP  EQU   34d
COLUMN_RIGHT_RAMP     EQU   54d
MIN_COLUMN_RIGHT_RAMP EQU   51d

ROW_LEFT_BAR          EQU    15d
COLUMN_LEFT_BAR       EQU    34d
MAX_COLUMN_LEFT_BAR   EQU    37d
COLUMN_RIGHT_BAR      EQU    49d
MAX_COLUMN_RIGHT_BAR  EQU    52d

ROW_1_OBSTACLE_1        EQU    7d
MAX_ROW_1_OBSTACLE_1    EQU    10d
COLUMN_1_OBSTACLE_1     EQU    34d
COLUMN_2_OBSTACLE_1     EQU    36d
MAX_COLUMN_1_OBSTACLE_1 EQU    38d  

ROW_1_OBSTACLE_2        EQU    11d
MAX_ROW_1_OBSTACLE_2    EQU    13d
COLUMN_1_OBSTACLE_2     EQU    49d
COLUMN_2_OBSTACLE_2     EQU    50d
MAX_COLUMN_1_OBSTACLE_2 EQU    51d

ROW_TEXT_SCORE          EQU    8d
COLUMN_TEXT_SCORE       EQU    9d
ROW_TEXT_LIFE           EQU    9d

ROW_SHOVEL              EQU    16d
COLUMN_LEFT_SHOVEL      EQU   37d
MAX_COLUMN_LEFT_SHOVEL  EQU   40d
COLUMN_RIGHT_SHOVEL     EQU   48d
MIN_COLUMN_RIGHT_SHOVEL EQU   45d

ROW_MOV_SHOVEL              EQU    15d
COLUMN_MOV_LEFT_SHOVEL      EQU    37d
MAX_COLUMN_MOV_LEFT_SHOVEL  EQU    41d
COLUMN_MOV_RIGHT_SHOVEL     EQU    45d
MAX_COLUMN_MOV_RIGHT_SHOVEL EQU    49d


;------------------------------------------------------------------------------
; ZONA II: definicao de variaveis
;          Pseudo-instrucoes : WORD - palavra (16 bits)
;                              STR  - sequencia de caracteres (cada ocupa 1 palavra: 16 bits).
;          Cada caracter ocupa 1 palavra
;------------------------------------------------------------------------------
                    ORIG    8000h
ScoreText           STR     'Score:', FIM_TEXTO
LifeText            STR     'Lifes:', FIM_TEXTO
RowIndex            WORD  4d
ColumnIndex         WORD  30d
TextIndex           WORD  8d
UpLeftShovel_Flag   WORD  OFF
UpRightShovel_Flag  WORD  OFF


;------------------------------------------------------------------------------
; ZONA II: definicao de tabela de interrupções
;------------------------------------------------------------------------------
                ORIG    FE00h
INT0            WORD    MovUpLeftShovel
INT1            WORD    MovUpRightShovel

                ORIG    FE0Fh
INT15           WORD    Timer


;------------------------------------------------------------------------------
; ZONA IV:   codigo
;         conjunto de instrucoes Assembly, ordenadas de forma a realizar
;          as funcoes pretendidas
;------------------------------------------------------------------------------
                ORIG    0000h
                JMP     Main


;------------------------------------------------------------------------------
;Funcao Timer
;------------------------------------------------------------------------------
Timer:              PUSH   R1
                    PUSH   R2
                    PUSH   R3

                    MOV      R1, M[ UpLeftShovel_Flag ]
                    CMP      R1, ON
                    CALL.Z   MovDownLeftShovel

                    MOV      R1, M[ UpRightShovel_Flag ]
                    CMP      R1, ON
                    CALL.Z   MovDownRightShovel

                    MOV   R1, 1d
                    MOV    M[ CONFIG_TIMER ], R1
                    MOV   R1, ON
                    MOV    M[ ACTIVATE_TIMER ], R1

                    POP    R3
                    POP    R2
                    POP    R1        
                    RTI


;------------------------------------------------------------------------------
;Funcao PrintScore
;------------------------------------------------------------------------------
WriteScore:         PUSH   R1
                    PUSH   R2
                    PUSH   R3
                    PUSH   R4
                    MOV    R4, 0d

CycleWriteScore:    MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, M[ R4 + ScoreText ]
                    CMP     R3, FIM_TEXTO
                    JMP.Z   EndWriteScore
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1
                    MOV     M[ WRITE ], R3  
                    INC     M[ ColumnIndex ]
                    INC     R4
                    JMP     CycleWriteScore

EndWriteScore:      POP    R4
                    POP    R3
                    POP    R2
                    POP    R1
                    RET


;------------------------------------------------------------------------------
;Funcao PrintLife
;------------------------------------------------------------------------------

WriteLife:          PUSH   R1
                    PUSH   R2
                    PUSH   R3
                    PUSH   R4
                    MOV    R4, 0d

CycleWriteLife:     MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, M[ R4 + LifeText ]
                    CMP     R3, FIM_TEXTO
                    JMP.Z   EndWriteLife
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1
                    MOV     M[ WRITE ], R3  
                    INC     M[ ColumnIndex ]
                    INC     R4
                    JMP     CycleWriteLife

EndWriteLife:       POP    R4
                    POP    R3
                    POP    R2
                    POP    R1
                    RET

;------------------------------------------------------------------------------
;Funcao Left LeftWall
;------------------------------------------------------------------------------
LeftWall:       PUSH   R1
                PUSH   R2
                PUSH   R3

CycleLeftWall:  MOV     R1, M[ RowIndex ]     ; linha
                MOV     R2, M[ ColumnIndex ]   ; coluna
                MOV     R3, '|'
                CMP     R1, MAX_ROW_WALL
                JMP.Z   EndLeftWall
                SHL     R1, ROW_SHIFT
                OR      R1, R2           ; R1 vai conter a o cursor na posicao correta
                MOV     M[ CURSOR ], R1
                MOV     M[ WRITE ], R3  
                INC     M[ RowIndex ]
                JMP     CycleLeftWall
                
EndLeftWall:    POP    R3
                POP    R2
                POP    R1
                RET


;------------------------------------------------------------------------------
; Funcao RightWall
;------------------------------------------------------------------------------
RightWall:      PUSH R1
                PUSH R2
                PUSH R3

CycleRightWall: MOV    R1, M[ RowIndex ]
                MOV    R2, M[ ColumnIndex ]
                MOV    R3, '|'
                CMP    R1, MAX_ROW_WALL
                JMP.Z  EndRightWall
                SHL    R1, ROW_SHIFT
                OR     R1, R2
                MOV    M[ CURSOR ], R1
                MOV    M[ WRITE ], R3  
                INC    M[ RowIndex ]
                JMP    CycleRightWall

EndRightWall:   POP   R3
                POP   R2
                POP   R1
                RET


;------------------------------------------------------------------------------
; Funcao UpRoof
;------------------------------------------------------------------------------
UpRoof:         PUSH R1
                PUSH R2
                PUSH R3

CycleUpRoof:    MOV    R1, M[ RowIndex ]
                MOV    R2, M[ ColumnIndex ]
                MOV    R3, '_'
                CMP    R2,  MAX_COLUMN_ROOF
                JMP.Z  EndUpRoof
                SHL    R1, ROW_SHIFT
                OR     R1, R2
                MOV    M[ CURSOR ], R1 
                MOV    M[ WRITE ], R3 
                INC    M[ ColumnIndex ]
                JMP    CycleUpRoof

EndUpRoof:      POP   R3
                POP   R2
                POP   R1
                RET


;------------------------------------------------------------------------------
; Funcao DownRoof
;------------------------------------------------------------------------------
DownRoof:       PUSH R1
                PUSH R2
                PUSH R3

CycleDownRoof:  MOV    R1, M[ RowIndex ]
                MOV    R2, M[ ColumnIndex ]
                MOV    R3, '_'
                CMP    R2,  MAX_COLUMN_ROOF
                JMP.Z  EndDownRoof
                SHL    R1, ROW_SHIFT
                OR     R1, R2
                MOV    M[ CURSOR ], R1 
                MOV    M[ WRITE ], R3 
                INC    M[ ColumnIndex ]
                JMP    CycleDownRoof

EndDownRoof:    POP   R3
                POP   R2
                POP   R1
                RET  


;------------------------------------------------------------------------------
; Funcao LeftRamp
;------------------------------------------------------------------------------
LeftRamp:           PUSH R1
                    PUSH R2
                    PUSH R3

CycleLeftRamp:      MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '\'
                    CMP     R2, MAX_COLUMN_LEFT_RAMP
                    JMP.Z   EndLeftRamp
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ RowIndex ]
                    INC     M[ ColumnIndex ]
                    JMP     CycleLeftRamp

EndLeftRamp:        POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao RightRamp
;------------------------------------------------------------------------------
RightRamp:          PUSH R1
                    PUSH R2
                    PUSH R3

CycleRightRamp:     MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '/'
                    CMP     R2, MIN_COLUMN_RIGHT_RAMP
                    JMP.Z   EndRightRamp
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ RowIndex ]
                    DEC     M[ ColumnIndex ]
                    JMP     CycleRightRamp

EndRightRamp:       POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao LeftBar
;------------------------------------------------------------------------------
LeftBar:            PUSH R1
                    PUSH R2
                    PUSH R3

CycleLeftBar:       MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '_'
                    CMP     R2, MAX_COLUMN_LEFT_BAR
                    JMP.Z   EndLeftBar
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ ColumnIndex ]
                    JMP     CycleLeftBar

EndLeftBar:         POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao RightBar
;------------------------------------------------------------------------------
RightBar:           PUSH R1
                    PUSH R2
                    PUSH R3

CycleRightBar:      MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '_'
                    CMP     R2, MAX_COLUMN_RIGHT_BAR
                    JMP.Z   EndRightBar
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ ColumnIndex ]
                    JMP     CycleRightBar

EndRightBar:        POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao Row_1_Obstacle_1
;------------------------------------------------------------------------------
Row_1_Obstacle_1:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_1_Obstacle_1: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '#'
                        CMP     R1, MAX_ROW_1_OBSTACLE_1
                        JMP.Z   End_Row_1_Obstacle_1
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_1_Obstacle_1

End_Row_1_Obstacle_1:   POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao Row_2_Obstacle_1
;------------------------------------------------------------------------------
Row_2_Obstacle_1:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_2_Obstacle_1: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '#'
                        CMP     R1, MAX_ROW_1_OBSTACLE_1
                        JMP.Z   End_Row_2_Obstacle_1
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_2_Obstacle_1

End_Row_2_Obstacle_1:   POP   R3
                        POP   R2
                        POP   R1
                        RET  


;------------------------------------------------------------------------------
; Funcao Row_3_Obstacle_1
;------------------------------------------------------------------------------
Row_3_Obstacle_1:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_3_Obstacle_1: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '#'
                        CMP     R1, MAX_ROW_1_OBSTACLE_1
                        JMP.Z   End_Row_3_Obstacle_1
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_3_Obstacle_1

End_Row_3_Obstacle_1:   POP   R3
                        POP   R2
                        POP   R1
                        RET  


;------------------------------------------------------------------------------
; Funcao Row_1_Obstacle_2
;------------------------------------------------------------------------------
Row_1_Obstacle_2:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_1_Obstacle_2: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '@'
                        CMP     R1, MAX_ROW_1_OBSTACLE_2
                        JMP.Z   End_Row_1_Obstacle_2
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_1_Obstacle_2

End_Row_1_Obstacle_2:   POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao Row_2_Obstacle_2
;------------------------------------------------------------------------------
Row_2_Obstacle_2:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_2_Obstacle_2: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '@'
                        CMP     R1, MAX_ROW_1_OBSTACLE_2
                        JMP.Z   End_Row_2_Obstacle_2
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_2_Obstacle_2

End_Row_2_Obstacle_2:   POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao Row_3_Obstacle_2
;------------------------------------------------------------------------------
Row_3_Obstacle_2:       PUSH R1
                        PUSH R2
                        PUSH R3

Cycle_Row_3_Obstacle_2: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '@'
                        CMP     R1, MAX_ROW_1_OBSTACLE_2
                        JMP.Z   End_Row_3_Obstacle_2
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        JMP     Cycle_Row_3_Obstacle_2

End_Row_3_Obstacle_2:   POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao LeftShovel
;------------------------------------------------------------------------------
LeftShovel:         PUSH R1
                    PUSH R2
                    PUSH R3

CycleLeftShovel:    MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '\'
                    CMP     R2, MAX_COLUMN_LEFT_SHOVEL
                    JMP.Z   EndLeftShovel
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ RowIndex ]
                    INC     M[ ColumnIndex ]
                    JMP     CycleLeftShovel

EndLeftShovel:      POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao RightShovel
;------------------------------------------------------------------------------
RightShovel:        PUSH R1
                    PUSH R2
                    PUSH R3

CycleRightShovel:   MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '/'
                    CMP     R2, MIN_COLUMN_RIGHT_SHOVEL
                    JMP.Z   EndRightShovel
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ RowIndex ]
                    DEC     M[ ColumnIndex ]
                    JMP     CycleRightShovel

EndRightShovel:     POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao EraseRightShovel
;------------------------------------------------------------------------------
EraseRightShovel:       PUSH R1
                        PUSH R2
                        PUSH R3

CycleEraseRightShovel:  MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, ' '
                        CMP     R2, MIN_COLUMN_RIGHT_SHOVEL
                        JMP.Z   EndEraseRightShovel
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        DEC     M[ ColumnIndex ]
                        JMP     CycleEraseRightShovel

EndEraseRightShovel:    POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao EraseLeftShovel
;------------------------------------------------------------------------------
EraseLeftShovel:    PUSH R1
                    PUSH R2
                    PUSH R3

CycleEraseLeftShovel:   MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, ' '
                        CMP     R2, MAX_COLUMN_LEFT_SHOVEL
                        JMP.Z   EndEraseLeftShovel
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ RowIndex ]
                        INC     M[ ColumnIndex ]
                        JMP     CycleEraseLeftShovel

EndEraseLeftShovel: POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao UpLeftShovel
;------------------------------------------------------------------------------
UpLeftShovel:       PUSH   R1
                    PUSH   R2
                    PUSH   R3

CycleUpLeftShovel:  MOV     R1, M[ RowIndex ]
                    MOV     R2, M[ ColumnIndex ]
                    MOV     R3, '_'
                    CMP     R2, MAX_COLUMN_MOV_LEFT_SHOVEL
                    JMP.Z   EndUpLeftShovel
                    SHL     R1, ROW_SHIFT
                    OR      R1, R2
                    MOV     M[ CURSOR ], R1 
                    MOV     M[ WRITE ], R3
                    INC     M[ ColumnIndex ]
                    JMP     CycleUpLeftShovel        

EndUpLeftShovel:    POP   R3
                    POP   R2
                    POP   R1
                    RET


;------------------------------------------------------------------------------
; Funcao MovUpLeftShovel
;------------------------------------------------------------------------------
MovUpLeftShovel:        PUSH   R1
                        PUSH   R2
                        PUSH   R3

                        MOV     R1, ROW_SHOVEL
                        MOV     M[ RowIndex ], R1
                        MOV     R1, COLUMN_LEFT_SHOVEL
                        MOV     M[ ColumnIndex ], R1
                        CALL    EraseLeftShovel
                        
                        MOV     R1, ROW_MOV_SHOVEL
                        MOV     M[ RowIndex ], R1
                        MOV     R1, COLUMN_MOV_LEFT_SHOVEL
                        MOV     M[ ColumnIndex ], R1
                        CALL    UpLeftShovel

                        MOV     R1, ON
                        MOV     M[ UpLeftShovel_Flag ], R1
                
                        POP   R3
                        POP   R2
                        POP   R1
                        RTI


;------------------------------------------------------------------------------
; Funcao EraseUpLeftShovel
;------------------------------------------------------------------------------
EraseUpLeftShovel:      PUSH   R1
                        PUSH   R2
                        PUSH   R3

CycleEraseUpLeftShovel: MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, ' '
                        CMP     R2, MAX_COLUMN_MOV_LEFT_SHOVEL
                        JMP.Z   EndEraseUpLeftShovel
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ ColumnIndex ]
                        JMP     CycleEraseUpLeftShovel        

EndEraseUpLeftShovel:   POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao MovDownLeftShovel
;------------------------------------------------------------------------------
MovDownLeftShovel:      PUSH   R1
                        PUSH   R2
                        PUSH   R3
                        
                        MOV     R1, ROW_MOV_SHOVEL
                        MOV     M[ RowIndex ], R1
                        MOV     R1, COLUMN_MOV_LEFT_SHOVEL
                        MOV     M[ ColumnIndex ], R1
                        CALL    EraseUpLeftShovel
                    
                        MOV     R1, ROW_SHOVEL
                        MOV     M[ RowIndex ], R1
                        MOV     R1, COLUMN_LEFT_SHOVEL
                        MOV     M[ ColumnIndex ], R1
                        CALL    LeftShovel

                        MOV     R1, OFF
                        MOV     M[ UpLeftShovel_Flag ], R1

                        POP   R3
                        POP   R2
                        POP   R1
                        RET        

                    
;------------------------------------------------------------------------------
; Funcao UpRightShovel
;------------------------------------------------------------------------------
UpRightShovel:          PUSH   R1
                        PUSH   R2
                        PUSH   R3

CycleUpRightShovel:     MOV     R1, M[ RowIndex ]
                        MOV     R2, M[ ColumnIndex ]
                        MOV     R3, '_'
                        CMP     R2, MAX_COLUMN_MOV_RIGHT_SHOVEL
                        JMP.Z   EndUpRightShovel
                        SHL     R1, ROW_SHIFT
                        OR      R1, R2
                        MOV     M[ CURSOR ], R1 
                        MOV     M[ WRITE ], R3
                        INC     M[ ColumnIndex ]
                        JMP     CycleUpRightShovel        

EndUpRightShovel:       POP   R3
                        POP   R2
                        POP   R1
                        RET


;------------------------------------------------------------------------------
; Funcao EraseUpRightShovel
;------------------------------------------------------------------------------
EraseUpRightShovel:         PUSH   R1
                            PUSH   R2
                            PUSH   R3

EraseCycleUpRightShovel:    MOV     R1, M[ RowIndex ]
                            MOV     R2, M[ ColumnIndex ]
                            MOV     R3, ' '
                            CMP     R2, MAX_COLUMN_MOV_RIGHT_SHOVEL
                            JMP.Z   EndEraseUpRightShovel
                            SHL     R1, ROW_SHIFT
                            OR      R1, R2
                            MOV     M[ CURSOR ], R1 
                            MOV     M[ WRITE ], R3
                            INC     M[ ColumnIndex ]
                            JMP     EraseCycleUpRightShovel        

EndEraseUpRightShovel:      POP   R3
                            POP   R2
                            POP   R1
                            RET


;------------------------------------------------------------------------------
; Funcao MovUpRightShovel
;------------------------------------------------------------------------------
MovUpRightShovel:           PUSH   R1
                            PUSH   R2
                            PUSH   R3

                            MOV     R1, ROW_SHOVEL
                            MOV     M[ RowIndex ], R1
                            MOV     R1, COLUMN_RIGHT_SHOVEL
                            MOV     M[ ColumnIndex ], R1
                            CALL    EraseRightShovel
                            
                            MOV     R1, ROW_MOV_SHOVEL
                            MOV     M[ RowIndex ], R1
                            MOV     R1, COLUMN_MOV_RIGHT_SHOVEL
                            MOV     M[ ColumnIndex ], R1
                            CALL    UpRightShovel

                            MOV     R1, ON
                            MOV     M[ UpRightShovel_Flag ], R1
                
                            POP   R3
                            POP   R2
                            POP   R1
                            RTI


;------------------------------------------------------------------------------
; Funcao MovDownRightShovel
;------------------------------------------------------------------------------
MovDownRightShovel:         PUSH   R1
                            PUSH   R2
                            PUSH   R3

                            MOV     R1, ROW_MOV_SHOVEL
                            MOV     M[ RowIndex ], R1
                            MOV     R1, COLUMN_MOV_RIGHT_SHOVEL
                            MOV     M[ ColumnIndex ], R1
                            CALL    EraseUpRightShovel

                            MOV     R1, ROW_SHOVEL
                            MOV     M[ RowIndex ], R1
                            MOV     R1, COLUMN_RIGHT_SHOVEL
                            MOV     M[ ColumnIndex ], R1
                            CALL    RightShovel

                            MOV     R1, OFF
                            MOV     M[ UpRightShovel_Flag ], R1

                            POP   R3
                            POP   R2
                            POP   R1
                            RET


;------------------------------------------------------------------------------
; Funcao Screen
;------------------------------------------------------------------------------
Screen:         PUSH    R1

                CALL    LeftWall

                MOV     R1, ROW_WALL
                MOV     M[ RowIndex ], R1
                MOV     R1, MAX_COLUMN_WALL
                MOV     M[ ColumnIndex], R1
                CALL    RightWall  

                MOV     R1, ROW_UP_ROOF
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_ROOF
                MOV     M[ ColumnIndex ], R1
                CALL    UpRoof

                MOV     R1, ROW_DOWN_ROOF
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_ROOF
                MOV     M[ ColumnIndex ], R1
                CALL    DownRoof

                MOV     R1, ROW_RAMP
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_LEFT_RAMP
                MOV     M[ ColumnIndex ], R1
                CALL    LeftRamp

                MOV     R1, ROW_RAMP
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_RIGHT_RAMP
                MOV     M[ ColumnIndex ], R1
                CALL    RightRamp

                MOV     R1, ROW_LEFT_BAR
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_LEFT_BAR
                MOV     M[ ColumnIndex ], R1
                CALL    LeftBar

                MOV     R1, ROW_LEFT_BAR
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_RIGHT_BAR
                MOV     M[ ColumnIndex ], R1
                CALL    RightBar

                MOV     R1, ROW_1_OBSTACLE_1
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_1_OBSTACLE_1
                MOV     M[ ColumnIndex ], R1
                CALL    Row_1_Obstacle_1

                MOV     R1, ROW_1_OBSTACLE_1
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_2_OBSTACLE_1
                MOV     M[ ColumnIndex ], R1
                CALL    Row_2_Obstacle_1

                MOV     R1, ROW_1_OBSTACLE_1
                MOV     M[ RowIndex ], R1
                MOV     R1, MAX_COLUMN_1_OBSTACLE_1
                MOV     M[ ColumnIndex ], R1
                CALL    Row_3_Obstacle_1

                MOV     R1, ROW_1_OBSTACLE_2
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_1_OBSTACLE_2
                MOV     M[ ColumnIndex ], R1
                CALL    Row_1_Obstacle_2

                MOV     R1, ROW_1_OBSTACLE_2
                MOV     M[ RowIndex ], R1
                MOV     R1, MAX_COLUMN_1_OBSTACLE_2
                MOV     M[ ColumnIndex ], R1
                CALL    Row_2_Obstacle_2

                MOV     R1, ROW_1_OBSTACLE_2
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_2_OBSTACLE_2
                MOV     M[ ColumnIndex ], R1
                CALL    Row_3_Obstacle_2

                MOV     R1, ROW_TEXT_SCORE
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_TEXT_SCORE
                MOV     M[ ColumnIndex ], R1
                CALL    WriteScore

                MOV     R1, ROW_TEXT_LIFE
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_TEXT_SCORE
                MOV     M[ ColumnIndex ], R1
                CALL    WriteLife

                MOV     R1, ROW_SHOVEL
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_LEFT_SHOVEL
                MOV     M[ ColumnIndex ], R1
                CALL    LeftShovel

                MOV     R1, ROW_SHOVEL
                MOV     M[ RowIndex ], R1
                MOV     R1, COLUMN_RIGHT_SHOVEL
                MOV     M[ ColumnIndex ], R1
                CALL    RightShovel

EndScreen:      POP     R1
                RET


Main:           ENI
                MOV     R1, INITIAL_SP
                MOV     SP, R1         ; We need to initialize the stack
                MOV     R1, CURSOR_INIT    ; We need to initialize the cursor 
                MOV     M[ CURSOR ], R1    ; with value CURSOR_INIT
                MOV     R1, 70d
                MOV     M[ CONFIG_TIMER ], R1
                MOV     R1, ON
                MOV     M[ ACTIVATE_TIMER ], R1


                CALL    Screen

Cycle:          BR      Cycle  
Halt:           BR      Halt
