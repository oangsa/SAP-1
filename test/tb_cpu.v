// =============================================================
//  tb_cpu.v  –  Testbench for SAP-1 top-level cpu module
//
//  Tests:
//    1. LDA 3   → A should become 4  (ram[3]=4)
//    2. ADD 6   → A should become 9  (ram[6]=5, 4+5=9)
// =============================================================

`timescale 1ns/1ps

module tb_cpu;

    reg  clk, reset;
    wire [7:0] bus;
    wire [7:0] A_data, B_data, IR_reg;
    wire [3:0] state_out;

    // Instantiate DUT
    cpu DUT (
        .clk      (clk),
        .reset    (reset),
        .bus      (bus),
        .A_data   (A_data),
        .B_data   (B_data),
        .IR_reg   (IR_reg),
        .state_out(state_out)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Load test program into memory ----
    // Instruction encoding:
    //   LDA  addr  = opcode 0000 | addr[3:0]  → 8'h03  (LDA  address 3)
    //   ADDA addr  = opcode 0001 | addr[3:0]  → 8'h16  (ADDA address 6)
    initial begin
        // Pre-load instructions directly into memory module
        // ram[0] = LDA 3  = 0000_0011 = 8'h03
        // ram[4] = ADD 6  = 0001_0110 = 8'h16
        // (PC increments by 4 each fetch)
        DUT.MEM.ram[0] = 8'h03;   // LDA  3
        DUT.MEM.ram[4] = 8'h16;   // ADDA 6
        // Data (already set in memory.v initial block, but set again for safety)
        DUT.MEM.ram[3] = 8'd4;
        DUT.MEM.ram[6] = 8'd5;
    end

    // ---- Stimulus ----
    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);

        // Reset for 2 cycles
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        // Run for enough cycles to complete both instructions
        // Each instruction takes ~3-4 clock cycles; give 40 cycles total
        repeat (40) @(posedge clk);

        // ---- Check results ----
        $display("=== SAP-1 Simulation Results ===");
        $display("A register = %0d (expected 9)", A_data);
        $display("B register = %0d", B_data);
        if (A_data === 8'd9)
            $display("PASS: LDA 3 + ADD 6 => A = 9");
        else
            $display("FAIL: A = %0d (expected 9)", A_data);

        $finish;
    end

    // ---- Monitor every clock edge ----
    initial begin
        $monitor("t=%0t | state=%0d | bus=%02h | A=%0d | B=%0d | IR=%02h",
                  $time, state_out, bus, A_data, B_data, IR_reg);
    end

endmodule