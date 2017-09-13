`ifndef SB_CALLBACKS__SV
`define SB_CALLBACKS__SV

class slave_driver_sb_callbacks extends slave_driver_callbacks ; 

   scoreboard     sb;

   function new( scoreboard sb ) ; 
      this.sb  =  sb ; 
   endfunction

   virtual  task post_tx( mouse_packet pkt ) ; 
      sb.write_expect( pkt ) ; 
   endtask 

endclass

class slave_monitor_sb_callbacks extends slave_monitor_callbacks  ; 

   scoreboard     sb;

   function new( scoreboard sb ) ; 
      this.sb  =  sb ; 
   endfunction

   virtual  task post_rx( mouse_packet pkt ) ; 
      sb.write_actual( pkt ) ; 
   endtask 

endclass

`endif // SB_CALLBACKS_ _SV
