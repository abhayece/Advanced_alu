module barrel_shifter #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] data_in,
    input  wire [$clog2(WIDTH)-1:0] shift_amt,
    input  wire [2:0] mode,
    output reg  [WIDTH-1:0] data_out
);

    integer i;
    reg [WIDTH-1:0] temp;

    always @(*) begin
        temp = data_in;

        case (mode)
            // Logical Left Shift
            3'b000: begin
                for (i = 0; i < shift_amt; i = i + 1)
                    temp = {temp[WIDTH-2:0], 1'b0};
            end

            // Logical Right Shift
            3'b001: begin
                for (i = 0; i < shift_amt; i = i + 1)
                    temp = {1'b0, temp[WIDTH-1:1]};
            end

            // Arithmetic Right Shift
            3'b010: begin
                for (i = 0; i < shift_amt; i = i + 1)
                    temp = {temp[WIDTH-1], temp[WIDTH-1:1]};
            end

            // Rotate Left
            3'b011: begin
                for (i = 0; i < shift_amt; i = i + 1)
                    temp = {temp[WIDTH-2:0], temp[WIDTH-1]};
            end

            // Rotate Right
            3'b100: begin
                for (i = 0; i < shift_amt; i = i + 1)
                    temp = {temp[0], temp[WIDTH-1:1]};
            end

            default: temp = data_in;
        endcase

        data_out = temp;
    end

endmodule
