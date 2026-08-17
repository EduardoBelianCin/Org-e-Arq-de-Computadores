`timescale 1ns/1ps

module tb_mux_4;
  logic [31:0] a, b, c, d;
  logic [1:0]  sel;
  logic [31:0] muxOut;

  mux_4 dut(.f(muxOut), .a(a), .b(b), .c(c), .d(d), .sel(sel));

  initial begin
    $monitor("%0t: sel = %b | a = %h | b = %h | c = %h | d = %h | muxOut = %h",
              $time, sel, a, b, c, d, muxOut);

    a = 32'hAAAA_AAAA;
    b = 32'hBBBB_BBBB;
    c = 32'hCCCC_CCCC;
    d = 32'hDDDD_DDDD;

    for (sel = 2'b00; sel != 2'b11; sel++) #10;
    #10 sel = 2'b11; #10;

    $stop;
  end

endmodule: tb_mux_4