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

		// B - A
		a = 8'h04; b = 8'h09; op = 3'b010; check_result(8'h05, "B minus A");
		a = 8'h01; b = 8'h00; op = 3'b010; check_result(8'hFF, "B minus A wraparound");

		// PASS A
		a = 8'hA0; b = 8'h0F; op = 3'b011; check_result(8'hA0, "PASS A");

		// PASS B
		a = 8'hF0; b = 8'hAA; op = 3'b100; check_result(8'hAA, "PASS B");

		// MUL
		a = 8'd3; b = 8'd4; op = 3'b101; check_result(8'd12, "MUL");

		// A / B
		a = 8'd12; b = 8'd4; op = 3'b110; check_result(8'd3, "A divided by B");
		a = 8'd12; b = 8'd0; op = 3'b110; check_result(8'd0, "A divided by zero");

		// B / A
		a = 8'd3; b = 8'd12; op = 3'b111; check_result(8'd4, "B divided by A");
		a = 8'd0; b = 8'd12; op = 3'b111; check_result(8'd0, "B divided by zero");

		if (errors == 0) begin
			$display("ALU TEST RESULT: PASS");
		end else begin
			$display("ALU TEST RESULT: FAIL (%0d errors)", errors);
		end

		$finish;
	end
endmodule
