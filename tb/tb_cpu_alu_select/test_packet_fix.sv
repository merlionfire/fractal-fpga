
`ifndef  TEST_PACKET_FIX__SV
`define  TEST_PACKET_FIX__SV

class packet_fix extends mouse_packet; 

   constraint  c_left_x_limit { left_x == 10; }  

   constraint  c_bot_y_limt   { bot_y == 757; }

   constraint  c_half_len_limit {  half_len == 100; } 

   function  new( int unsigned id = 0, int size = 768, shortreal cx = -2.0 , cy = -1.5 ) ; 
      super.new(id,size,cx,cy);
   endfunction

endclass 

class test_packet_fix extends test_base ;
 
   typedef proxy_class#(test_packet_fix, "test_packet_fix")  proxy ; 

   configure         cfg;
   enviornment       env ; 
   packet_fix        pkt ;

   virtual task run();
      cfg            =  new( .pkts_cnt( 1 ) ); 
      env            =  new(cpu_if, cfg);
      pkt            =  new(.size(cfg.screen_size)) ; 
      env.build() ; 
      env.reset_dut() ; 
      env.gen.randomize_obj  = pkt ;  
      env.run() ; 
      env.report() ; 
   endtask

endclass 

`endif // TEST_PACKET_FIX__SV
