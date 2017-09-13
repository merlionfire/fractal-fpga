

module multiplier #(
      parameter  M    = 32 
) (

   input   wire             clk,
   input   wire             rst,
   input   wire             ce,
   input   wire             start,   
   input   wire [M-1:0]     a,       // 
   input   wire [M-1:0]     b,       //
   output  wire             valid,   
   output  wire [M-1:0]     result   // 
) ; 


   wire  [2*M-1 : 0]       result_full ; 
   wire     mul_go ; 
   reg      mul_go_1d, mul_go_2d, mul_go_3d ; 
   reg      mul_ce ; 

   multiplier_wrapper  multiplier_wrapper_inst (
      .clk ( clk           ), //i
      .ce  ( mul_ce        ), //i
      .a   ( a             ), //i
      .b   ( b             ), //i
      .p   ( result_full   )  //o
   );

   assign   mul_go   =  start && ce ; 

   always @(posedge clk ) begin 
      if ( valid ) begin 
         mul_ce   <= 1'b0;
      end else if ( mul_go ) begin 
         mul_ce   <= 1'b1;
      end  

   end

   always @(posedge clk ) begin 
      mul_go_1d <= mul_go ; 
      mul_go_2d <= mul_go_1d ; 
      mul_go_3d <= mul_go_2d ; 
   end 

   assign   result   =  result_full[M-1:0] ; 
   assign   valid    =  mul_go_3d ; 

endmodule 
