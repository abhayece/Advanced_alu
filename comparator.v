 module comparator #(
     parameter WIDTH = 16
 )(
     input  wire [WIDTH-1:0] A,
     input  wire [WIDTH-1:0] B,
     input  wire             signed_mode,
     output reg  [2:0]       cmp // [2]=LT, [1]=GT, [0]=EQ
 );

     // Internal wires to hold comparison results
     wire is_eq, is_gt, is_lt;

     // Determine results based on mode using ternary operators
     // This removes the need for duplicated if-else blocks
     assign is_eq = signed_mode ? ($signed(A) == $signed(B)) : (A == B);
     assign is_gt = signed_mode ? ($signed(A) >  $signed(B)) : (A >  B);
     assign is_lt = signed_mode ? ($signed(A) <  $signed(B)) : (A <  B);

     // Combine individual bits into the 3-bit output vector
     // This is much faster to read than 6 different if-else assignments
     always @(*) begin
         cmp = {is_lt, is_gt, is_eq};
     end

 endmodule	
