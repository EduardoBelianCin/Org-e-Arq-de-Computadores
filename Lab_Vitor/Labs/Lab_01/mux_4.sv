module mux_4
  #(parameter WIDTH = 32)
  (
    output logic [WIDTH-1:0] f,
    input  logic [WIDTH-1:0] a, b, c, d,
    input  logic [1:0]       sel
  );

  logic [WIDTH-1:0] ab, cd;

  genvar i;
  generate
    for (i = 0; i < WIDTH; i++) begin : bit_slice
      mux m0(.f(ab[i]), .a(a[i]), .b(b[i]), .sel(sel[0]));
      mux m1(.f(cd[i]), .a(c[i]), .b(d[i]), .sel(sel[0]));

      mux m2(.f(f[i]),  .a(ab[i]), .b(cd[i]), .sel(sel[1]));
    end
  endgenerate

endmodule
