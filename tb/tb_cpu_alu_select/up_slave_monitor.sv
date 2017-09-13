`ifndef UP_SLAVE_MONITOR__SV
`define UP_SLAVE_MONITOR__SV

virtual class slave_monitor_callbacks;
   virtual task  post_rx( mouse_packet pkt ) ; 
   endtask 
endclass

class up_slave_monitor ; 

`include "mouse_pi.vh"

   virtual     up_if.monitor    vif ; 
   event       calc_done ; 
   int         slave_id       =  15; 
   int         last_cfg_idx   =  11  ; 
   bit [7:0]   data[0:15]  =  '{default:8'h00};  

   slave_monitor_callbacks cbsq[$]; 

   function new( virtual up_if.monitor vif, event done ) ; 
      this.vif       =  vif; 
      this.calc_done =  done; 
   endfunction 
   
   task  configure ( int last_cfg_idx ,  int slave_id = 15 ) ; 
      this.last_cfg_idx =  last_cfg_idx;
      this.slave_id     =  slave_id ; 
   endtask 

   task  append_callback( slave_monitor_callbacks cbs );
      cbsq.push_back(cbs) ; 
   endtask

   task  run();
      forever begin

         fork 
            collect_data(); 
            @(posedge vif.rst) ; 
         join_any

         $display("@%0t: [INFO] Monitor: enter reset...", $time ) ; 
         disable fork;
         reset_all();
         @(negedge vif.rst); 
         @(posedge vif.clk);
         $display("@%0t: [INFO] Monitor: exit reset...", $time ) ; 
      end

   endtask 


   task  collect_data() ; 

      forever  begin 
         @(posedge vif.clk) ; 
         //$display("@%0t: [DEBUG] Monitor: pi_blk_sel = %16b", $time, vif.pi_blk_sel ) ; 
         if ( vif.pi_wr_en & vif.pi_blk_sel[slave_id] ) begin
            data[vif.pi_addr] =  vif.pi_wr_data ; 
            //$display("@%0t: [DEBUG] Monitor: write address is 0x%1h", $time, vif.pi_addr ) ; 
            //$display("@%0t: [DEBUG] Monitor: write data is 0x%1h", $time, vif.pi_wr_data ) ; 
            if ( vif.pi_addr  == last_cfg_idx ) begin 
               //$display("@%0t: [DEBUG] Monitor: Last data has been written. Begin pack data and sent to scoreboard", $time ) ; 
               pack_data_sent() ; 
               notify_done(); 
            end
         end
      end

   endtask 

   task reset_all();
      @(posedge vif.clk ) ; 
      foreach ( data[i] ) begin 
         data[i]  =  8'h00 ; 
      end 
   endtask

   task pack_data_sent(); 
      mouse_packet  resp ; 
      int   frac_width = 32-4 ; 
      resp  =  new() ; 
      resp.new_cx    =  int2real( { data[3], data[2], data[1], data[0] }, frac_width  )  ;  
      resp.new_cy    =  int2real( { data[7], data[6], data[5], data[4] }, frac_width  )  ;  
      resp.new_delta =  int2real( { data[11], data[10], data[9], data[8] }, frac_width  )  ;  
      foreach ( cbsq[i] ) begin 
         cbsq[i].post_rx(resp) ; 
      end 
   endtask 

   function shortreal int2real ( bit signed [31:0]  data_in , int width ) ;
      real  temp ; 
      temp  =  real'(data_in) ; 
      int2real =  real'(data_in) / ( 2 ** width ) ;   
      //$display("@%0t: [DEBUG] Monitor: convert 0x%8h --> %f", $time, data_in, temp ) ; 
      //$display("@%0t: [DEBUG] Monitor: convert 0x%8h --> %f", $time, data_in, int2real ) ; 
   endfunction

   task notify_done();
      ->calc_done ; 
   endtask 

endclass

`endif  //UP_SLAVE_MONITOR__SV
