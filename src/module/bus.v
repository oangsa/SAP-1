module bus_system(
    input PC_out,
    input MEM_rd,
    input IR_out,
    input ALU_out,
  
    input [7:0] pc_data,
    input [7:0] mem_data,
    input [7:0] ir_data,
    input [7:0] alu_data,
    
    output reg [7:0] bus_data
);
    wire [2:0] enable_count;
  	assign enable_count = PC_out + MEM_rd + IR_out + ALU_out;
    always @(*) begin
        if (enable_count > 1) begin bus_data = 8'hxx;
      end
        else if (PC_out)            bus_data = pc_data;
        else if (MEM_rd)            bus_data = mem_data;
        else if (IR_out)            bus_data = ir_data;
        else if (ALU_out)           bus_data = alu_data;
        else                        bus_data = 8'bz; 
    end

endmodule