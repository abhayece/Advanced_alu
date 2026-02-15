module adder_subtractor #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [1:0]       op,       // 00=ADD, 01=SUB, 10=INC, 11=DEC
    output wire [WIDTH-1:0] result,
    output wire              carry,
    output wire              overflow
);

    wire [WIDTH-1:0] B_int;
    wire             cin;

    // Optimized Operand Selection logic
    // Now INC/DEC ignore the external B input entirely
    assign B_int = (op == 2'b01) ? ~B :             // SUB: use 1's complement
                   (op == 2'b10) ? {WIDTH{1'b0}} :  // INC: force B to 0
                   (op == 2'b11) ? {WIDTH{1'b1}} :  // DEC: use -1 (all 1s)
                   B;                               // ADD: use B

    // Carry-in logic: 1 for SUB/INC, 0 for ADD/DEC
    // SUB: A + ~B + 1 = A - B
    // INC: A + 0 + 1  = A + 1
    // DEC: A + (-1) + 0 = A - 1
    assign cin = (op == 2'b01 || op == 2'b10);

    // Optimized Arithmetic using LHS Concatenation
    // Automatically handles the (WIDTH+1) math and extracts carry
    assign {carry, result} = A + B_int + cin;

    // Signed Overflow Detection
    // Logic: Inputs have same sign, but result sign differs
    assign overflow = (A[WIDTH-1] == B_int[WIDTH-1]) && (result[WIDTH-1] != A[WIDTH-1]);

endmodule

