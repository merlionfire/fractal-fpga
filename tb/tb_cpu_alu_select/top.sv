`timescale 1ns / 10ps  
//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/08/2017 
// Design Name: 
// Module Name:    top.sv 
// Project Name:   tb_cpu_alu_select
// Target Devices:  
// Tool versions: 
// Description: 
//
// Dependencies:    Top-level of Design and Verification. 
//                  Instatiatse DTU and Verifcation Env 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`include "up_if.sv"
module top;

   parameter  DISP_BLK_SEL_BIT   =  4'h0 ;  
   parameter  DDR2_MGR_SEL_BIT   =  4'h1 ;    
   parameter  FRAC_UNIT_SEL_BIT  =  4'h2 ; 
   parameter  MOUSE_SEL_BIT      =  4'h3 ;
   parameter  ALU_SEL_BIT        =  4'h4 ;
   parameter  UART_SEL_BIT       =  4'h5 ;
   parameter  CPU_SEL_BIT        =  4'h6 ;

   // --- clock and reset ----
   bit       clk ; 

   //*************************************************************//
   // Module instatiation 
   //*************************************************************//

   up_if             cpu_if(clk) ; 

   cpu_top  cpu_top_inst (
      .clk              ( clk                     ), //i
      .reset            ( cpu_if.rst              ), //i
      .port_id          ( cpu_if.port_id          ), //o
      .write_strobe     ( cpu_if.write_strobe     ), //o
      .read_strobe      ( cpu_if.read_strobe      ), //o
      .out_port         ( cpu_if.out_port         ), //o
      .in_port          ( cpu_if.in_port          ), //i
      .interrupt_uart   ( cpu_if.interrupt_uart   ), //i
      .interrupt_alu    ( cpu_if.interrupt_alu    ), //i
      .interrupt_mouse  ( cpu_if.interrupt_mouse  ), //i
      .interrupt_ack    ( cpu_if.interrupt_ack    ), //o
      .pi_blk_sel       ( cpu_if.pi_blk_sel[CPU_SEL_BIT]    ), //i
      .pi_addr          ( cpu_if.pi_addr       ), //i
      .pi_wr_en         ( cpu_if.pi_wr_en      ), //i
      .pi_rd_en         ( cpu_if.pi_rd_en      ), //i
      .pi_wr_data       ( cpu_if.pi_wr_data    ), //i
      .pi_rd_data       ( cpu_if.pi_cpu_rd_data), //o
      .reset_over_remap (                  )  //o
   );

   alu  alu_inst (
      .clk           ( clk                 ), //i
      .rst           ( cpu_if.rst                 ), //i
      .pi_blk_sel    ( cpu_if.pi_blk_sel[ALU_SEL_BIT]    ), //i
      .pi_addr       ( cpu_if.pi_addr       ), //i
      .pi_wr_en      ( cpu_if.pi_wr_en      ), //i
      .pi_rd_en      ( cpu_if.pi_rd_en      ), //i
      .pi_wr_data    ( cpu_if.pi_wr_data    ), //i
      .pi_rd_data    ( cpu_if.pi_alu_rd_data), //o
      .interrupt_ack ( cpu_if.interrupt_ack ), //i
      .interrupt     ( cpu_if.interrupt_alu )  //o
   );
  
   tb_top  test_inst (  
      .clk     ( clk    ), //i
      .cpu_if  ( cpu_if )
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
   end


endmodule
