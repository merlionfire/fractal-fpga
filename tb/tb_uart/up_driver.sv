
class up_driver ; 

   virtual   up_if    vif ; 

   function new( virtual up_if vif ) ; 
      this.vif =  vif ; 
   endfunction 

   task  send_byte ( input uart_packet pkt ) ;  
      logic [7:0] data_reg ; 

      if ( pkt.transmit_delay > 0 ) 
         repeat ( pkt.transmit_delay ) @( posedge vif.clk ) ; 
      while ( 1 ) begin       
         @(posedge vif.clk )  ; 
         vif.read_reg ( REG_UART_STATUS_ADDR , data_reg ) ; 
         if ( data_reg[2] == 1'b1 ) begin 
            //$display("[INFO] Send 0x%2h.", pkt.payload);
            vif.write_reg( REG_UART_WRITE_FIFO_ADDR, pkt.payload ) ; 
            break ; 
         end
      end 
   endtask : send_byte


   task  read_byte ( output uart_packet pkt ) ;  
      logic [7:0] data_reg ; 
      pkt   =  new(); 
      while ( 1 ) begin       
         @(posedge vif.clk )  ; 
         vif.read_reg( REG_UART_STATUS_ADDR , data_reg ) ; 
         if ( data_reg[0] == 1'b1 ) begin 
            vif.read_reg( REG_UART_READ_FIFO_ADDR, data_reg ) ; 
            pkt.payload =  data_reg ; 
            //$display("[INFO] Receive 0x%2h.", pkt.payload);
            break ; 
         end   
      end

   endtask 

endclass
