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
endmodule
