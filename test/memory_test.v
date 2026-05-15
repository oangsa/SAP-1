`timescale 1ns / 1ps

module tb_memory();

    reg [3:0] address;
    reg clk;
    reg MEM_wr;
    reg [7:0] data_in;
    wire [7:0] data_out;

    memory unit_under_test (
        .address(address), 
      	.clk(clk), 
        .MEM_wr(MEM_wr), 
        .data_in(data_in), 
        .data_out(data_out)
    );

    always #5 clk = ~clk; 

    initial begin
      	//For viewing on the web: EDA Playground (disabled when integrated into Vivado)
      	//$dumpfile("dump.vcd");
      	//$dumpvars(0, tb_memory);
        clk = 0;
        MEM_wr = 0;
        address = 0;
        data_in = 0;

        #10;
        
        address = 4'd3;
        #10;

        address = 4'd6;
        #10;

        address = 4'd1;
        data_in = 8'd10;
        MEM_wr = 1;      
        #10;         
        MEM_wr = 0;      

        #10;

        $finish;
    end
endmodule