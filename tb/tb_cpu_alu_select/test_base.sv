`ifndef  TEST_BASE__SV
`define  TEST_BASE__SV

class test_base ;
   
   typedef proxy_class#(test_base,"test_base")  proxy ; 

   configure         cfg;
   enviornment       env ; 
   mouse_packet      pkt ;
   
   virtual task run( );
      cfg            =  new(); 
      env            =  new(cpu_if, cfg);
      pkt            =  new(.size(cfg.screen_size)) ; 
      env.build() ; 
      env.reset_dut() ; 
      env.gen.randomize_obj  = pkt ;  
      env.run() ; 
      env.report() ; 
   endtask

endclass 
`endif // TEST_BASE__SV

