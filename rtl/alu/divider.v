//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   07/02/2017 
// Design Name: 
// Module Name:   divider 
// Function:      radix-2 non-restoring fixed-point divider  
//
// Note: 
//    shift-substract approach
//
//    _____   _____________________ 
//   |  c  |  | |      a          |
//    -----   ---------------------
//    __________ 
//   | 0 |   b  |   
//    ---------- 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module divider #( 
      parameter  M  = 16, 
      parameter  N  = 16
) (
   input   wire             clk,
   input   wire             rst,
   input   wire             ce,
   input   wire             start,   
   input   wire [M-1:0]     a,       // Dividend
   input   wire [N-1:0]     b,       // Divisor
   output  wire             valid,   
   output  wire [M-1:0]     q,       // Quotient
   output  wire [N-1:0]     r        // Rmd 
) ; 



   // ---------------------------------------------------------
   //    Variables declaration   
   // ---------------------------------------------------------
function integer clog2;
  input integer value;
  begin
    value = value - 1;
    for (clog2 = 0; value > 0; clog2 = clog2 + 1)
      value = value >> 1;
  end
endfunction

   parameter    STEP_BITS  = clog2(M) ; 

   reg   [ M-1 : 0 ]       a_r; 
   reg   [ N-1 : 0 ]       b_r; 
   reg   [ N-1 : 0 ]       c_r;

   wire  [ N : 0 ]         b_ext ;
   wire  [ N : 0 ]         c_ext ;

   wire  [ N-1 : 0 ]       diff;
   wire                    sig_minus;

   reg   [ STEP_BITS-1:0]  step ; 
   reg   busy ; 
   reg   valid_r ; 



   // ---------------------------------------------------------
   //    Combination Logic   
   // ---------------------------------------------------------

   assign b_ext   =  { 1'b0, b_r } ; 

   assign c_ext   =  { c_r, a_r[M-1] } ;  

   assign { sig_minus, diff }  = c_ext - b_ext ; 

   // ---------------------------------------------------------
   //    Sequential Logic   
   // ---------------------------------------------------------

   always @( posedge clk ) begin 
      if ( rst ) begin 
         a_r      <=  'h0; 
         b_r      <=  'h0;
         c_r      <=  'h0 ; 
         busy     <=  1'b0;
         step     <=  'h0 ;  
         valid_r  <= 1'b0 ; 
      end else begin 
         valid_r  <= 1'b0 ; 
         if ( ce == 1'b1 ) begin 
            if ( start & ~busy ) begin 
               a_r      <=  a; 
               b_r      <=  b;
               c_r      <=  'h0 ; 
               busy     <=  1'b1;
               step     <=  'h0 ;  
            end else if ( busy ) begin 
               if ( sig_minus ) begin 
                  c_r   <= c_ext[N-1:0] ;
               end else begin 
                  c_r   <= diff ; 
               end
               
               a_r      <= { a_r[M-2:0],  ~sig_minus } ; 
               
               step     <= step + 1'b1 ; 
               if ( step == (M-1) ) begin 
                  busy  <= 1'b0 ; 
                  valid_r  <= 1'b1 ; 
               end
            end
         end
      end
   end


   //---------------------------------------
   //   Output interface signals  
   //---------------------------------------
      
   assign  q            =  a_r ; 
   assign  r            =  c_r[N-1:0] ;  
   assign  valid        =  valid_r;
endmodule 
