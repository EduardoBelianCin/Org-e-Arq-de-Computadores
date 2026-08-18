`timescale 1ns/1ps

module tb_mux_4;
	logic [31:0] a, b, c, d;
	logic [1:0]  sel;
	logic [31:0] muxOut;
	logic [2:0]count;

	mux_4 dut(.f(muxOut), .a(a), .b(b), .c(c), .d(d), .sel(count[1:0]));

	initial begin
		a = 32'b00000111111111100000000001111000;
		b = 32'b11110000000000000000000011111111;
		c = 32'b00011110000000001111111111111111;
		d = 32'b00000000111111111111111111111111;

		$monitor("%0t: sel = %b | a = %h | b = %h | c = %h | d = %h | muxOut = %h", $time, count[1:0], a, b, c, d, muxOut);

		for(count = 0; count != 3'b111; count++) begin
			a += 32'b10101;
			b += 32'b1010101;
			c += 32'b10101010101;
			d += 32'b101010101010101;
			#10;
		end

		#10 $stop;
	end

endmodule: tb_mux_4