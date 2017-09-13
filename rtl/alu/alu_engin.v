

module alu_engine #(
   parameter   M  =  32,
   parameter   N  =  32
) (   
   // --- clock and reset 
   input  wire          clk,
   input  wire          rst,

   // --- data interface
   input  wire          ce,
   input  wire          start,
   input  wire [M-1:0]  a,
   input  wire [N-1:0]  b,
   input  wire [3:0]    op,
   output wire          valid,
   output wire [M-1:0]  q,
   output wire [N-1:0]  r
);


   //*************************************************************//
   //    Variables declaration   
   //*************************************************************//
   parameter   OP_DIVIDER = 4'h0 ; 
   parameter   OP_MUL     = 4'h1 ; 

   wire           divider_ce;
   wire           multiplier_ce;
   wire           div_valid;
   wire           mul_valid;
   wire [31:0]    div_q;
   wire [31:0]    div_r;
   wire [31:0]    mul_result;

   //*************************************************************//
   // Module instatiation 
   //*************************************************************//
   divider  #( 
         .M(M),
         .N(N)
   ) divider_inst (
      .clk   ( clk         ), //i
      .rst   ( rst         ), //i
      .ce    ( divider_ce  ), //i
      .start ( start       ), //i
      .a     ( a           ), //i
      .b     ( b           ), //i
      .valid ( div_valid       ), //o
      .q     ( div_q           ), //o
      .r     ( div_r           )  //o
   );

   multiplier  #( 
         .M(M)
   ) multiplier_inst (
      .clk   ( clk         ), //i
      .rst   ( rst         ), //i
      .ce    ( multiplier_ce  ), //i
      .start ( start       ), //i
      .a     ( a           ), //i
      .b     ( b           ), //i
      .valid ( mul_valid       ), //o
      .result( mul_result  ) //o
   );

   //*************************************************************//
   // Logics 
   //*************************************************************//
  
   assign divider_ce    = ( op == OP_DIVIDER ) ? ce : 1'b0;     
   assign multiplier_ce = ( op == OP_MUL)      ? ce : 1'b0; 

   assign valid   =  div_valid || mul_valid ; 
   assign q       =  ( { 32{div_valid} } & div_q)  | ( { 32{mul_valid} } & mul_result ) ; 
   assign r       =  div_r ; 

endmodule 
