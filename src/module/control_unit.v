module control_unit (
    input wire clk, reset,
    input wire [3:0] opcode,
    input reg [3:0] PC,
    output reg PC_out, PC_inc, MAR_in, MEM_rd, MEM_wr, IR_in, IR_out,
    output reg A_in, B_in, ALU_out,
    output reg [2:0] ALU_op,
    output reg [5:0] state         // 5 bits — needed for values up to 31
);

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
    localparam T0       = 0,
                T1       = 1, // FETCH IR
                T2       = 2, // DECODE IR
                LDA_st1  = 3, // Load A part 1
                LDA_st2  = 4, // Load A part 2
                ADDA_st1 = 5, // Add A part 1
                ADDA_st2 = 6, // Add A part 2
                ADDA_st3 = 7, // Add A part 3 (ALU result to A)
                SUBA_st1 = 8, // SUB A part 1
                SUBA_st2 = 9, // SUB A part 2
                SUBA_st3 = 10,// SUB A part 3
                ADDAI_st1= 11,// ADD A immediate part 1
                ADDAI_st2= 12,// ADD A immediate part 2
                SUBAI_st1= 13,// SUB A immediate part 1
                SUBAI_st2= 14,// SUB A immediate part 2
                STRA_st1 = 15,// STORE A with address in IR part 1
                STRA_st2 = 16,// STORE A with address in IR part 2
                MOVAB_st = 17,// MOVE A to B
                LDB_st1  = 18,// Load B part 1
                LDB_st2  = 19,// Load B part 2
                ADDB_st1 = 20,// Add B part 1
                ADDB_st2 = 21,// Add B part 2
                ADDB_st3 = 22,// Add B part 3
                SUBB_st1 = 23,// SUB B part 1
                SUBB_st2 = 24,// SUB B part 2
                SUBB_st3 = 25,// SUB B part 3
                ADDBI_st1= 26,// ADD B immediate part 1
                ADDBI_st2= 27,// ADD B immediate part 2
                SUBBI_st1= 28,// SUB B immediate part 1
                SUBBI_st2= 29,// SUB B immediate part 2
                STRB_st1  = 30,// STORE B with address in IR part 1 
                STRB_st2 = 31, // STORE B with address in IR part 2
                MOVBA_st = 32,// MOVE B to A
                ADDAB_st = 33;// ADD A + B store to A

    // ALU opcode — matches src/module/alu.v exactly
    localparam A_add_B  = 3'b000, // res = a + b
                A_sub_B = 3'b001, // res = a - b
                B_sub_A = 3'b010, // res = b - a
                Pass_A  = 3'b011, // res = a
                Pass_B  = 3'b100, // res = b
                A_mul_B = 3'b101, // res = a * b
                A_div_B = 3'b110, // res = a / b
                B_div_A = 3'b111; // res = b / a


    /* ------- State machine ------ */
    always @(posedge clk or posedge reset) begin

        /* ------- Default signal values ----- */
        {PC_out, PC_inc, MAR_in, MEM_rd, IR_in, IR_out, A_in, B_in, ALU_out} = 0;
        {PC_in, MEM_wr} = 0;
        ALU_op = 0;

        /* ------- If reset --------- */
        if (reset) begin
            state <= T0;
            {PC_out, PC_inc, MAR_in, MEM_rd, IR_in, IR_out, A_in, B_in, ALU_out} = 0;
            {PC_in, MEM_wr} = 0;
            ALU_op = 0;
        end
        else begin
            case (state)
                /* ----- FETCH cycle ----- */
                T0: begin
                    PC_out = 1;
                    MAR_in = 1;
                    state <= T1;
                end
                T1: begin
                    PC_inc = 1;
                    MEM_rd = 1;
                    IR_in  = 1;
                    state <= T2;
                end

                T2: begin
                    case (opcode)
                        OP_LDA:   state <= LDA_st1;
                        OP_ADDA:  state <= ADDA_st1;
                        OP_SUBA:  state <= SUBA_st1;
                        OP_ADDAI: state <= ADDAI_st1;
                        OP_SUBAI: state <= SUBAI_st1;
                        OP_STRA:  state <= STRA_st1;
                        OP_MOVAB: state <= MOVAB_st;
                        OP_LDB:   state <= LDB_st1;
                        OP_ADDB:  state <= ADDB_st1;
                        OP_SUBB:  state <= SUBB_st1;
                        OP_ADDBI: state <= ADDBI_st1;
                        OP_SUBBI: state <= SUBBI_st1;
                        OP_STRB:  state <= STRB_st1;
                        OP_MOVBA: state <= MOVBA_st;
                        OP_ADDAB: state <= ADDAB_st;
                        default : state <= T0;
                    endcase
                end

                /* ------- LDA: A <- MEM[addr] ----------- */
                LDA_st1: begin
                    IR_out = 1;       // IR[3:0] (address) -> MAR
                    MAR_in = 1;
                    state <= LDA_st2;
                end

                LDA_st2: begin
                    MEM_rd = 1;       // read memory -> A
                    A_in   = 1;
                    state <= T0;
                end

                /* ------- ADDA: A <- A + MEM[addr] ------ */
                ADDA_st1: begin
                    IR_out = 1;       // address -> MAR
                    MAR_in = 1;
                    state <= ADDA_st2;
                end

                ADDA_st2: begin
                    MEM_rd = 1;       // mem value -> B
                    B_in   = 1;
                    state <= ADDA_st3;
                end

                ADDA_st3: begin
                    ALU_op  = A_add_B; // A + B -> A
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                /* ------- SUBA: A <- A - MEM[addr] ------ */
                SUBA_st1: begin
                    IR_out = 1;
                    MAR_in = 1;
                    state <= SUBA_st2;
                end

                SUBA_st2: begin
                    MEM_rd = 1;
                    B_in   = 1;
                    state <= SUBA_st3;
                end

                SUBA_st3: begin
                    ALU_op  = A_sub_B;
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                /* ------- ADDAI: A <- A + imm ------------ */
                ADDAI_st1: begin
                    IR_out = 1;       // immediate -> B
                    B_in   = 1;
                    state <= ADDAI_st2;
                end

                ADDAI_st2: begin
                    ALU_op  = A_add_B;
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                /* ------- SUBAI: A <- A - imm ------------ */
                SUBAI_st1: begin
                    IR_out = 1;
                    B_in   = 1;
                    state <= SUBAI_st2;
                end

                SUBAI_st2: begin
                    ALU_op  = A_sub_B;
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                /* ------- STRA: MEM[IR[3:0]] <- A ------- */
                STRA_st1: begin
                    IR_out = 1;       // address -> MAR
                    MAR_in = 1;
                    ALU_op = Pass_A;  // A -> bus
                    state <= STRA_st2;
                end

                /* ------- STRA: */  
                STRA_st2: begin 
                    ALU_out = 1;
                    MEM_wr = 1;
                    state <= T0;
                end

                /* ------- MOVAB: B <- A ----------------- */
                MOVAB_st: begin
                    ALU_op  = Pass_A;
                    ALU_out = 1;
                    B_in    = 1;
                    state <= T0;
                end

                /* ------- LDB: B <- MEM[addr] ----------- */
                LDB_st1: begin
                    IR_out = 1;
                    MAR_in = 1;
                    state <= LDB_st2;
                end

                LDB_st2: begin
                    MEM_rd = 1;
                    B_in   = 1;
                    state <= T0;
                end

                /* ------- ADDB: B <- B + MEM[addr] ------ */
                ADDB_st1: begin
                    IR_out = 1;
                    MAR_in = 1;
                    state <= ADDB_st2;
                end

                ADDB_st2: begin
                    MEM_rd = 1;
                    A_in   = 1;         // mem value -> A
                    state <= ADDB_st3;
                end

                ADDB_st3: begin
                    ALU_op  = A_add_B; // A (mem) + B -> B
                    ALU_out = 1;
                    B_in    = 1;
                    state <= T0;
                end

                /* ------- SUBB: B <- B - MEM[addr] ------ */
                SUBB_st1: begin
                    IR_out = 1;
                    MAR_in = 1;
                    state <= SUBB_st2;
                end

                SUBB_st2: begin
                    MEM_rd = 1;
                    A_in   = 1;         // mem value -> A
                    state <= SUBB_st3;
                end

                SUBB_st3: begin
                    ALU_op  = B_sub_A; // B - A -> B
                    ALU_out = 1;
                    B_in    = 1;
                    state <= T0;
                end

                /* ------- ADDBI: B <- B + imm ----------- */
                ADDBI_st1: begin
                    IR_out = 1;       // immediate -> A
                    A_in   = 1;
                    state <= ADDBI_st2;
                end

                ADDBI_st2: begin
                    ALU_op  = A_add_B; // A (imm) + B -> B
                    ALU_out = 1;
                    B_in    = 1;
                    state <= T0;
                end

                /* ------- SUBBI: B <- B - imm ----------- */
                SUBBI_st1: begin
                    IR_out = 1;
                    A_in   = 1;
                    state <= SUBBI_st2;
                end

                SUBBI_st2: begin
                    ALU_op  = B_sub_A; // B - A (imm) -> B
                    ALU_out = 1;
                    B_in    = 1;
                    state <= T0;
                end

                /* ------- STRB: MEM[IR[3:0]] <- B ------- */
                STRB_st1: begin
                    IR_out = 1;       // address -> MAR
                    MAR_in = 1;
                    state <= STRB_st2;
                end

                /* ------- STRB: */  
                STRB_st2: begin 
                    ALU_op = Pass_B;  // B -> bus
                    ALU_out = 1;
                    MEM_wr = 1;
                    state <= T0;
                end

                /* ------- MOVBA: A <- B ----------------- */
                MOVBA_st: begin
                    ALU_op  = Pass_B;
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                /* ------- ADDAB: A <- A + B ------------ */
                ADDAB_st: begin
                    ALU_op  = A_add_B;
                    ALU_out = 1;
                    A_in    = 1;
                    state <= T0;
                end

                default: state <= T0;
            endcase
        end
    end
endmodule
