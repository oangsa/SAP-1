// =============================================================
//  tb_cpu.v  –  Testbench for SAP-1 top-level cpu module
//
//  Tests ARM-like memory instructions:
//    1. LDR A, [3]; ADD A, [6] -> A should become 9  (4 + 5)
//    2. LDR A, [4]; ADD A, [5] -> A should become 19 (7 + 12)
// =============================================================

`timescale 1ns/1ps

module tb_cpu;

    reg  clk, reset;
    wire [7:0] bus;
    wire [7:0] A_data, B_data, IR_reg;
    wire [5:0] state_out;

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

    integer i;
    integer errors;

    task clear_memory;
        begin
            for (i = 0; i < 16; i = i + 1)
                DUT.MEM.ram[i] = 8'h00;
        end
    endtask

    task reset_cpu;
        begin
            reset = 1;
            @(posedge clk); #1;
            @(posedge clk); #1;
            reset = 0;
        end
    endtask

    task run_ldr_add_case;
        input [511:0] name;
        input [3:0] load_addr;
        input [7:0] load_value;
        input [3:0] add_addr;
        input [7:0] add_value;
        input [7:0] expected;
        begin
            clear_memory;

            // Local ISA encoding:
            //   LDR A, [addr] == LDA addr  == 0000_addr
            //   ADD A, [addr] == ADDA addr == 0001_addr
            DUT.MEM.ram[0] = {4'h0, load_addr};
            DUT.MEM.ram[1] = {4'h1, add_addr};
            DUT.MEM.ram[load_addr] = load_value;
            DUT.MEM.ram[add_addr] = add_value;

            reset_cpu;

            // Run through LDA and ADDA, then check before data bytes are fetched as instructions.
            repeat (12) @(posedge clk);
            #1;

            $display("=== %0s ===", name);
            $display("LDR A, [%0d] = %0d; ADD A, [%0d] = %0d", load_addr, load_value, add_addr, add_value);
            $display("A register = %0d (expected %0d)", A_data, expected);

            if (A_data === expected)
                $display("PASS: %0s", name);
            else begin
                $display("FAIL: %0s", name);
                errors = errors + 1;
            end
        end
    endtask

    // ---- Stimulus ----
    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);

        reset = 0;
        errors = 0;

        run_ldr_add_case("ARM example: LDR A, [3]; ADD A, [6]",
                         4'd3, 8'd4,
                         4'd6, 8'd5,
                         8'd9);

        run_ldr_add_case("Second case: LDR A, [4]; ADD A, [5]",
                         4'd4, 8'd7,
                         4'd5, 8'd12,
                         8'd19);

        if (errors == 0)
            $display("CPU LDR/ADD TEST RESULT: PASS");
        else
            $display("CPU LDR/ADD TEST RESULT: FAIL (%0d errors)", errors);

        $finish;
    end

    // ---- Monitor every clock edge ----
    initial begin
        $monitor("t=%0t | state=%0d | bus=%02h | A=%0d | B=%0d | IR=%02h",
                  $time, state_out, bus, A_data, B_data, IR_reg);
    end

endmodule
