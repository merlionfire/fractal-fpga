`timescale 1ns / 1ps  
program automatic tb_top (
      input bit   clk,
      up_if       cpu_if
);

   `include    "factory.sv"
   `include    "configure.sv"
   `include    "mouse_packet.sv"
   `include    "scoreboard.sv"
   `include    "generator.sv"
   `include    "up_slave_driver.sv"
   `include    "up_slave_monitor.sv"
   `include    "sb_callbacks.sv" 
   `include    "cov_callbacks.sv"
   `include    "environment.sv"
   `include    "test_lib.sv" 

   initial begin 
      run_test();
   end

   task run_test( string test_name="test_base") ; 
      test_base   test ;  
      factory::print();

      $value$plusargs("testcase=%s",test_name) ; 
      test = factory::create_test_by_name(test_name) ; 
      if ( test == null ) begin 
         $display("[ERR] Testname <%s> is Unkown !!!", test_name) ; 
         $finish; 
      end
      $display("\n*************************************");
      $display("*      Testname = %s   ", test_name) ; 
      $display("*************************************\n");
      test.run(); 
   endtask 
endprogram 

