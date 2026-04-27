`timescale 1ns/1ps

module alu_test;
	reg [7:0] a;
	reg [7:0] b;
	reg [2:0] op;
	wire [7:0] res;

	integer errors;

	alu dut (
		.a(a),
		.b(b),
		.op(op),
		.res(res)
	);

	task check_result;
		input [7:0] exp;
		input [255:0] msg;
		begin
			#1;
			if (res !== exp) begin
				$display("FAIL: %0s | op=%b a=%h b=%h exp=%h got=%h", msg, op, a, b, exp, res);
				errors = errors + 1;
			end else begin
				$display("PASS: %0s", msg);
			end
		end
	endtask

	initial begin
		errors = 0;

		// ADD
		a = 8'h05; b = 8'h03; op = 3'b000; check_result(8'h08, "ADD basic");
		a = 8'hFF; b = 8'h01; op = 3'b000; check_result(8'h00, "ADD wraparound");

		// SUB
		a = 8'h09; b = 8'h04; op = 3'b001; check_result(8'h05, "SUB basic");
		a = 8'h00; b = 8'h01; op = 3'b001; check_result(8'hFF, "SUB underflow wraparound");

		// AND
		a = 8'hAA; b = 8'hCC; op = 3'b010; check_result(8'h88, "AND");

		// OR
		a = 8'hA0; b = 8'h0F; op = 3'b011; check_result(8'hAF, "OR");

		// XOR
		a = 8'hF0; b = 8'hAA; op = 3'b100; check_result(8'h5A, "XOR");

		// NOT (unary on A)
		a = 8'h0F; b = 8'h00; op = 3'b101; check_result(8'hF0, "NOT A");

		// PASS (A pass-through)
		a = 8'h3C; b = 8'hC3; op = 3'b110; check_result(8'h3C, "PASS A");

		// DEFAULT
		a = 8'h12; b = 8'h34; op = 3'b111; check_result(8'h00, "DEFAULT");

		if (errors == 0) begin
			$display("ALU TEST RESULT: PASS");
		end else begin
			$display("ALU TEST RESULT: FAIL (%0d errors)", errors);
		end

		$finish;
	end
endmodule
