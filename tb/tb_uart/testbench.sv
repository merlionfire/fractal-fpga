`timescale 1ns / 1ps  
//`default_nettype none 

//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    23/04/2017 
// Design Name: 
// Module Name:    testbech 
// Project Name:   tb_uart
// Target Devices:  
// Tool versions: 
// Description: 
//
// Dependencies:    testbench for uart rtl with uP interface
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "up_if.sv"

module testbench  ( ) ; 

   logic       clk_a, rst_a ; 
   logic       clk_b, rst_b ; 
   logic       tx_a, tx_b, rx_a, rx_b ; 

   parameter RND_TEST_NUM  =  1000 ; 

   `include "uart_pi.vh" 
   `include "uart_packet.sv" 
   `include "scoreboard.sv" 
   `include "up_driver.sv"

   //*******************************************************************//
   //     Class Declaration                                             // 
   //*******************************************************************//

   up_if          up_if_a  ( clk_a,  rst_a  ) ; 
   up_if          up_if_b ( clk_b, rst_b ) ; 
   uart_packet    test_pkt ; 
   scoreboard     scb ; 
   up_driver      up_driver_a ; 
   up_driver      up_driver_b ; 

   //*******************************************************************//
   //     DUT Instatiation                                                  // 
   //*******************************************************************//

   uart  uart_a (
      .clk           ( clk_a                 ), //i
      .rst           ( rst_a                 ), //i
      .rx            ( rx_a                  ), //i
      .tx            ( tx_a                  ), //o
      .pi_blk_sel    ( up_if_a.pi_blk_sel    ), //i
      .pi_addr       ( up_if_a.pi_addr       ), //i
      .pi_wr_en      ( up_if_a.pi_wr_en      ), //i
      .pi_rd_en      ( up_if_a.pi_rd_en      ), //i
      .pi_wr_data    ( up_if_a.pi_wr_data    ), //i
      .pi_rd_data    ( up_if_a.pi_rd_data    ), //o
      .interrupt_ack ( up_if_a.interrupt_ack ), //i
      .interrupt     ( up_if_a.interrupt     )  //o
   );

   uart  uart_b (
      .clk           ( up_if_b.clk           ), //i
      .rst           ( up_if_b.rst           ), //i
      .rx            ( rx_b                  ), //i
      .tx            ( tx_b                  ), //o
      .pi_blk_sel    ( up_if_b.pi_blk_sel    ), //i
      .pi_addr       ( up_if_b.pi_addr       ), //i
      .pi_wr_en      ( up_if_b.pi_wr_en      ), //i
      .pi_rd_en      ( up_if_b.pi_rd_en      ), //i
      .pi_wr_data    ( up_if_b.pi_wr_data    ), //i
      .pi_rd_data    ( up_if_b.pi_rd_data    ), //o
      .interrupt_ack ( up_if_b.interrupt_ack ), //i
      .interrupt     ( up_if_b.interrupt     )  //o
   );

   //*******************************************************************//
   //     Clock                                                         // 
   //*******************************************************************//
 
   always #10ns clk_a  = ~ clk_a ;  


   initial begin 
      #8ns
      forever  #10ns clk_b = ~ clk_b;  
   end

   //*******************************************************************//
   //     FSDB dumper                                                   // 
   //*******************************************************************//

   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      repeat(250) @(posedge clk_a ) ; 
   end


   //*******************************************************************//
   //     Main test                                                     // 
   //*******************************************************************//
   
   assign   rx_a  =  tx_b ; 
   assign   rx_b  =  tx_a ; 

   initial begin 
      $display("[INFO] Starting to test UART module ........." ) ; 
      test_pkt = new() ; 
      scb      = new() ; 
      up_driver_a =  new(up_if_a); 
      up_driver_b =  new(up_if_b); 
      clk_a    =  1'b0; 
      clk_b   =  1'b0; 
      rst_a    =  1'b1 ; 
      rst_b   =  1'b1 ; 

      repeat (20) @( negedge clk_a )  ; 

      rst_a    =  1'b0 ; 
      rst_b   =  1'b0 ; 

      repeat (20) @( negedge clk_a )  ; 

      fork  
         fork 
            begin 
               $display("[INFO] Directed test ........." ) ; 
               void'( test_pkt.randomize( ) with { payload == 8'b10010101 ; } ) ; 
               up_driver_a.send_byte( test_pkt ) ; 
               scb.write_a( test_pkt ) ; 

               $display("[INFO] Randomized test ........." ) ; 
               for ( int i = 0; i < RND_TEST_NUM; i++ ) begin  
                  test_pkt =  new() ; 
                  void'( test_pkt.randomize( )   ) ; 
                  up_driver_a.send_byte( test_pkt ) ; 
                  scb.write_a( test_pkt ) ; 
               end

            end

            begin 
               uart_packet receive_pkt ;
               up_driver_b.read_byte( receive_pkt ) ; 
               scb.write_b( receive_pkt ) ; 
               for ( int i = 0; i < RND_TEST_NUM; i++ ) begin  
                  up_driver_b.read_byte( receive_pkt ) ; 
                  scb.write_b( receive_pkt ) ; 
               end
            end 
         join

         begin 
            #15ms;
            $display("[INFO] Time out !!!"); 
         end

      join_any 

      scb.perform_check() ; 

      repeat (20) @( negedge clk_a )  ; 
      $finish ;       

   end 

   //*************************************************************//
   // Task and function definition 
   //*************************************************************//
endmodule
