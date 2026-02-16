`timescale 1ns/1ps

module alu_tb;

parameter WIDTH = 16;

reg clk;
reg rst;
reg start;
reg [3:0] opcode;
reg [WIDTH-1:0] A;
reg [WIDTH-1:0] B;

wire [WIDTH-1:0] result;
wire [WIDTH-1:0] remainder;
wire busy;
wire done;
wire [3:0] flags;

// DUT
alu_top #(WIDTH) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .opcode(opcode),
    .A(A),
    .B(B),
    .result(result),
    .remainder(remainder),
    .busy(busy),
    .done(done),
    .flags(flags)
);

// Clock generation
always #5 clk = ~clk;

// ---------------------------------------------
// Test Procedure
// ---------------------------------------------
initial begin

    $dumpfile("wave.vcd");
    $dumpvars(0, alu_tb);

    clk = 0;
    rst = 1;
    start = 0;
    #20;
    rst = 0;

    // =============================
    // 1️⃣ ADD
    // =============================
    A = 10; B = 5; opcode = 4'b0000;
    #10;
    $display("ADD Result = %d", result);

    // =============================
    // 2️⃣ SUB
    // =============================
    A = 10; B = 3; opcode = 4'b0001;
    #10;
    $display("SUB Result = %d", result);

    // =============================
    // 3️⃣ LOGIC AND
    // =============================
    A = 8'hF0; B = 8'h0F; opcode = 4'b0100;
    #10;
    $display("LOGIC Result = %h", result);

    // =============================
    // 4️⃣ SHIFT
    // =============================
    A = 16'h0001; B = 2; opcode = 4'b1100;
    #10;
    $display("SHIFT Result = %h", result);

    // =============================
    // 5️⃣ COMPARE
    // =============================
    A = 5; B = 10; opcode = 4'b1010;
    #10;
    $display("COMPARE Result = %b", result);

    // =============================
    // 6️⃣ MULTIPLY
    // =============================
    A = 6; B = 3; opcode = 4'b1000;
    start = 1;
    @(posedge clk);
    start = 0;

    wait(done);
    #10;
    $display("MUL Result = %d", result);

    // =============================
    // 7️⃣ DIVIDE
    // =============================
    A = 13; B = 3; opcode = 4'b1001;
    start = 1;
    @(posedge clk);
    start = 0;

    wait(done);
    #10;
    $display("DIV Result = %d Remainder = %d", result, remainder);

    #50;
    $finish;
end

endmodule

