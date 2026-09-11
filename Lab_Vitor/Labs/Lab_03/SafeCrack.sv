// =============================================================================
// button_fsm.sv
// FSM didatica: avanca de estado a cada pressionamento de botao
//
// Objetivo: ponto de partida para discutir em aula
//   [1] Sintaxe SystemVerilog para FSMs (typedef enum, always_ff, always_comb)
//   [2] Deteccao de borda de subida do botao (edge detection)
//   [3] Codificacao de estados one-hot e por que e boa para FPGAs
//   [4] Separacao datapath (saida) x controle (FSM)
//
// Hardware alvo: DE2-115 (Cyclone IV E, clock de 50 MHz)
//   CLOCK_50       -> clk
//   KEY[0]         -> rst_n  (reset, ativo em nivel baixo)
//   KEY[1]         -> btn    (avanca estado, ativo em nivel baixo)
//   LEDR[3:0]      -> leds   (indica estado atual)
// =============================================================================

module SafeCrack (
    input  logic       clk,      // Clock de 50 MHz
    input  logic       rst_n,    // Reset assincrono, ativo baixo (KEY[0])
    input  logic [3:0] btn,      // Botao de avanco, ativo baixo  (KEY[1])
    output logic       unlocked, // LED aceso quando o cofre esta desbloqueado
    output logic [4:0] leds      // Indica o estado atual da FSM
);

// -----------------------------------------------------------------------------
// [1] DEFINICAO DOS ESTADOs

typedef enum logic [3:0] {
    INICIO      = 4'b0000,
    AZUL_1      = 4'b0001,
    AMARELO_2   = 4'b0010,
    AMARELO_3   = 4'b0100,
    DESBLOQUEIO = 4'b1000
} state_t;

state_t state, next_state;

// -----------------------------------------------------------------------------
// [2] DETECCAO DE BORDA DE SUBIDA

logic [3:0] btn_prev; // Estado anterior dos botoes no ciclo anterior
logic btn_rise;       // Pulso de 1 ciclo na borda de subida

assign btn_rise = (btn != 4'b0000) && (btn_prev == 4'b0000);

// Registra o estado anterior do botao (FF simples)
always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) btn_prev <= 4'b0000;
    else btn_prev <= btn;
end

// -----------------------------------------------------------------------------
// [3] PROCESSO SEQUENCIAL -- Registro de estado

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) state <= INICIO;
    else state <= next_state;
end

// -----------------------------------------------------------------------------
// [4] PROCESSO COMBINACIONAL -- Logica de proximo estado

always_comb begin
    next_state = state;

    unique case (state)
        // INICIO -> AZUL1
        INICIO: begin
            if(btn_rise) begin
                if(btn == 4'b0001) next_state = AZUL_1;
                else next_state = INICIO;
            end
        end
        // AZUL1 -> AMARELO2
        AZUL_1: begin
            if(btn_rise) begin
                if(btn == 4'b0010) next_state = AMARELO_2;
                else next_state = INICIO;
            end
        end
        // AMARELO2 -> AMARELO3
        AMARELO_2: begin
            if(btn_rise) begin
                if(btn == 4'b0010) next_state = AMARELO_3;
                else next_state = INICIO;
            end
        end
        // AMARELO3 -> DESBLOQUEIA
        AMARELO_3: begin
            if(btn_rise) begin
                if(btn == 4'b1000) next_state = DESBLOQUEIO;
                else next_state = INICIO;
            end
        end

        DESBLOQUEIO: next_state = DESBLOQUEIO;
        default:     next_state = INICIO;
    endcase
end

// -----------------------------------------------------------------------------
// [5] SAIDA -- Logica de Moore

assign unlocked = (state == DESBLOQUEIO);

always_comb begin
    leds = 5'b00001;

    case (state)
        INICIO:      leds = 5'b00001;
        AZUL_1:      leds = 5'b00010;
        AMARELO_2:   leds = 5'b00100;
        AMARELO_3:   leds = 5'b01000;
        DESBLOQUEIO: leds = 5'b10000;
        default:     leds = 5'b00001;
    endcase
end

endmodule
