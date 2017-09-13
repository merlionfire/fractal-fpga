`ifndef GENERATOR__SV 
`define GENERATOR__SV 
class generator;
   int stop_after_n_trans ; 
   mouse_packet   randomize_obj; 
   event       calc_done ; 
   mailbox     gen2drv ; 

   function new( input  mailbox  gen2drv, 
                  input  int   n_trans, 
                 input  event calc_done
                );
      randomize_obj = null ; 
      this.stop_after_n_trans =  n_trans ; 
      this.calc_done          =  calc_done ; 
      this.gen2drv            =  gen2drv;
   endfunction 

   virtual  task run ; 
      $display("\n@%0t: [INFO] Start run testcases for mouse zoom select ......", $time ) ; 
      for ( int i=0; i < stop_after_n_trans ; i++ ) begin 
         mouse_packet   pkt ; 
         assert(randomize_obj.randomize()) ; 
         //$cast( pkt, randomize_obj.clone() ) ; 
         pkt =  randomize_obj.clone()  ; 
         pkt.packet_id = i ; 
         $display("\n@%0t: [INFO] A mouse packet is generated .......", $time ) ; 
         pkt.print(); 
         gen2drv.put(pkt) ; 
         @calc_done; 
      end
   endtask 

endclass 

`endif //GENERATOR__SV 
