`timescale 1ns / 1ps

module tb_memory();

    reg [3:0] address;
    reg clk;
    reg MEM_wr;
    reg MEM_rd;
    reg [7:0] data_in;
    wire [7:0] data_out;

    memory unit_under_test (
        .address(address), 
      	.clk(clk), 
        .MEM_wr(MEM_wr), 
        .MEM_rd(MEM_rd),
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
        MEM_rd = 0;
        address = 0;
        data_in = 0;
	        
        #10;

        address = 4'd3;
        data_in = 8'd4;
        MEM_wr = 1;
        #10;
        MEM_wr = 0;
        #10;
        MEM_rd = 1; 
        #10;
        if (data_out === 8'd4) $display("PASS: Address 3 is 4");
        else $display("ERROR: Address 3 is %d (Expected 4)", data_out);
        MEM_rd = 0;
        #10;

        address = 4'd6;
        data_in = 8'd5;
        MEM_wr = 1;
        #10;
        MEM_wr = 0;
        #10;
        MEM_rd = 1; 
        #10;
        if (data_out === 8'd5) $display("PASS: Address 6 is 5");
        else $display("ERROR: Address 6 is %d (Expected 5)", data_out);
        MEM_rd = 0;
        #10;

        address = 4'd1;
        data_in = 8'd10;
        MEM_wr = 1;      
        #10;         
        MEM_wr = 0;
        #10;         
        MEM_rd = 1;       
        #10;
        if (data_out === 8'd10) $display("PASS: Write/Read Address 1 Success");
        else $display("ERROR: Write/Read Failed");
        MEM_rd = 0; 
      	#10;

        $display("--- Memory Verification Completed ---");
        $finish;
    end
endmodule
