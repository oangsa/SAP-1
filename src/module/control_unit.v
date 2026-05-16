module control_unit (
    input wire clk, reset,
    input wire [3:0] opcode,
    output reg PC_out, PC_in, PC_inc, MAR_in, MEM_rd, MEM_wr, IR_in, IR_out,
    output reg A_in, B_in, ALU_out,
    output reg [2:0] ALU_op,
    output reg [5:0] state
);
    reg [5:0] next_state;

    // Opcode format
    localparam OP_LDA   = 4'b0000, // load A
                OP_ADDA  = 4'b0001, // add A with value in memory
                OP_SUBA  = 4'b0010, // sub A with value in memory
                OP_ADDAI = 4'b0011, // add A with immediate value
                OP_SUBAI = 4'b0100, // sub A with immediate value
                OP_STRA  = 4'b0101, // store A to address in IR[3:0]
                OP_MOVAB = 4'b0110, // mov A to B

                OP_LDB   = 4'b1000, // load B
                OP_ADDB  = 4'b1001, // add B with value in memory
                OP_SUBB  = 4'b1010, // sub B with value in memory
                OP_ADDBI = 4'b1011, // add B with immediate value
                OP_SUBBI = 4'b1100, // sub B with immediate value
                OP_STRB  = 4'b1101, // store B to address in IR[3:0]
                OP_MOVBA = 4'b1110, // mov B to A
                OP_ADDAB = 4'b1111; // add A + B store to A

    // State definitions
    localparam [5:0] T0        = 6'd0,
                     T1        = 6'd1,  // FETCH IR
                     T2        = 6'd2,  // DECODE IR
                     LDA_st1   = 6'd3,  // Load A part 1
                     LDA_st2   = 6'd4,  // Load A part 2
                     ADDA_st1  = 6'd5,  // Add A part 1
                     ADDA_st2  = 6'd6,  // Add A part 2
                     ADDA_st3  = 6'd7,  // Add A part 3 (ALU result to A)
                     SUBA_st1  = 6'd8,  // SUB A part 1
                     SUBA_st2  = 6'd9,  // SUB A part 2
                     SUBA_st3  = 6'd10, // SUB A part 3
                     ADDAI_st1 = 6'd11, // ADD A immediate part 1
                     ADDAI_st2 = 6'd12, // ADD A immediate part 2
                     SUBAI_st1 = 6'd13, // SUB A immediate part 1
                     SUBAI_st2 = 6'd14, // SUB A immediate part 2
                     STRA_st1  = 6'd15, // STORE A with address in IR part 1
                     STRA_st2  = 6'd16, // STORE A with address in IR part 2
                     MOVAB_st  = 6'd17, // MOVE A to B
                     LDB_st1   = 6'd18, // Load B part 1
                     LDB_st2   = 6'd19, // Load B part 2
                     ADDB_st1  = 6'd20, // Add B part 1
                     ADDB_st2  = 6'd21, // Add B part 2
                     ADDB_st3  = 6'd22, // Add B part 3
                     SUBB_st1  = 6'd23, // SUB B part 1
                     SUBB_st2  = 6'd24, // SUB B part 2
                     SUBB_st3  = 6'd25, // SUB B part 3
                     ADDBI_st1 = 6'd26, // ADD B immediate part 1
                     ADDBI_st2 = 6'd27, // ADD B immediate part 2
                     SUBBI_st1 = 6'd28, // SUB B immediate part 1
                     SUBBI_st2 = 6'd29, // SUB B immediate part 2
                     STRB_st1  = 6'd30, // STORE B with address in IR part 1
                     STRB_st2  = 6'd31, // STORE B with address in IR part 2
                     MOVBA_st  = 6'd32, // MOVE B to A
                     ADDAB_st  = 6'd33; // ADD A + B store to A

    // ALU opcode — matches src/module/alu.v exactly
    localparam A_add_B  = 3'b000, // res = a + b
                A_sub_B = 3'b001, // res = a - b
                B_sub_A = 3'b010, // res = b - a
                Pass_A  = 3'b011, // res = a
                Pass_B  = 3'b100, // res = b
                A_mul_B = 3'b101, // res = a * b
                A_div_B = 3'b110, // res = a / b
                B_div_A = 3'b111; // res = b / a

    /* ------- State register ------ */
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= T0;
        else
            state <= next_state;
    end

    /* ------- Control outputs and next-state logic ------ */
    always @(*) begin
        {PC_out, PC_in, PC_inc, MAR_in, MEM_rd, MEM_wr, IR_in, IR_out} = 0;
        {A_in, B_in, ALU_out} = 0;
        ALU_op = A_add_B;
        next_state = T0;

        case (state)
            /* ----- FETCH cycle ----- */
            T0: begin
                PC_out = 1;
                MAR_in = 1;
                next_state = T1;
            end
            T1: begin
                PC_inc = 1;
                MEM_rd = 1;
                IR_in  = 1;
                next_state = T2;
            end

            T2: begin
                case (opcode)
                    OP_LDA:   next_state = LDA_st1;
                    OP_ADDA:  next_state = ADDA_st1;
                    OP_SUBA:  next_state = SUBA_st1;
                    OP_ADDAI: next_state = ADDAI_st1;
                    OP_SUBAI: next_state = SUBAI_st1;
                    OP_STRA:  next_state = STRA_st1;
                    OP_MOVAB: next_state = MOVAB_st;
                    OP_LDB:   next_state = LDB_st1;
                    OP_ADDB:  next_state = ADDB_st1;
                    OP_SUBB:  next_state = SUBB_st1;
                    OP_ADDBI: next_state = ADDBI_st1;
                    OP_SUBBI: next_state = SUBBI_st1;
                    OP_STRB:  next_state = STRB_st1;
                    OP_MOVBA: next_state = MOVBA_st;
                    OP_ADDAB: next_state = ADDAB_st;
                    default:  next_state = T0;
                endcase
            end

            /* ------- LDA: A <- MEM[addr] ----------- */
            LDA_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = LDA_st2;
            end

            LDA_st2: begin
                MEM_rd = 1;
                A_in   = 1;
                next_state = T0;
            end

            /* ------- ADDA: A <- A + MEM[addr] ------ */
            ADDA_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = ADDA_st2;
            end

            ADDA_st2: begin
                MEM_rd = 1;
                B_in   = 1;
                next_state = ADDA_st3;
            end

            ADDA_st3: begin
                ALU_op  = A_add_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            /* ------- SUBA: A <- A - MEM[addr] ------ */
            SUBA_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = SUBA_st2;
            end

            SUBA_st2: begin
                MEM_rd = 1;
                B_in   = 1;
                next_state = SUBA_st3;
            end

            SUBA_st3: begin
                ALU_op  = A_sub_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            /* ------- ADDAI: A <- A + imm ------------ */
            ADDAI_st1: begin
                IR_out = 1;
                B_in   = 1;
                next_state = ADDAI_st2;
            end

            ADDAI_st2: begin
                ALU_op  = A_add_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            /* ------- SUBAI: A <- A - imm ------------ */
            SUBAI_st1: begin
                IR_out = 1;
                B_in   = 1;
                next_state = SUBAI_st2;
            end

            SUBAI_st2: begin
                ALU_op  = A_sub_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            /* ------- STRA: MEM[IR[3:0]] <- A ------- */
            STRA_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = STRA_st2;
            end

            STRA_st2: begin
                ALU_op  = Pass_A;
                ALU_out = 1;
                MEM_wr  = 1;
                next_state = T0;
            end

            /* ------- MOVAB: B <- A ----------------- */
            MOVAB_st: begin
                ALU_op  = Pass_A;
                ALU_out = 1;
                B_in    = 1;
                next_state = T0;
            end

            /* ------- LDB: B <- MEM[addr] ----------- */
            LDB_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = LDB_st2;
            end

            LDB_st2: begin
                MEM_rd = 1;
                B_in   = 1;
                next_state = T0;
            end

            /* ------- ADDB: B <- B + MEM[addr] ------ */
            ADDB_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = ADDB_st2;
            end

            ADDB_st2: begin
                MEM_rd = 1;
                A_in   = 1;
                next_state = ADDB_st3;
            end

            ADDB_st3: begin
                ALU_op  = A_add_B;
                ALU_out = 1;
                B_in    = 1;
                next_state = T0;
            end

            /* ------- SUBB: B <- B - MEM[addr] ------ */
            SUBB_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = SUBB_st2;
            end

            SUBB_st2: begin
                MEM_rd = 1;
                A_in   = 1;
                next_state = SUBB_st3;
            end

            SUBB_st3: begin
                ALU_op  = B_sub_A;
                ALU_out = 1;
                B_in    = 1;
                next_state = T0;
            end

            /* ------- ADDBI: B <- B + imm ----------- */
            ADDBI_st1: begin
                IR_out = 1;
                A_in   = 1;
                next_state = ADDBI_st2;
            end

            ADDBI_st2: begin
                ALU_op  = A_add_B;
                ALU_out = 1;
                B_in    = 1;
                next_state = T0;
            end

            /* ------- SUBBI: B <- B - imm ----------- */
            SUBBI_st1: begin
                IR_out = 1;
                A_in   = 1;
                next_state = SUBBI_st2;
            end

            SUBBI_st2: begin
                ALU_op  = B_sub_A;
                ALU_out = 1;
                B_in    = 1;
                next_state = T0;
            end

            /* ------- STRB: MEM[IR[3:0]] <- B ------- */
            STRB_st1: begin
                IR_out = 1;
                MAR_in = 1;
                next_state = STRB_st2;
            end

            STRB_st2: begin
                ALU_op  = Pass_B;
                ALU_out = 1;
                MEM_wr  = 1;
                next_state = T0;
            end

            /* ------- MOVBA: A <- B ----------------- */
            MOVBA_st: begin
                ALU_op  = Pass_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            /* ------- ADDAB: A <- A + B ------------ */
            ADDAB_st: begin
                ALU_op  = A_add_B;
                ALU_out = 1;
                A_in    = 1;
                next_state = T0;
            end

            default: begin
                next_state = T0;
            end
        endcase
    end
endmodule
