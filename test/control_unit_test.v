`timescale 1ns / 1ps

// =============================================================
// Simple testbench for control_unit
// Tests opcode decode by verifying state transitions.
//
// Timing model:
//   The control unit uses a single always @(posedge clk) block.
//   Outputs are blocking (=), state is non-blocking (<=).
//   After posedge: state = next state, outputs = old state's controls.
// =============================================================

module control_unit_test;

    reg         clk, reset;
    reg  [3:0]  opcode;
    wire        PC_out, PC_in, PC_inc, MAR_in, MEM_rd, MEM_wr, IR_in, IR_out;
    wire        A_in, B_in, ALU_out;
    wire [2:0]  ALU_op;
    wire [3:0]  state;

    control_unit uut (
        .clk    (clk),
        .reset  (reset),
        .opcode (opcode),
        .PC_out (PC_out),
        .PC_in  (PC_in),
        .PC_inc (PC_inc),
        .MAR_in (MAR_in),
        .MEM_rd (MEM_rd),
        .MEM_wr (MEM_wr),
        .IR_in  (IR_in),
        .IR_out (IR_out),
        .A_in   (A_in),
        .B_in   (B_in),
        .ALU_out(ALU_out),
        .ALU_op (ALU_op),
        .state  (state)
    );

    always #10 clk = ~clk;

    // Wait for posedge, then #1 to settle comb outputs
    task tick;
        @(posedge clk);
        #1;
    endtask

    // Set opcode at negedge (stable before next posedge)
    task set_op(input [3:0] val);
        @(negedge clk);
        opcode = val;
        #1;  // small delay for monitor
    endtask

    // Wait until state matches a value
    task wait_state(input [3:0] expected);
        while (state !== expected) tick;
    endtask

    integer pass, fail;

    task test_op;
        input [3:0]  op_val;
        input [3:0]  expected_state;
        input [5*8]   name;
        begin
            @(negedge clk);
            opcode = op_val;
            tick;   // T2 should decode to expected state
            if (state === expected_state) begin
                $display("  PASS: opcode=%b -> state=%d (%s)", op_val, state, name);
                pass = pass + 1;
            end else begin
                $error("FAIL: opcode=%b -> state=%d (expected %d) (%s)", op_val, state, expected_state, name);
                fail = fail + 1;
            end
        end
    endtask

    initial begin
        clk    = 0;
        reset  = 0;
        opcode = 4'b0;
        pass   = 0;
        fail   = 0;

        $display("==============================================");
        $display("  CONTROL UNIT - SIMPLE DECODE TEST");
        $display("==============================================");
        $display("  State encoding:");
        $display("    T0=0 T1=1 T2=2");
        $display("    LDA_st1=4 LDA_st2=5");
        $display("    ADDA_st1=6 ADDA_st2=7 ADDA_st3=8");
        $display("    SUBA_st1=9 SUBA_st2=10 SUBA_st3=11");
        $display("    ADDAI_st1=12 ADDAI_st2=13");
        $display("    SUBAI_st1=14 SUBAI_st2=15");
        $display("    STRA_st=16");
        $display("    MOVAB_st=17");
        $display("    LDB_st1=18 LDB_st2=19");
        $display("    ADDB_st1=20 ADDB_st2=21 ADDB_st3=22");
        $display("    SUBB_st1=23 SUBB_st2=24 SUBB_st3=25");
        $display("    ADDBI_st1=26 ADDBI_st2=27");
        $display("    SUBBI_st1=28 SUBBI_st2=29");
        $display("    STRB_st=30");
        $display("    MOVBA_st=31");
        $display("==============================================\n");

        // ---- Reset ----
        @(negedge clk);
        reset = 1;
        tick;
        reset = 0;
        $display("After reset: state=%d\n", state);

        // ---- Run through T0->T1->T2 three times to test all opcodes ----
        // Each opcode test needs: T0->T1->T2, then decode.
        // We'll do a fetch cycle between tests: 3 ticks (T0, T1, T2)

        // ====== LDA = 0000 ======
        tick; tick;          // T0->T1->T2
        test_op(4'b0000, 4, "LDA");     // -> LDA_st1 (4)

        // ====== ADDA = 0001 ======
        tick; tick; tick;    // LDA_st1->LDA_st2->T0->T1... actually go back to T2
        wait_state(2);       // wait until T2
        test_op(4'b0001, 6, "ADDA");    // -> ADDA_st1 (6)

        // ====== SUBA = 0010 ======
        wait_state(2);
        test_op(4'b0010, 9, "SUBA");    // -> SUBA_st1 (9)

        // ====== ADDAI = 0011 ======
        wait_state(2);
        test_op(4'b0011, 12, "ADDAI");  // -> ADDAI_st1 (12)

        // ====== SUBAI = 0100 ======
        wait_state(2);
        test_op(4'b0100, 14, "SUBAI");  // -> SUBAI_st1 (14)

        // ====== STRA = 0101 ======
        wait_state(2);
        test_op(4'b0101, 16, "STRA");   // -> STRA_st (16)

        // ====== MOVAB = 0110 ======
        wait_state(2);
        test_op(4'b0110, 17, "MOVAB");  // -> MOVAB_st (17)

        // ====== LDB = 1000 ======
        wait_state(2);
        test_op(4'b1000, 18, "LDB");    // -> LDB_st1 (18)

        // ====== ADDB = 1001 ======
        wait_state(2);
        test_op(4'b1001, 20, "ADDB");   // -> ADDB_st1 (20)

        // ====== SUBB = 1010 ======
        wait_state(2);
        test_op(4'b1010, 23, "SUBB");   // -> SUBB_st1 (23)

        // ====== ADDBI = 1011 ======
        wait_state(2);
        test_op(4'b1011, 26, "ADDBI");  // -> ADDBI_st1 (26)

        // ====== SUBBI = 1100 ======
        wait_state(2);
        test_op(4'b1100, 28, "SUBBI");  // -> SUBBI_st1 (28)

        // ====== STRB = 1101 ======
        wait_state(2);
        test_op(4'b1101, 30, "STRB");   // -> STRB_st (30)

        // ====== MOVBA = 1110 ======
        wait_state(2);
        test_op(4'b1110, 31, "MOVBA");  // -> MOVBA_st (31)

        // ====== Default = 0111 ======
        wait_state(2);
        test_op(4'b0111, 0, "DEFAULT"); // -> T0 (0)

        // ====== Results ======
        $display("\n==============================================");
        $display("  RESULTS: %0d PASS, %0d FAIL", pass, fail);
        $display("==============================================");
        $stop;
    end

    initial begin
        $display("time\tclk rst op st PC_out PC_inc MAR_in MEM_rd MEM_wr IR_in IR_out A_in B_in ALU_out ALU_op");
        $monitor("%0t\t%b %b %b %d %b %b %b %b %b %b %b %b %b %b %b",
                 $time, clk, reset, opcode, state,
                 PC_out, PC_inc, MAR_in, MEM_rd, MEM_wr,
                 IR_in, IR_out, A_in, B_in, ALU_out, ALU_op);
    end

endmodule
