`timescale 1ns/1ps

module pc_test;
    reg clk;
    reg reset;
    reg load;
    reg increment;
    reg [7:0] bus_in;
    wire [3:0] pc_out;

    integer errors;

    pc dut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .increment(increment),
        .bus_in(bus_in),
        .pc_out(pc_out)
    );

    always #5 clk = ~clk;

    task check_pc;
        input [3:0] exp;
        input [255:0] msg;
        begin
            #1;
            if (pc_out !== exp) begin
                $display("FAIL: %0s | exp=%h got=%h", msg, exp, pc_out);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s", msg);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 0;
        load = 0;
        increment = 0;
        bus_in = 8'h00;
        errors = 0;

        reset = 1;
        @(posedge clk);
        check_pc(4'h0, "reset clears PC");

        reset = 0;
        increment = 1;
        @(posedge clk);
        check_pc(4'h1, "increment advances PC");

        increment = 0;
        @(posedge clk);
        check_pc(4'h1, "PC holds when controls are inactive");

        bus_in = 8'hAB;
        load = 1;
        @(posedge clk);
        check_pc(4'hB, "load takes lower nibble from bus");

        increment = 1;
        bus_in = 8'h04;
        @(posedge clk);
        check_pc(4'h4, "load has priority over increment");

        increment = 0;
        bus_in = 8'h0F;
        @(posedge clk);
        check_pc(4'hF, "load can set PC to F");

        load = 0;
        increment = 1;
        @(posedge clk);
        check_pc(4'h0, "increment wraps from F to 0");

        if (errors == 0) begin
            $display("PC TEST RESULT: PASS");
        end else begin
            $display("PC TEST RESULT: FAIL (%0d errors)", errors);
        end

        $finish;
    end
endmodule
