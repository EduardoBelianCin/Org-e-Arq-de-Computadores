module SafeCrack_config (
    input  logic       CLOCK_50,
    input  logic [3:0] KEY,
    input  logic       RESET,
    output logic [4:0] LEDR,
    output logic       LEDG
);

    logic [3:0] btn;
    logic rst;
    logic unlocked;

    //            VERMELHO  VERDE   AMARELO   AZUL
    assign btn = {~KEY[0], ~KEY[1], ~KEY[2], ~KEY[3]};
    assign rst = ~RESET;

    SafeCrack cofre (
        .clk      (CLOCK_50),
        .rst_n    (rst),
        .btn      (btn),
        .unlocked (unlocked),
        .leds     (LEDR)
    );

    assign LEDG = unlocked;

endmodule