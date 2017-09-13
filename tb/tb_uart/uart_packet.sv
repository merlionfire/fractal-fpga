
typedef  enum { GOOD, ERROR_PARITY_GOOD, ERROR_PARITY_BAD } error_kind_e ; 
typedef  enum { EVEN, ODD }                                 parity_kind_e ; 
typedef  enum { UART_READ, UART_WRITE }                     uart_op_e;
typedef  enum { ZERO, SHORT, MEDIUM, LONG, MAX }            uart_delay_e ;  

class  uart_packet  ; 

   rand  uart_op_e         uart_op ; 
   rand  bit [7:0]         payload ; 
   rand  bit               parity_enable ; 
   rand  error_kind_e      error_kind ; 
   rand  parity_kind_e     parity_kind ; 
   rand  uart_delay_e      delay_kind ; 
   rand  int unsigned      transmit_delay ; 
   bit                     parity_bit ; 

   // Constraints
   constraint c_payload_dist  { 
      payload[0] dist { 1'b0:=1, 1'b1:=1 }  ;  
      payload[7] dist { 1'b0:=1, 1'b1:=1 }  ;  
   };

   constraint c_parity_enable { parity_enable == 1'b0; } ; 
   constraint c_parity_kind   { parity_kind == EVEN ; } ; 
   constraint c_error_kind    { error_kind == GOOD ; } ; 
   constraint c_delay_kind_dist {
      delay_kind  dist { ZERO:= 3, SHORT:=2, MEDIUM:=1, LONG:=1, MAX:=1} ; 
   } ; 

   constraint c_delay { 
      solve delay_kind before transmit_delay ;
      transmit_delay <= 100 ; 
      ( delay_kind   ==    ZERO     )  -> transmit_delay == 0 ;   
      ( delay_kind   ==    SHORT    )  -> transmit_delay inside { [1:10] } ; 
      ( delay_kind   ==    MEDIUM   )  -> transmit_delay inside { [11:30] } ; 
      ( delay_kind   ==    LONG     )  -> transmit_delay inside { [31:99] } ; 
      ( delay_kind   ==    MAX      )  -> transmit_delay == 100 ;
   } ;    


   function void post_randomize(); 
      parity_bit =  ^payload ; 
      if ( parity_kind == ODD ) begin
         parity_bit  =  ~parity_bit; 
      end
   endfunction 

endclass : uart_packet 

