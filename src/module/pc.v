module pc(
    input wire clk,
    input wire reset,
    input wire load,
    input wire increment,
    input wire [7:0] bus_in,
    output reg [3:0] pc_out
);
    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 4'h0;
        end else if (load) begin
            pc_out <= bus_in[3:0];
        end else if (increment) begin
            pc_out <= pc_out + 4'h1;
        end
    end
endmodule
