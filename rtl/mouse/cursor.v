module cursor (
   input    wire        clk,
   input    wire  [3:0] x,
   input    wire  [3:0] y,
   output   reg   [1:0] data
) ; 

/*
   00 :  blank or background 
   01 :  contour of cursor. Draw it in solid line. 
   10 :  inside of cursor. Draw it in solid point, background or transparent color.
   11 :  reserved.
*/


   reg   [0:16*2-1]  row_data ; 

   wire  [4:0]  x_index, x_index_1 ; 

   assign    x_index = { x, 1'b0 } ; 
   assign    x_index_1 = { x, 1'b1 } ; 

   always @(*) begin 
      case ( y ) 
         0  : row_data = { 2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b01 ,2'b00 ,2'b00 };
         1  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 };
         2  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         3  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         4  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         5  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         6  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         7  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         8  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         9  : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 };
         10 : row_data = { 2'b01 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 };
         11 : row_data = { 2'b01 ,2'b10 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 ,2'b00 };
         12 : row_data = { 2'b01 ,2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 ,2'b00 };
         13 : row_data = { 2'b01 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b10 ,2'b01 };
         14 : row_data = { 2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b10 ,2'b10 ,2'b01 };
         15 : row_data = { 2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b00 ,2'b01 ,2'b01 ,2'b01 };
      endcase
   end

   always @( posedge clk ) begin 
      data  <= { row_data[ x_index ], row_data[ x_index_1 ] }   ; 
   end 

endmodule 
