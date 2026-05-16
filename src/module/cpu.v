// =============================================================
//  cpu.v  –  Top-level module (SAP-1)
//
//  Instantiates and wires:
//    control_unit, pc, alu, bus_system, memory, reg_A, reg_B
//
//  Internal registers handled here:
//    • MAR (memory address register)
//    • IR  (instruction register)
// =============================================================
 
module cpu (
    input  wire       clk,
    input  wire       reset,
    // Optional debug outputs so you can probe in simulation
    output wire [7:0] bus,
    output wire [7:0] A_data,
    output wire [7:0] B_data,
    output wire [7:0] IR_reg,
    output wire [5:0] state_out
);
 
    // -------------------------------------------------------
    //  Control signals (from Control Unit)
    // -------------------------------------------------------
    wire PC_out, PC_in, PC_inc;
    wire MAR_in;
    wire MEM_rd, MEM_wr;
    wire IR_in,  IR_out;
    wire A_in,   B_in;
    wire ALU_out;
    wire [2:0] ALU_op;
 
    // -------------------------------------------------------
    //  Internal registers: MAR and IR
    // -------------------------------------------------------
    reg [3:0] MAR;   // only needs 4 bits (16-byte address space)
    reg [7:0] IR;    // full 8-bit instruction word
 
    // MAR: latch lower 4 bits of bus when MAR_in is asserted
    always @(posedge clk or posedge reset) begin
        if (reset)
            MAR <= 4'b0;
        else if (MAR_in)
            MAR <= bus[3:0];
    end
 
    // IR: latch full bus when IR_in is asserted
    always @(posedge clk or posedge reset) begin
        if (reset)
            IR <= 8'b0;
        else if (IR_in)
            IR <= bus;
    end
 
    assign IR_reg = IR;   // expose for debug
 
    // -------------------------------------------------------
    //  Program Counter
    // -------------------------------------------------------
    wire [3:0] PC_val;

    pc PC (
        .clk       (clk),
        .reset     (reset),
        .load      (PC_in),
        .increment (PC_inc),
        .bus_in    (bus),
        .pc_out    (PC_val)
    );
 
    // -------------------------------------------------------
    //  Data wires between modules
    // -------------------------------------------------------
    wire [7:0] mem_data_out;
    wire [7:0] alu_result;
    wire [7:0] A_wire, B_wire;
 
    // IR lower 4 bits zero-extended → bus when IR_out is asserted
    // (used as address or immediate value)
    wire [7:0] ir_bus_data = {4'b0000, IR[3:0]};
 
    // -------------------------------------------------------
    //  Bus
    // -------------------------------------------------------
    bus_system BUS (
        .PC_out   (PC_out),
        .MEM_rd   (MEM_rd),
        .IR_out   (IR_out),
        .ALU_out  (ALU_out),
        .pc_data  ({4'b0000, PC_val}),
        .mem_data (mem_data_out),
        .ir_data  (ir_bus_data),
        .alu_data (alu_result),
        .bus_data (bus)
    );
 
    // -------------------------------------------------------
    //  Memory
    // -------------------------------------------------------
    memory MEM (
        .address  (MAR),
        .clk      (clk),
        .MEM_wr   (MEM_wr),
        .MEM_rd   (MEM_rd),
        .data_in  (bus),
        .data_out (mem_data_out)
    );
 
    // -------------------------------------------------------
    //  ALU
    //    alu.v now uses the same opcode encoding as control_unit.v,
    //    so the control signal can be wired through directly.
    // -------------------------------------------------------
 
    alu ALU (
        .a   (A_wire),
        .b   (B_wire),
        .op  (ALU_op),
        .res (alu_result)
    );
 
    // -------------------------------------------------------
    //  Registers A and B
    // -------------------------------------------------------
    reg_A REGA (
        .clk    (clk),
        .reset  (reset),
        .A_in   (A_in),
        .bus    (bus),
        .A_data (A_wire)
    );
 
    reg_B REGB (
        .clk    (clk),
        .reset  (reset),
        .B_in   (B_in),
        .bus    (bus),
        .B_data (B_wire)
    );
 
    assign A_data = A_wire;
    assign B_data = B_wire;
 
    // -------------------------------------------------------
    //  Control Unit
    // -------------------------------------------------------
    control_unit CU (
        .clk     (clk),
        .reset   (reset),
        .opcode  (IR[7:4]),    // upper nibble of IR
        .PC_out  (PC_out),
        .PC_in   (PC_in),
        .PC_inc  (PC_inc),
        .MAR_in  (MAR_in),
        .MEM_rd  (MEM_rd),
        .MEM_wr  (MEM_wr),
        .IR_in   (IR_in),
        .IR_out  (IR_out),
        .A_in    (A_in),
        .B_in    (B_in),
        .ALU_out (ALU_out),
        .ALU_op  (ALU_op),
        .state   (state_out)
    );
 
endmodule
