module divider_restoring #(
    parameter WIDTH = 16
)(
    input  wire             clk,
    input  wire             rst,
    input  wire             start,
    input  wire [WIDTH-1:0] A,   // dividend
    input  wire [WIDTH-1:0] B,   // divisor
    output reg  [WIDTH-1:0] quotient,
    output reg  [WIDTH-1:0] remainder,
    output reg              busy,
    output reg              done
);

    reg [WIDTH-1:0] divisor;
    reg [WIDTH:0]   rem;
    reg [$clog2(WIDTH):0] count;

    always @(posedge clk) begin
        if (rst) begin
            quotient  <= 0;
            remainder <= 0;
            divisor   <= 0;
            rem       <= 0;
            count     <= 0;
            busy      <= 0;
            done      <= 0;
        end
        else if (start && !busy) begin
            quotient  <= A;
            divisor   <= B;
            rem       <= 0;
            count     <= WIDTH;
            busy      <= 1;
            done      <= 0;
        end
        else if (busy) begin
            rem = {rem[WIDTH-1:0], quotient[WIDTH-1]};
            quotient = quotient << 1;
            rem = rem - divisor;

            if (rem[WIDTH]) begin
                rem = rem + divisor;
                quotient[0] = 0;
            end
            else begin
                quotient[0] = 1;
            end

            count = count - 1;

            if (count == 1) begin
                remainder <= rem[WIDTH-1:0];
                busy <= 0;
                done <= 1;
            end
        end
        else begin
            done <= 0;
        end
    end

endmodule
