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

module button_fsm (
    input  logic       clk,    // Clock de 50 MHz
    input  logic       rst_n,  // Reset assincrono, ativo baixo (KEY[0])
    input  logic [3:0] btn,    // Botao de avanco, ativo baixo  (KEY[1])
    output logic [3:0] leds    // LEDs indicadores de estado
);

// -----------------------------------------------------------------------------
// [1] DEFINICAO DOS ESTADOs

typedef enum logic [3:0] {
    INICIO      = 4'b0000,
    AZUL_1      = 4'b0001,
    AMARELO_2   = 4'b0010,
    AMARELO_3   = 4'b0100,
    DESBLOQUEIO = 4'b1000,
} state_t;

state_t state, next_state;

// -----------------------------------------------------------------------------
// [2] DETECCAO DE BORDA DE SUBIDA

logic btn_active;  // Botao em logica positiva (1 = pressionado)
logic btn_prev;    // Valor do botao no ciclo anterior
logic btn_rise;    // Pulso de 1 ciclo na borda de subida

assign btn_active = ~btn;
assign btn_rise   = btn_active & ~btn_prev;  // Borda de subida

// Registra o estado anterior do botao (FF simples)
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) btn_prev <= 1'b0;
    else        btn_prev <= btn_active;
end

// -----------------------------------------------------------------------------
// [3] PROCESSO SEQUENCIAL -- Registro de estado

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= INICIO;
    else        state <= next_state;
end

// -----------------------------------------------------------------------------
// [4] PROCESSO COMBINACIONAL -- Logica de proximo estado

always_comb begin
    next_state = state;  // Default: mantem estado se nao houver borda

    unique case (state)
        INICIO: if (btn_rise)      next_state = AZUL_1;
        AZUL_1: if (btn_rise)      next_state = AMARELO_2;
        AMARELO_2: if (btn_rise)   next_state = AMARELO_3;
        AMARELO_3: if (btn_rise)   next_state = DESBLOQUEIO;
        DESBLOQUEIO: if (btn_rise) next_state = INICIO;
        default:                   next_state = INICIO;
    endcase
end

// -----------------------------------------------------------------------------
// [5] SAIDA -- Logica de Moore

assign leds = state;

endmodule
