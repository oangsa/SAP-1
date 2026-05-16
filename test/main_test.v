`timescale 1ns/1ps

module main_test;
    reg clk;
    reg reset;
    wire [7:0] bus;
    wire [7:0] A_data;
    wire [7:0] B_data;
    wire [7:0] IR_reg;
    wire [5:0] state_out;

    integer errors;
    integer i;

    main DUT (
        .clk       (clk),
        .reset     (reset),
        .bus       (bus),
        .A_data    (A_data),
        .B_data    (B_data),
        .IR_reg    (IR_reg),
        .state_out (state_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task clear_memory;
        begin
            for (i = 0; i < 16; i = i + 1)
                DUT.CPU.MEM.ram[i] = 8'h00;
        end
    endtask

    task reset_main;
        begin
            reset = 1;
            @(posedge clk); #1;
            @(posedge clk); #1;
            reset = 0;
        end
    endtask

    initial begin
        errors = 0;
        reset = 0;
        clear_memory;

        $dumpfile("main_test.vcd");
        $dumpvars(0, main_test);

        // LDR A, [3]; ADD A, [6]
        DUT.CPU.MEM.ram[0] = 8'h03;
        DUT.CPU.MEM.ram[1] = 8'h16;
        DUT.CPU.MEM.ram[3] = 8'd4;
        DUT.CPU.MEM.ram[6] = 8'd5;

        reset_main;

        repeat (12) @(posedge clk);
        #1;

        if (A_data === 8'd9)
            $display("PASS: main executes LDR A, [3]; ADD A, [6]");
        else begin
            $display("FAIL: main A=%0d expected 9", A_data);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("MAIN TEST RESULT: PASS");
        else
            $display("MAIN TEST RESULT: FAIL (%0d errors)", errors);

        $finish;
    end

    initial begin
        $monitor(
            "t=%0t | state=%0d | PC=%0d | MAR=%0d | IR=%02h | bus=%02h | A=%0d | B=%0d | PC_out=%b PC_inc=%b MAR_in=%b MEM_rd=%b IR_in=%b IR_out=%b A_in=%b B_in=%b ALU_out=%b",
            $time,
            DUT.CPU.CU.state,
            DUT.CPU.PC_val,
            DUT.CPU.MAR,
            DUT.CPU.IR,
            bus,
            A_data,
            B_data,
            DUT.CPU.CU.PC_out,
            DUT.CPU.CU.PC_inc,
            DUT.CPU.CU.MAR_in,
            DUT.CPU.CU.MEM_rd,
            DUT.CPU.CU.IR_in,
            DUT.CPU.CU.IR_out,
            DUT.CPU.CU.A_in,
            DUT.CPU.CU.B_in,
            DUT.CPU.CU.ALU_out
        );
    end
endmodule
