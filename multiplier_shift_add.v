module multiplier_shift_add #(
    parameter WIDTH = 16
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    output reg  [WIDTH-1:0] product,
    output reg              busy,
    output reg              done
);

    reg [WIDTH-1:0] multiplicand;
    reg [WIDTH-1:0] multiplier;
    reg [2*WIDTH-1:0] acc;
    reg [$clog2(WIDTH):0] count;

    always @(posedge clk) begin
        if (rst) begin
            multiplicand <= 0;
            multiplier   <= 0;
            acc          <= 0;
            count        <= 0;
            busy         <= 0;
            done         <= 0;
            product      <= 0;
        end
        else if (start && !busy) begin
            multiplicand <= A;
            multiplier   <= B;
            acc          <= 0;
            count        <= 0;
            busy         <= 1;
            done         <= 0;
        end
        else if (busy) begin
            if (multiplier[0])
                acc <= acc + multiplicand;

            multiplicand <= multiplicand << 1;
            multiplier   <= multiplier >> 1;
            count        <= count + 1;

            if (count == WIDTH-1) begin
                busy    <= 0;
                done    <= 1;
                product <= acc[WIDTH-1:0];
            end
        end
        else begin
            done <= 0;
        end
    end

endmodule
