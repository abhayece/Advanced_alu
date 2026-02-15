module alu_top #(
    parameter WIDTH = 16
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              start,
    input  wire [3:0]        opcode,
    input  wire [WIDTH-1:0]  A,
    input  wire [WIDTH-1:0]  B,

    output reg  [WIDTH-1:0]  result,
    output wire [WIDTH-1:0]  remainder,
    output wire              busy,
    output wire              done,
    output wire [3:0]        flags
);

    // ------------------------------------------------------------------
    // Internal Wires
    // ------------------------------------------------------------------
    wire [WIDTH-1:0] arith_res, logic_res, shift_res;
    wire [WIDTH-1:0] mul_res, div_res;
    wire [2:0]       comp_res;          // {LT, GT, EQ}
    wire             arith_c, arith_v;
    wire             mul_busy, mul_done;
    wire             div_busy, div_done;

    // ------------------------------------------------------------------
    // Arithmetic Unit
    // ------------------------------------------------------------------
    adder_subtractor #(WIDTH) u_arith (
        .A(A),
        .B(B),
        .op(opcode[1:0]),        // 00 ADD, 01 SUB, 10 INC, 11 DEC
        .result(arith_res),
        .carry(arith_c),
        .overflow(arith_v)
    );

    // ------------------------------------------------------------------
    // Logic Unit
    // ------------------------------------------------------------------
    logic_unit #(WIDTH) u_logic (
        .A(A),
        .B(B),
        .op(opcode[2:0]),
        .result(logic_res)
    );

    // ------------------------------------------------------------------
    // Barrel Shifter
    // ------------------------------------------------------------------
    barrel_shifter #(WIDTH) u_shift (
        .data_in(A),
        .shift_amt(B[$clog2(WIDTH)-1:0]),
        .mode(opcode[2:0]),
        .data_out(shift_res)
    );

    // ------------------------------------------------------------------
    // Multiplier (Sequential)
    // ------------------------------------------------------------------
    multiplier_shift_add #(WIDTH) u_mul (
        .clk(clk),
        .rst(rst),
        .start(start && (opcode == 4'b1000)),
        .A(A),
        .B(B),
        .product(mul_res),
        .busy(mul_busy),
        .done(mul_done)
    );

    // ------------------------------------------------------------------
    // Divider (Sequential)
    // ------------------------------------------------------------------
    divider_restoring #(WIDTH) u_div (
        .clk(clk),
        .rst(rst),
        .start(start && (opcode == 4'b1001)),
        .A(A),
        .B(B),
        .quotient(div_res),
        .remainder(remainder),
        .busy(div_busy),
        .done(div_done)
    );

    // ------------------------------------------------------------------
    // Comparator
    // ------------------------------------------------------------------
    comparator #(WIDTH) u_comp (
        .A(A),
        .B(B),
        .signed_mode(opcode[0]),     // 0 = unsigned, 1 = signed
        .cmp(comp_res)               // {LT, GT, EQ}
    );

    // ------------------------------------------------------------------
    // Output Multiplexer
    // ------------------------------------------------------------------
    always @(*) begin
        result = {WIDTH{1'b0}};
        case (opcode)

            // Arithmetic
            4'b0000, 4'b0001,
            4'b0010, 4'b0011:
                result = arith_res;

            // Logic
            4'b0100, 4'b0101,
            4'b0110, 4'b0111:
                result = logic_res;

            // Multiply (valid only when done)
            4'b1000:
                result = mul_done ? mul_res : {WIDTH{1'b0}};

            // Divide (valid only when done)
            4'b1001:
                result = div_done ? div_res : {WIDTH{1'b0}};

            // Compare
            4'b1010, 4'b1011:
                result = {{WIDTH-3{1'b0}}, comp_res};

            // Shift (LSL, LSR only)
            4'b1100, 4'b1101:
                result = shift_res;

            default:
                result = A;
        endcase
    end

    // ------------------------------------------------------------------
    // Status Signals
    // ------------------------------------------------------------------
    assign busy = mul_busy | div_busy;

    assign done = (opcode == 4'b1000) ? mul_done :
                  (opcode == 4'b1001) ? div_done :
                  start;   // single-cycle ops

    // ------------------------------------------------------------------
    // Flags
    // ------------------------------------------------------------------
    wire is_arith = (opcode[3:2] == 2'b00);

    flag_generator #(WIDTH) u_flags (
        .result(result),
        .carry(is_arith ? arith_c : 1'b0),
        .overflow(is_arith ? arith_v : 1'b0),
        .Z(flags[3]),
        .N(flags[2]),
        .C(flags[1]),
        .V(flags[0])
    );

endmodule
