module alu(input [31:0] a, b, input [2:0] op, output reg [31:0] res);
    always @(*) begin
        case (op)
            3'b000: res = a + b;
            3'b001: res = a - b;
            3'b010: res = a & b;
            3'b011: res = a | b;
            3'b100: res = a ^ b;
            3'b101: res = ~a;
            3'b110: res = (a < b) ? 1 : 0;
            default: res = 0;
        endcase
    end
endmodule
