`ifndef ALU_PACKE__SV
`define ALU_PACKE__SV

typedef  enum  {DIV, MUL} alu_op_e;

class alu_packet;

   rand  alu_op_e       alu_op;
   rand  bit signed [31:0]     a;
   rand  bit signed [31:0]     b;
   rand  int            fraction_width ; 
   bit   [31:0]         result ; 
   bit   [31:0]         remainder ; 


   constraint c_b_nozero_for_div {
      ( alu_op == DIV ) -> b != 'b0 ; 
   } 

   constraint c_a_greater_b_for_div {
      (alu_op == DIV ) -> ( a > b ) ; 
   } 

   constraint c_fraction_width_for_mul {
      ( alu_op == MUL ) -> ( fraction_width inside { [1:31] } ) ;
   }

   // [-2,2] 
   // 0b1110_0000_0000_0000_0000_0000_0000_0000   -2
   //    
   // 0b0010_0000_0000_0000_0000_0000_0000_0000    2   
  /* 
   constraint c_max_limit_for_mul {
      if ( alu_op == MUL ) {
         ! ( a inside { [32'h20000000 : 32'he0000000] } )  ;
         ! ( b inside { [32'h20000000 : 32'he0000000] } )  ;
      }

      solve alu_op before a ; 
      solve alu_op before b ; 
   }

    */

   // delta =  ( 1 - ( -2 ) ) / 768 = 1 / 256 = 32'h00_10_00_00 
   // 0b1110_0000_0000_0000_0000_0000_0000_0000      
   //    
   // 0b0000_0000_0000_0000_0000_0010_1111_1111   767   
   
   constraint c_max_limit_for_mul {
      if ( alu_op == MUL ) {
           ( a inside { [32'h00000001 : 32'h00100000] } )  ;
           ( b inside { [32'h00000000 : 32'h00000300] } )  ;
      }

      solve alu_op before a ; 
      solve alu_op before b ; 
   }


   function void post_randomize(); 
      case ( alu_op ) 
         //ADD:  result   =  a  +  b;
         //SUB:  result   =  a  -  b
         MUL:  begin
            bit [63:0]  full_result ; 
            full_result =  a * b ; 
            result      =  full_result[31:0]; 
         end
         DIV:  begin
            result      =  a / b ; 
            remainder   =  a % b ; 
         end
      endcase
   endfunction 

   /*
   function bit [31:0]  bits_slice ( input bit [63:0] data, int start_idx) ; 

      int   j ; 
      j  =  0   ; 

      for ( int i = start_idx ; j < 32 ; i++, j++ ) begin 
            bits_slice[j]  =  data[i] ; 
      end 
      
   endfunction 
*/

endclass : alu_packet

`endif
   
