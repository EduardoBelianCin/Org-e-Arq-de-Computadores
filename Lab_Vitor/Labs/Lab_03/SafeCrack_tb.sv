// =============================================================================
// SafeCrack_tb.sv
// Testbench para SafeCrack.sv
// =============================================================================

`timescale 1ns/1ps

module SafeCrack_tb;

    // -------------------------------------------------------------------------
    // Sinais de estimulo e observacao
    // -------------------------------------------------------------------------
    logic       clk;
    logic       rst_n;
    logic [3:0] btn;
    logic       unlocked;
    logic [4:0] leds;

    // -------------------------------------------------------------------------
    // Instancia do DUT (Device Under Test)
    // -------------------------------------------------------------------------
    SafeCrack dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .btn      (btn),
        .unlocked (unlocked),
        .leds     (leds)
    );

    // -------------------------------------------------------------------------
    // Geracao de clock: periodo de 20ns -> 50 MHz
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk;

    // -------------------------------------------------------------------------
    // Task: pressiona um botao por alguns ciclos e solta
    // -------------------------------------------------------------------------
    task press_button(input logic [3:0] button_code, input int hold_cycles);
        @(negedge clk);
        btn = button_code;
        repeat (hold_cycles) @(posedge clk);
        @(negedge clk);
        btn = 4'b0000;
        repeat (3) @(posedge clk);
    endtask

    // -------------------------------------------------------------------------
    // Task: verifica LEDs de estado e saida unlocked
    // -------------------------------------------------------------------------
    task check_state(
        input logic [4:0] expected_leds,
        input logic       expected_unlocked,
        input string      msg
    );
        @(negedge clk);
        if ((leds === expected_leds) && (unlocked === expected_unlocked))
            $display("[PASS] %s | leds = 5'b%05b | unlocked = %b",
                     msg, leds, unlocked);
        else
            $display("[FAIL] %s | leds esperado = 5'b%05b, obtido = 5'b%05b | unlocked esperado = %b, obtido = %b",
                     msg, expected_leds, leds, expected_unlocked, unlocked);
    endtask

    // -------------------------------------------------------------------------
    // Sequencia de testes
    // -------------------------------------------------------------------------
    initial begin
        // Dump de formas de onda para visualizacao no GTKWave/ModelSim
        $dumpfile("SafeCrack.vcd");
        $dumpvars(0, SafeCrack_tb);

        // Condicao inicial
        rst_n = 1'b1;
        btn   = 4'b0000;

        // ------------------------------------------------------------------
        // Teste 1: Reset
        // ------------------------------------------------------------------
        $display("\n=== Teste 1: Reset ===");
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(5'b00001, 1'b0, "Apos reset -> INICIO");

        // ------------------------------------------------------------------
        // Teste 2: Sequencia correta (Azul -> Amarelo -> Amarelo -> Vermelho)
        // ------------------------------------------------------------------
        $display("\n=== Teste 2: Sequencia correta de abrir o cofre ===");

        press_button(4'b0001, 2);
        check_state(5'b00010, 1'b0, "Azul correto -> AZUL_1");

        press_button(4'b0010, 2);
        check_state(5'b00100, 1'b0, "1o Amarelo correto -> AMARELO_2");

        press_button(4'b0010, 2);
        check_state(5'b01000, 1'b0, "2o Amarelo correto -> AMARELO_3");

        press_button(4'b1000, 2);
        check_state(5'b10000, 1'b1, "Vermelho correto -> DESBLOQUEIO");

        // ------------------------------------------------------------------
        // Teste 3: Botao segurado nao deve avancar mais de uma vez
        // ------------------------------------------------------------------
        $display("\n=== Teste 3: Botao segurado ===");
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(negedge clk);
        btn = 4'b0001;
        repeat (20) @(posedge clk);
        @(negedge clk);
        btn = 4'b0000;
        repeat (3) @(posedge clk);
        check_state(5'b00010, 1'b0, "Azul mantido pressionado -> apenas AZUL_1");

        // ------------------------------------------------------------------
        // Teste 4: Reset apos desbloqueio
        // ------------------------------------------------------------------
        $display("\n=== Teste 4: Reset para fechar o cofre ===");
        press_button(4'b0010, 2);
        press_button(4'b0010, 2);
        press_button(4'b1000, 2);
        check_state(5'b10000, 1'b1, "Cofre desbloqueado antes do reset");
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(5'b00001, 1'b0, "Reset em DESBLOQUEIO -> INICIO");

        // ------------------------------------------------------------------
        // Teste 5: Sequencia incorreta reinicia a FSM
        // ------------------------------------------------------------------
        $display("\n=== Teste 5: Sequencia incorreta ===");
        press_button(4'b0001, 2);
        check_state(5'b00010, 1'b0, "Azul correto -> AZUL_1");

        press_button(4'b0100, 2);
        check_state(5'b00001, 1'b0, "Verde incorreto -> INICIO");

        $display("\n=== Simulacao concluida ===\n");
        $finish;
    end

endmodule
