module logic_unit #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire [2:0]       op, // Expanded to 3 bits (0-7)
    output reg [WIDTH-1:0] result
);

    always@(*) begin
        case (op)
            3'b000: result = A & B;        // AND
            3'b001: result = A | B;        // OR
            3'b010: result = A ^ B;        // XOR
            3'b011: result = ~(A ^ B);     // XNOR (Equality check)
            3'b100: result = ~(A & B);     // NAND
            3'b101: result = ~(A | B);     // NOR
            3'b110: result = ~A;           // NOT A (Unary)
            3'b111: result = A;            // PASS A (Transfer)
            default: result = 1'b0;
        endcase
    end

endmodule
