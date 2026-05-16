module reg_A (
    input  wire       clk,
    input  wire       reset,
    input  wire       A_in,       // load enable  (from Control Unit)
    input  wire [7:0] bus,        // 8-bit shared bus
    output reg  [7:0] A_data      // current value of A (always visible)
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            A_data <= 8'b0;
        else if (A_in)
            A_data <= bus;        // capture whatever is on the bus
    end
endmodule
 
 
module reg_B (
    input  wire       clk,
    input  wire       reset,
    input  wire       B_in,       // load enable  (from Control Unit)
    input  wire [7:0] bus,        // 8-bit shared bus
    output reg  [7:0] B_data      // current value of B (always visible)
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            B_data <= 8'b0;
        else if (B_in)
            B_data <= bus;        // capture whatever is on the bus
    end
endmodule