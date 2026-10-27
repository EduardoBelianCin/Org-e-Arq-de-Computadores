// =============================================================================
// pl_mmio.sv
// Controlador de E/S Mapeada em Memoria -- DE2-115 (RV32I pipelined)
//
// Mapa de enderecos (byte address, word-aligned):
//   0x400  SW    [17:0]  read-only    18 chaves deslizantes
//   0x404  KEY   [3:0]   read-only     4 botoes push
//   0x408  LEDR  [17:0]  write-only   18 LEDs vermelhos
//   0x40C  LEDG  [8:0]   write-only    9 LEDs verdes
//   0x410  UART  [31:0]  read/write    porta serial RS-232
//            LW  -> {22'b0, tx_busy, rx_ready, rx_data[7:0]}
//            SW  -> envia WriteData[7:0] como um byte
//   0x414  CYCLE [31:0]  read-only    contador de ciclos de clock (32 bits)
//
// Selecao: alu_result[10] = 1 seleciona este modulo (enderecos 0x400-0x7FF).
// O periferico e selecionado por alu_result[4:2] dentro da janela MMIO.
//
// Leituras: combinatoriais; escritas em LED e UART: registradas em posedge clk.
// =============================================================================

`timescale 1ns / 1ps

module pl_mmio #(
    parameter int CLK_HZ = 50_000_000
) (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        MemWrite,
    input  logic        MemRead,
    input  logic [2:0]  addr,        // alu_result[4:2]
    input  logic [31:0] WriteData,

    input  logic [17:0] SW,
    input  logic [3:0]  KEY,

    output logic [17:0] LEDR,
    output logic [8:0]  LEDG,

    output logic        UART_TXD,
    input  logic        UART_RXD,

    output logic [31:0] ReadData
);

    // -------------------------------------------------------------------------
    // Instancia da UART
    // -------------------------------------------------------------------------
    logic       tx_write;
    logic       tx_busy;
    logic [7:0] rx_data;
    logic       rx_valid;

    pl_uart #(
        .CLK_HZ (CLK_HZ),
        .BAUD   (9_600)
    ) uart_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_write (tx_write),
        .tx_data  (tx_byte),
        .tx_busy  (tx_busy),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .TXD      (UART_TXD),
        .RXD      (UART_RXD)
    );

    // -------------------------------------------------------------------------
    // Buffer de um byte para transmissao
    //
    // Cada SW para 0x410 envia somente WriteData[7:0].
    // tx_pending fica alto ate a UART aceitar o byte.
    // O CPU deve aguardar tx_busy == 0 (bit 9 de LW 0x410) antes de nova SW.
    // -------------------------------------------------------------------------
    logic        tx_pending;
    logic [7:0]  tx_byte;

    // Strobe para a UART: ativo enquanto ha byte pendente e UART disponivel
    assign tx_write = tx_pending & ~tx_busy;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_byte    <= 8'b0;
            tx_pending <= 1'b0;
        end else if (MemWrite && (addr == 3'b100) && !tx_pending && !tx_busy) begin
            // One SW writes one UART byte; the CPU supplies it in WriteData[7:0].
            tx_byte    <= WriteData[7:0];
            tx_pending <= 1'b1;
        end else if (tx_pending && !tx_busy) begin
            // UART samples tx_write on this edge.
            tx_pending <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // Contador de ciclos de clock (32 bits, read-only em 0x414)
    // -------------------------------------------------------------------------
    logic [31:0] cycle_count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cycle_count <= 32'b0;
        else        cycle_count <= cycle_count + 32'd1;
    end

    // -------------------------------------------------------------------------
    // Flag rx_ready (sticky): set em rx_valid, clear em LW do endereco UART
    // -------------------------------------------------------------------------
    logic rx_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_ready <= 1'b0;
        else if (rx_valid)
            rx_ready <= 1'b1;
        else if (MemRead & (addr == 3'b100))
            rx_ready <= 1'b0;
    end

    // -------------------------------------------------------------------------
    // Mux de leitura (combinatorial)
    // -------------------------------------------------------------------------
    always_comb begin
        case (addr)
            3'b000:  ReadData = {14'b0, SW};
            3'b001:  ReadData = {28'b0, KEY};
            3'b100:  ReadData = {22'b0, (tx_pending | tx_busy), rx_ready, rx_data};
            3'b101:  ReadData = cycle_count;
            default: ReadData = 32'b0;
        endcase
    end

    // -------------------------------------------------------------------------
    // Registradores de LED (escrita sincrona)
    // -------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            LEDR <= 18'b0;
            LEDG <=  9'b0;
        end else if (MemWrite) begin
            case (addr)
                3'b010: LEDR <= WriteData[17:0];
                3'b011: LEDG <= WriteData[8:0];
                default: ;
            endcase
        end
    end

endmodule
