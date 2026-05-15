`timescale 1ns / 1ps

module tb_bus_system();

    reg PC_out;
    reg MEM_rd;
    reg IR_out;
    reg ALU_out;
    
    reg [7:0] pc_data;
    reg [7:0] mem_data;
    reg [7:0] ir_data;
    reg [7:0] alu_data;
    wire [7:0] bus_data;

    bus_system uut (
        .PC_out(PC_out), 
        .MEM_rd(MEM_rd), 
        .IR_out(IR_out), 
        .ALU_out(ALU_out),
        .pc_data(pc_data), 
        .mem_data(mem_data), 
        .ir_data(ir_data), 
        .alu_data(alu_data),
        .bus_data(bus_data)
    );

    initial begin
      	//For viewing on the web: EDA Playground (disabled when integrated into Vivado)
 		//$dumpfile("dump.vcd");
      	//$dumpvars(0, tb_bus_system);
        PC_out = 0; 
        MEM_rd = 0; 
        IR_out = 0; 
        ALU_out = 0;
        pc_data  = 8'h11; 
        mem_data = 8'h22; 
        ir_data  = 8'h33; 
        alu_data = 8'h44; 
        
        #10; 
        PC_out = 1;
        #10; 
        PC_out = 0;
        
        #10; 
        MEM_rd = 1;
        #10; 
        MEM_rd = 0;
        
      	#10;
        IR_out = 1;
        #10;
        IR_out = 0;
      
        #10;
        ALU_out = 1;
        #10; 
        ALU_out = 0;
      
     
      	#10;
        
        $finish; 
    end
endmodule