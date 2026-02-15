module flag_generator #(
    parameter WIDTH = 16
)(
    input  wire [WIDTH-1:0] result,
    input  wire             carry,
    input  wire             overflow,
    output wire             Z,
    output wire             N,
    output wire             C,
    output wire             V
);

    assign Z = (result == 0);
    assign N = result[WIDTH-1];
    assign C = carry;
    assign V = overflow;

endmodule
