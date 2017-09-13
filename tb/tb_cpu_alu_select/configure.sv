`ifndef CONFIGURE__SV
`define CONFIGURE__SV
class configure ; 
   parameter   NUM_PKTS_DEFAULT = 10;
   int   pkts_cnt ; 
   int   screen_size;

   function new( int pkts_cnt=NUM_PKTS_DEFAULT, int size=768 ) ; 

      if ( (size <= 0 ) || ( size > 768 ) ) begin 
            $display("@t: [ERR] Cfg: screen size must be within [1,767]!!!", $time ) ;    
            $finish;
      end else begin 
         screen_size =  size ; 
      end

      if (  pkts_cnt > 0 ) begin 
         this.pkts_cnt  =  pkts_cnt ;  
      end else begin
            $display("@t: [ERR] Cfg: number of generated packets must be postive", $time ) ;    
            $finish;
      end 
   endfunction

endclass 

`endif // CONFIGURE__SV
