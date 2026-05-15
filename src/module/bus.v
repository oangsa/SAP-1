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

    always @(*) begin
        if (PC_out)            bus_data = pc_data;
        else if (MEM_rd)   bus_data = mem_data;
        else if (IR_out)   bus_data = ir_data;
        else if (ALU_out)  bus_data = alu_data;
        else               bus_data = 8'bz; 
    end

endmodule