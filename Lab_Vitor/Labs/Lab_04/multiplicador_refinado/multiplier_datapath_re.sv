// multiplier_datapath.sv
// Datapath da unidade de multiplicacao (32 bits → produto de 64 bits)
// Baseado na Figura 3.3 - Patterson & Hennessy, Computer Organization and Design
//
// Registradores conforme a figura:
//   multiplicand_reg [63:0] — comeca com multiplicando nos bits [31:0], zeros nos [63:32]
//                             shift left a cada iteracao
//   multiplier_reg   [31:0] — contem o multiplicador
//                             shift right a cada iteracao
//   product_reg      [63:0] — inicializado em 0; acumula o resultado
//
// Sinais de controle vindos da FSM:
//   load       — carrega os operandos iniciais nos registradores
//   product_wr — habilita a escrita do resultado da ALU em product_reg
//   shift_en   — desloca multiplicand_reg a esquerda e multiplier_reg a direita

module multiplier_datapath_re (
    input  logic        clk,
    input  logic        rst_n,

    // Entradas de dados
    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,  

    // Sinais de controle vindos da FSM
    input  logic        load,        // Carrega operandos iniciais
    input  logic        product_wr,  // Escreve soma da ALU em product_reg
    input  logic        shift_en,    // Shift left em multiplicand, shift right em multiplier

    // Saidas de status para a FSM
    output logic        multiplier_lsb, // Bit 0 do registrador product, serve para saber o bit atual

    // Saída do resultado
    output logic [63:0] product
);

    // -----------------------------------------------------------------------
    // Registradores internos (Figura 3.4)
    // -----------------------------------------------------------------------
    logic [64:0] product_reg; // Produto com carry-out
    logic [31:0] multiplicand_reg;  
    logic [32:0] alu_sum; // 33 bits para o carry out da soma 

    alu_32 alu (
        .a   (product_reg[63:32]),
        .b   (multiplicand_reg),
        .sum (alu_sum[31:0])
    );

    assign multiplier_lsb = product_reg[0];
    assign product        = product_reg[63:0];
    assign alu_sum[32] = {1'b0, product_reg[63:32]} + {1'b0, multiplicand_reg};

    // -----------------------------------------------------------------------
    // Atualizacao dos registradores
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product_reg      <= '0;
            multiplicand_reg <= '0;

        end else if (load) begin
            // Inicializacao conforme Figura 3.4:
            // Multiplicand -> bits [31:0], bits [63:32] = 0
            multiplicand_reg <= multiplicand_in;
            product_reg   <= {33'b0, multiplier_in};

        end else begin
            // Passo 1 (Figura 3.4): Product = Product + Multiplicand (se habilitado)
            if (product_wr)
                product_reg[64:32]  <= alu_sum;

            // Passos 2 e 3 (Figura 3.4): deslocamentos
            if (shift_en) begin
                product_reg   <= {1'b0, product_reg[64:1]};   // shift right (lógico)
            end
        end
    end

endmodule