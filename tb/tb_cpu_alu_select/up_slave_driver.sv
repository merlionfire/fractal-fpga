`ifndef UP_SLAVE_DRIVER__SV
`define UP_SLAVE_DRIVER__SV

virtual class slave_driver_callbacks; 
   virtual  task post_tx( mouse_packet pkt ) ;
   endtask
endclass 

class up_slave_driver ; 

`include "mouse_pi.vh"

   virtual     up_if.slave_mouse    vif ; 
   mailbox     gen2drv ; 

   bit [10:0]  left_pos_x;
   bit [10:0]  bot_pos_y;
   bit [9:0]   half_length;


   event    interrupt_event ; 
   int      interrupt_active_after_configure = 1 ; 
   
   slave_driver_callbacks cbsq[$] ;  

   function new( virtual up_if.slave_mouse  vif, mailbox gen2drv ) ; 
      this.vif       =  vif; 
      this.gen2drv   =  gen2drv;
   endfunction 

   task  append_callback( slave_driver_callbacks cbs );
      cbsq.push_back(cbs) ; 
   endtask

   task run() ; 
      forever begin 
        fork  
          assert_interrupt();
          process_read(); 
          wait_for_data(); 
          @(posedge vif.cb.rst ) ; 
        join_any
        $display("@%0t: [INFO] Driver: enter reset...", $time ) ; 
        disable fork  ; 
        reset_all(); 
        @( negedge vif.cb.rst ) ; 
        $display("@%0t: [INFO] Driver: exit reset...", $time ) ; 
      end
   endtask : run 

   task  process_read() ; 
       forever begin 
            @(vif.cb.pi_sel) ; 
            //$display("@%0t: [DEBUG] Driver: read address is 0x%1h", $time, vif.cb.pi_addr ) ; 
            
            case ( vif.cb.pi_addr )  
               REG_SEL_X_LEFT_LOW_ADDR      :  vif.pi_rd_data   =  left_pos_x[7:0] ;
               REG_SEL_X_LEFT_HIGH_ADDR     :  vif.pi_rd_data   =  { 5'b00000, left_pos_x[10:8] } ;
               REG_SEL_Y_BOT_LOW_ADDR       :  vif.pi_rd_data   =  bot_pos_y[7:0] ;
               REG_SEL_Y_BOT_HIGH_ADDR      :  vif.pi_rd_data   =  { 5'b00000, bot_pos_y[10:8] } ;
               REG_SEL_HALF_LENGTH_LOW_ADDR :  vif.pi_rd_data   =  half_length[7:0] ;
               REG_SEL_HALF_LENGTH_HIGH_ADDR:  vif.pi_rd_data   =  { 6'b000000, half_length[9:8] } ;
               default :                       vif.pi_rd_data   =  'h0 ;
            endcase 
            //$display("@%0t: [DEBUG] Driver: read data is 0x%2h", $time, vif.pi_rd_data ) ; 
            repeat(2) @(vif.cb) ;  
            vif.pi_rd_data   <=  'h0 ;
        end
   endtask : process_read 

   task  assert_interrupt() ; 
        forever begin 
           $display("@%0t: [INFO] Driver: waiting for interrupt event", $time) ; 
           @interrupt_event ; 
           $display("@%0t: [INFO] Driver: assert interrupt", $time) ; 
           @( vif.cb ) ;
           vif.interrupt_slave   <= 1'b1 ;             
           @( posedge vif.cb.interrupt_ack) ; 
           vif.interrupt_slave   <= 1'b0 ;             
        end 
   endtask 

   task reset_all();
      @(vif.cb) ; 
      vif.cb.rst              <= 1'b1;
      vif.interrupt_slave     <= 1'b0; 
      vif.pi_rd_data          <= 'h0;
      repeat (20) @(vif.cb )  ; 
      vif.cb.rst              <= 1'b0;
   endtask


   task  wait_for_data (  ) ; 
      #2;
      forever begin 
         mouse_packet  pkt;
         gen2drv.get(pkt);
         left_pos_x  =  pkt.left_x;
         bot_pos_y   =  pkt.bot_y;
         half_length =  pkt.half_len;  
         if ( interrupt_active_after_configure ) begin 
            invoke_interrupt(); 
         end
         foreach ( cbsq[i] ) begin 
            cbsq[i].post_tx(pkt) ; 
         end 
      end
   endtask 

   task  invoke_interrupt () ; 
      $display("@%0t: [INFO] Driver: mouse triggers interrupt", $time) ; 
      ->interrupt_event ;  
   endtask 

endclass

`endif  //UP_SLAVE_DRIVER__SV
