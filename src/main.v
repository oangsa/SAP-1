// =============================================================
//  main.v - Project top-level wrapper
//
//  The CPU module contains the full SAP-1 datapath. This wrapper
//  gives synthesis/simulation flows a simple top module named
//  `main` while keeping the CPU integration in src/module/cpu.v.
// =============================================================

module main (
    input  wire       clk,
    input  wire       reset,
    output wire [7:0] bus,
    output wire [7:0] A_data,
    output wire [7:0] B_data,
    output wire [7:0] IR_reg,
    output wire [5:0] state_out
);

    cpu CPU (
        .clk       (clk),
        .reset     (reset),
        .bus       (bus),
        .A_data    (A_data),
        .B_data    (B_data),
        .IR_reg    (IR_reg),
        .state_out (state_out)
    );

endmodule
