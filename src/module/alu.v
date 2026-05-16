module alu(input [7:0] a, b, input [2:0] op, output reg [7:0] res);
    always @(*) begin
        case (op)
            3'b000: res = a + b;
            3'b001: res = a - b;
            3'b010: res = b - a;
            3'b011: res = a;
            3'b100: res = b;
            3'b101: res = a * b;
            3'b110: res = (b == 8'b0) ? 8'b0 : (a / b);
            3'b111: res = (a == 8'b0) ? 8'b0 : (b / a);
        endcase
    end
endmodule
