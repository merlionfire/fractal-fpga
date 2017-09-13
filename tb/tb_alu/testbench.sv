`timescale 1ns / 1ps  
//`default_nettype none 

//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    28/06/2017 
// Design Name: 
// Module Name:    testbech 
// Project Name:   tb_alu
// Target Devices:  
// Tool versions: 
// Description: 
//
// Dependencies:    testbench for alu with uP interface
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "up_if.sv"

module testbench  ( ) ; 

   logic       clk ; 
   logic       rst ; 

   `include    "alu_pi.vh"
   `include    "alu_packet.sv"
   `include    "up_driver.sv"
   `include    "scoreboard.sv"

   parameter   NUM_RAND_TESTS =  200 ; 
   //*******************************************************************//
   //     Class Declaration                                             // 
   //*******************************************************************//

   up_if          cpu_if  ( clk,  rst  ) ; 
   scoreboard     scb ; 
   up_driver      up_drv ; 
   
   alu_packet     alu_pkt ; 
   alu_packet     resp ; 


   covergroup cov_mul_result ;
      coverpoint  alu_pkt.result { 
         bins  positive  = { [0:32'h7f_ff_ff_ff] } ;
         bins  negative  = { [32'h80_00_00_00 : 32'hff_ff_ff_ff] }  ; 
      } 
   endgroup

   cov_mul_result        cov ; 

   //*******************************************************************//
   //     DUT Instatiation                                                  // 
   //*******************************************************************//

   alu  alu_inst (
      .clk           ( clk                  ), //i
      .rst           ( rst                  ), //i
      .pi_blk_sel    ( cpu_if.pi_blk_sel    ), //i
      .pi_addr       ( cpu_if.pi_addr       ), //i
      .pi_wr_en      ( cpu_if.pi_wr_en      ), //i
      .pi_rd_en      ( cpu_if.pi_rd_en      ), //i
      .pi_wr_data    ( cpu_if.pi_wr_data    ), //i
      .pi_rd_data    ( cpu_if.pi_rd_data    ), //o
      .interrupt_ack ( cpu_if.interrupt_ack ), //i
      .interrupt     ( cpu_if.interrupt     )  //o
   );

   //*******************************************************************//
   //     Clock                                                         // 
   //*******************************************************************//
 
   always #10ns clk  = ~ clk ;  
   //
   //*******************************************************************//
   //     FSDB dumper                                                   // 
   //*******************************************************************//

   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      repeat(250) @(posedge clk ) ; 
   end

   //*******************************************************************//
   //     Main test                                                     // 
   //*******************************************************************//

   initial begin 
      clk   =  1'b0; 
      $display("@%0t: [INFO] Starting to test ALU module .........", $time ) ; 
      up_drv   =  new(cpu_if) ; 
      scb      =  new(); 
      cov      =  new(); 
      reset_all() ; 
      direct_test() ; 
      random_test(); 
      repeat (20) @( negedge clk )  ; 
      $finish ;       
   end


   task  reset_all() ; 
      $display("@%0t: [INFO] Reset ALU and test component.........", $time ) ; 
      rst      =  1'b1 ;  
      repeat (20) @( negedge clk )  ; 
      rst      =  1'b0 ;  
      $display("@%0t: [INFO] Release ALU and test component.........", $time ) ; 

   endtask 

   task direct_test () ; 
      //direct_test_divider(); 
      direct_test_multiplier(); 
   endtask 

   task random_test() ; 
      //random_test_for_divider();
      random_test_for_multiplier();
   endtask 


   task  direct_test_multiplier(); 

      $display("\n@%0t: [INFO] Start directed testcases for multiplier........", $time ) ; 
      alu_pkt  =  new(); 
      void'( alu_pkt.randomize( ) with { alu_op == MUL ; fraction_width== 28 ; } ) ;  
      scb.write_a( alu_pkt ) ; 
      up_drv.execute( alu_pkt , resp ) ; 
      scb.write_b( resp ) ; 

      scb.perform_check() ; 

   endtask : direct_test_multiplier  

   task random_test_for_multiplier() ; 
      $display("\n@%0t: [INFO] Start randomized testcases for Multiplier ......", $time ) ; 
      for ( int i=0; i < NUM_RAND_TESTS ; i++ ) begin 
         alu_pkt  =  new(); 
         void'( alu_pkt.randomize( ) with { alu_op == MUL ; fraction_width == 28 ; } ) ;  
         cov.sample(); 
         scb.write_a( alu_pkt ) ; 
         up_drv.execute( alu_pkt , resp ) ; 
         scb.write_b( resp ) ; 
      end

      scb.perform_check() ; 

   endtask : random_test_for_multiplier 

   task direct_test_divider() ; 
      $display("\n@%0t: [INFO] Start directed testcases for Divider........", $time ) ; 
      void'( alu_pkt.randomize( ) with { alu_op == DIV ; a > b ; } ) ; 
      scb.write_a( alu_pkt ) ; 
      up_drv.execute( alu_pkt , resp ) ; 
      scb.write_b( resp ) ; 

      scb.perform_check() ; 
   endtask : direct_test_divider 

   task random_test_for_divider() ; 

      $display("\n@%0t: [INFO] Start randomized testcases with all bits randomized ......", $time ) ; 
      for ( int i=0; i < NUM_RAND_TESTS ; i++ ) begin 
         alu_pkt  =  new(); 
         void'( alu_pkt.randomize( ) with { alu_op == DIV ;  } ) ; 
         scb.write_a( alu_pkt ) ; 
         up_drv.execute( alu_pkt , resp ) ; 
         scb.write_b( resp ) ; 
      end

      scb.perform_check() ; 
      $display("\n@%0t: [INFO] Start randomized testcases with b[31:16] == 0........", $time ) ; 
      for ( int i=0; i < NUM_RAND_TESTS ; i++ ) begin 
         alu_pkt  =  new(); 
         void'( alu_pkt.randomize( ) with { alu_op == DIV ; b[31:16] == 0 ; } ) ; 
         scb.write_a( alu_pkt ) ; 
         up_drv.execute( alu_pkt , resp ) ; 
         scb.write_b( resp ) ; 
      end
      scb.perform_check() ; 

      $display("\n@%0t: [INFO] Start randomized testcases with b[31:8] == 0 ........", $time ) ; 
      for ( int i=0; i < NUM_RAND_TESTS ; i++ ) begin 
         alu_pkt  =  new(); 
         void'( alu_pkt.randomize( ) with { alu_op == DIV ;  b[31:8] == 0 ; } ) ; 
         scb.write_a( alu_pkt ) ; 
         up_drv.execute( alu_pkt , resp ) ; 
         scb.write_b( resp ) ; 
      end

      scb.perform_check() ; 

   endtask : random_test_for_divider 
   
endmodule 
