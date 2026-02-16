module barrel_shifter #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] data_in,
    input  wire [$clog2(WIDTH)-1:0] shift_amt,
    input  wire [2:0] mode,
    output reg  [WIDTH-1:0] data_out
);

always @(*) begin
    case (mode)

        // Logical Left Shift
        3'b000:
            data_out = data_in << shift_amt;

        // Logical Right Shift
        3'b001:
            data_out = data_in >> shift_amt;

        // Arithmetic Right Shift
        3'b010:
            data_out = $signed(data_in) >>> shift_amt;

        // Rotate Left
        3'b011:
            data_out = (data_in << shift_amt) |
                       (data_in >> (WIDTH - shift_amt));

        // Rotate Right
        3'b100:
            data_out = (data_in >> shift_amt) |
                       (data_in << (WIDTH - shift_amt));

        default:
            data_out = data_in;

    endcase
end

endmodule

