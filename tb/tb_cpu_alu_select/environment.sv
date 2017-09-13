`ifndef ENVIRONMENT__SV
`define ENVIRONMENT__SV

typedef class factory ;
class enviornment ; 
   

   virtual up_if             cpu_if;
   configure         cfg;
   generator         gen;
   mailbox           gen2drv; 
   up_slave_driver   up_slave_drv ; 
   up_slave_monitor  up_slave_mon;   
   scoreboard        scb;
   slave_driver_sb_callbacks   slave_drv_sb ; 
   slave_monitor_sb_callbacks  slave_mon_sb ; 
   slave_driver_cov_callbacks  slave_drv_cov;

   event             calc_done; 

   function new( input virtual up_if vif, configure cfg ) ; 
      this.cpu_if =  vif;
      this.cfg    =  cfg;
   endfunction

   task build() ; 
      $display("@%0t: [INFO] Env: execute build()....", $time ) ; 
      gen2drv        =  new();
      scb            =  new();
      gen            =  new(gen2drv,cfg.pkts_cnt,calc_done );
      up_slave_drv   =  new(cpu_if.slave_mouse, gen2drv) ; 
      slave_drv_sb   =  new(scb) ; 
      slave_drv_cov  =  new();
      up_slave_drv.append_callback(slave_drv_sb) ; 
      up_slave_drv.append_callback(slave_drv_cov) ; 

      up_slave_mon   =  new(cpu_if.monitor, calc_done) ; 
      slave_mon_sb   =  new(scb) ; 
      up_slave_mon.append_callback(slave_mon_sb) ; 
   endtask 


   task  reset_dut(); 
      $display("@%0t: [INFO] Reset all components.........", $time ) ; 
      up_slave_drv.reset_all();    
      $display("@%0t: [INFO] Release all component.........", $time ) ; 
   endtask ; 

   task  run();
      fork 
         gen.run(); 
         up_slave_drv.run(); 
         up_slave_mon.run();
      join_any
   endtask

   task  report() ; 
      scb.perform_check() ; 
   endtask 


endclass 
`endif //  ENVIRONMENT__SV
