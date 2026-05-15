module memory(
    input [3:0] address,   
    input clk,                  
    input MEM_wr,          
    input [7:0] data_in,      
    output [7:0] data_out      
);
  reg [7:0] ram [15:0]; 

    initial begin
        integer i;
      for (i = 0; i < 16; i = i + 1) ram[i] = 8'h00; 
        ram[3] = 8'd4; 
        ram[6] = 8'd5; 
    end

  always @(posedge clk) begin
        if (MEM_wr)
            ram[address] <= data_in;
    end

    assign data_out = ram[address];

endmodule