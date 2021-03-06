`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    multiplier_wrapper 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Wrapper to N-bit signed multiplier 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module multiplier_wrapper  #( parameter N = 32 ) (
  input  wire              clk,
  input  wire              ce,
  input  wire signed [ N-1:0 ]   a,
  input  wire signed [ N-1:0 ]   b,
  output wire  [ 2*N-1:0 ] p
) ; 

`ifdef SIM 
   reg  [ (2*N-1) : 0 ] result ; 

   always @( posedge clk ) begin    
      if ( ce ) begin 
         result <=   a * b ; 
      end   
   end

   assign p =  result ; 

`else 

   // IP is generated by IP Coregen, which implements 4 MUL18X18 and some LUTs
   // to realize a 32 X 32 signed multiplier 

   mult32X32s mult32X32s_inst  (  
      .clk  (  clk  ), // i
      .a    (  a    ), // i
      .b    (  b    ), // i
      .ce   (  ce   ), // i
      .p    (  p    )  // o
   );

`endif 

endmodule    

      
