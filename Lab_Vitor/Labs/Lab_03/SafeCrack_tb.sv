// =============================================================================
// button_fsm_tb.sv
// Testbench para button_fsm.sv
//
// Simula:
//   [1] Reset inicial
//   [2] Varios pressionamentos do botao (verifica avanco de estados)
//   [3] Volta ao estado S0 apos 4 pressionamentos (ciclo completo)
//   [4] Segurar o botao pressionado (verifica que nao avanca mais de 1 vez)
// =============================================================================

`timescale 1ns/1ps

module button_fsm_tb;

    // -------------------------------------------------------------------------
    // Sinais de estimulo e observacao
    // -------------------------------------------------------------------------
    logic       clk;
    logic       rst_n;
    logic [3:0] btn;
    logic [3:0] leds;

    // -------------------------------------------------------------------------
    // Instancia do DUT (Device Under Test)
    // -------------------------------------------------------------------------
    button_fsm dut (
        .clk   (clk),
        .rst_n (rst_n),
        .btn   (btn),
        .leds  (leds)
    );

    // -------------------------------------------------------------------------
    // Geracao de clock: periodo de 20ns -> 50 MHz
    // -------------------------------------------------------------------------
    initial clk = 0;
    always #10 clk = ~clk;

    // -------------------------------------------------------------------------
    // Task: pressiona o botao por alguns ciclos e solta
    //   - btn e ativo baixo na placa, mas aqui simulamos como ativo baixo:
    //     btn = 0 quando pressionado, btn = 1 quando solto
    //   - hold_cycles: quantos ciclos o botao fica pressionado
    // -------------------------------------------------------------------------
    task press_button(input int btn_idx, input int hold_cycles);
        @(negedge clk);
        btn[btn_idx] = 1'b0;
        repeat (hold_cycles) @(posedge clk);
        @(negedge clk);
        btn[btn_idx] = 1'b1;
        repeat (3) @(posedge clk);
    endtask

    // -------------------------------------------------------------------------
    // Task: verifica o estado dos LEDs e imprime resultado
    // -------------------------------------------------------------------------
    task check_state(input logic [3:0] expected, input string msg);
        @(negedge clk);
        if (leds === expected)
            $display("[PASS] %s | leds = 4'b%04b", msg, leds);
        else
            $display("[FAIL] %s | esperado = 4'b%04b, obtido = 4'b%04b",
                     msg, expected, leds);
    endtask

    // -------------------------------------------------------------------------
    // Sequencia de testes
    // -------------------------------------------------------------------------
initial begin
        // Dump de formas de onda para visualizacao no GTKWave
        $dumpfile("button_fsm.vcd");
        $dumpvars(0, button_fsm_tb);

        // Condicao inicial
        rst_n = 1'b1;
        btn   = 4'b1111;  // Botoes soltos (ativo baixo, entao 1 = solto)

        // ------------------------------------------------------------------
        // Teste 1: Reset
        // ------------------------------------------------------------------
        $display("\n=== Teste 1: Reset ===");
        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(4'b0001, "Apos reset -> S0");

        // ------------------------------------------------------------------
        // Teste 2: Sequencia Correta (S0 -> S1 -> S2 -> S3 / Unlock)
        // ------------------------------------------------------------------
        $display("\n=== Teste 2: Sequencia Correta de Abrir o Cofre ===");
        
        press_button(0, 2);
        check_state(4'b0010, "1o Botao correto -> S1");

        press_button(1, 2);
        check_state(4'b0100, "2o Botao correto -> S2");

        press_button(3, 2);
        check_state(4'b1000, "3o Botao correto -> S3 (UNLOCKED)");

        // ------------------------------------------------------------------
        // Teste 3: Botao segurado nao deve avancar mais de 1 estado
        // ------------------------------------------------------------------
        $display("\n=== Teste 3: Botao segurado no estado Unlock ===");
        press_button(3, 20); // Segura por 20 ciclos
        check_state(4'b1000, "Botao mantido pressionado -> Continua em UNLOCKED");

        // ------------------------------------------------------------------
        // Teste 4: Reset apos desbloqueio
        // ------------------------------------------------------------------
        $display("\n=== Teste 4: Reset para fechar o cofre ===");
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(4'b0001, "Reset em UNLOCKED -> Retorna para S0 (Bloqueado)");

        // ------------------------------------------------------------------
        // Teste 5: Sequencia Incorreta (Errar botão reseta FSM)
        // ------------------------------------------------------------------
        $display("\n=== Teste 5: Sequencia Incorreta (Erro reseta FSM) ===");
        
        press_button(0, 2); // Botão 1 correto -> S1
        check_state(4'b0010, "1o Botao correto -> Avanca para S1");

        press_button(2, 2); // Botão INCORRETO (Esperava 1, recebeu 2)
        check_state(4'b0001, "Botao incorreto pressionado -> Voltou para S0");

        $display("\n=== Simulacao concluida ===\n");
        $finish;
    end

endmodule
