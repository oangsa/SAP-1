module memory(
    input [3:0] address,   
    input clk,                  
    input MEM_wr,   
    input MEM_rd,       
    input [7:0] data_in,      
    output [7:0] data_out      
);
  reg [7:0] ram [15:0]; 

    initial begin
        integer i;
        for (i = 0; i < 16; i = i + 1)
            ram[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (MEM_wr)
            ram[address] <= data_in;
    end

    assign data_out = (MEM_rd) ? ram[address] : 8'hzz;
endmodule
