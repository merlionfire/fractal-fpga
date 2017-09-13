`ifndef PACKET__SV
`define PACKET__SV

class packet   extends uvm_sequence_item ; 
   typedef enum { TRUE, FALSE } result_e ;  
   static real  cx_orig =  -2;
   static real  cy_orig =  -1.5;
   static real  delta   =  0.00390625; 
   rand  bit [10:0]  x;
   rand  bit [10:0]  y;
   rand  bit [15:0]  iter;
   real        cx;
   real        cy;
   result_e          result ;  

   `uvm_object_utils_begin(packet)
      `uvm_field_int (x,               UVM_ALL_ON | UVM_UNSIGNED | UVM_NOCOMPARE ) 
      `uvm_field_int (y,               UVM_ALL_ON | UVM_UNSIGNED | UVM_NOCOMPARE )
      `uvm_field_int (iter,            UVM_ALL_ON | UVM_UNSIGNED | UVM_NOCOMPARE )
      `uvm_field_real(cx,              UVM_ALL_ON | UVM_NOCOMPARE  )
      `uvm_field_real(cy,              UVM_ALL_ON | UVM_NOCOMPARE  )
      `uvm_field_enum(result_e,result, UVM_ALL_ON ) 
   `uvm_object_utils_end

   constraint c_iter { iter == 48 ;} ; 

   function new(string name = "packet" ) ; 
      super.new(name);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction 

   function void post_randomize(); 
      cx = cx_orig + x * delta ; 
      cy = cy_orig + (767-y) * delta ; 
   endfunction

   static function bit signed [31:0]  float2bits( input real data_in ) ; 
      real temp ;
      temp = (data_in * ( 2 ** (32-4) ) ); 
      float2bits = int'(temp ) ;
   endfunction 

   static function real bits2float( input bit signed [31:0]  data_in ) ; 
      bits2float = real'(data_in) / ( 2 ** ( 32-4) );
   endfunction 
endclass: packet 
`endif // PACKET__SV

