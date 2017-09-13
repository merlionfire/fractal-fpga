`timescale 1ns / 100ps
`default_nettype none 
`define  SIM 
`define  SVA 
`define  DISP fractal_top_inst.frac_disp_inst 
//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/14/2015 
// Design Name: 
// Module Name:    tb_fractal_top.v 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Testbench  
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps
`default_nettype none 
`define  SIM 
`define  SVA 
`define  FRAME  fractal_top_inst.frame_buf_inst
module testbench () ; 

`include "ddr2_512M16_mig_parameters_0.v"

  logic clk, rst ; 
  logic mem_clk_s, mem_rst_s_n ; 
  logic mem_clk0 ;  

   // Sinals between DDR2 model and MIG .
   wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga;
   wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_fpga;
   wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_fpga;
   wire [`CLK_WIDTH-1:0]          ddr2_clk_n_fpga;
   wire [`ROW_ADDRESS-1:0]        ddr2_address_fpga;
   wire [`BANK_ADDRESS-1:0]       ddr2_ba_fpga;
   wire                           ddr2_ras_n_fpga;
   wire                           ddr2_cas_n_fpga;
   wire                           ddr2_we_n_fpga;
   wire                           ddr2_cs_n_fpga;
   wire                           ddr2_cke_fpga;
   wire                           ddr2_odt_fpga;

   wire ddr2_rst_dqs_div_in ;
   wire ddr2_rst_dqs_div_out; 
   logic vga_h_sync,  vga_v_sync;

   logic [3:0] vga_red, vga_green,  vga_blue;

   reg [12:0] row ; 
   reg [6:0]  col ; 
   reg [1:0]  bank = 2'b00 ; 
   reg  [21:0] addr ; 

  //*******************************************************************//
  //     Instatiation                                                  // 
  //*******************************************************************//

  fractal_top  fractal_top_inst (
      .clk               ( clk               ), //i
      .mem_clk_s         ( mem_clk_s         ), //i
      .rst               ( rst               ), //i
      .mem_rst_s_n       ( mem_rst_s_n       ), //i
      .vga_red           ( vga_red           ), //o
      .vga_green         ( vga_green         ), //o
      .vga_blue          ( vga_blue          ), //o
      .vga_h_sync        ( vga_h_sync        ), //o
      .vga_v_sync        ( vga_v_sync        ), //o
      .ddr2_dq_fpga      ( ddr2_dq_fpga      ), //o
      .ddr2_dqs_fpga     ( ddr2_dqs_fpga     ), //o
      .ddr2_dqs_n_fpga   ( ddr2_dqs_n_fpga   ), //o
      .ddr2_dm_fpga      ( ddr2_dm_fpga      ), //o
      .ddr2_clk_fpga     ( ddr2_clk_fpga     ), //o
      .ddr2_clk_n_fpga   ( ddr2_clk_n_fpga   ), //o
      .ddr2_address_fpga ( ddr2_address_fpga ), //o
      .ddr2_ba_fpga      ( ddr2_ba_fpga      ), //o
      .ddr2_ras_n_fpga   ( ddr2_ras_n_fpga   ), //o
      .ddr2_cas_n_fpga   ( ddr2_cas_n_fpga   ), //o
      .ddr2_we_n_fpga    ( ddr2_we_n_fpga    ), //o
      .ddr2_cs_n_fpga    ( ddr2_cs_n_fpga    ), //o
      .ddr2_cke_fpga     ( ddr2_cke_fpga     ), //o
      .ddr2_odt_fpga     ( ddr2_odt_fpga     ), //o
      .ddr2_rst_dqs_div_in  ( ddr2_rst_dqs_div_in ), //i
      .ddr2_rst_dqs_div_out ( ddr2_rst_dqs_div_out)  //o
  );

   /////////////////////////////////////////////////////////////////////////////
   // Memory model instances
   /////////////////////////////////////////////////////////////////////////////
   
   ddr2_model u_mem0 (
      .ck      (ddr2_clk_fpga),
      .ck_n    (ddr2_clk_n_fpga),
      .cke     (ddr2_cke_fpga),
      .cs_n    (ddr2_cs_n_fpga),
      .ras_n   (ddr2_ras_n_fpga),
      .cas_n   (ddr2_cas_n_fpga),
      .we_n    (ddr2_we_n_fpga),
      .dm_rdqs (ddr2_dm_fpga),
      .ba      (ddr2_ba_fpga),
      .addr    (ddr2_address_fpga),
      .dq      (ddr2_dq_fpga),
      .dqs     (ddr2_dqs_fpga),
      .dqs_n   (ddr2_dqs_n_fpga),
      .rdqs_n  (),
      .odt     (ddr2_odt_fpga)
   );
  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  always #10ns clk = ~ clk ; 
  always #4ns mem_clk_s = ~ mem_clk_s ; 


  //*******************************************************************//
  //     Main test                                                     // 
  //*******************************************************************//

  assign  ddr2_rst_dqs_div_in = ddr2_rst_dqs_div_out ;

  assign   mem_clk0 = fractal_top_inst.mem_clk0 ; 

  initial begin 
     rst   =  1'b1; clk   =  1'b0;  
     mem_clk_s = 1'b0 ;  mem_rst_s_n = 1'b0 ; 
     
     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #10 mem_rst_s_n =  1'b1 ; 
     
     $display("[DEBUG] DDR2_mgr has been unfrozen, be waiting for memory init done......" ) ;   
     wait ( fractal_top_inst.mig_init_done ) ; 

     $display("[DEBUG] Memory initialization has been done !!" ) ;   

     repeat (8) @(posedge clk ) ; 

     $display("[DEBUG] Start to preload ddr2 with incremental data !!") ;  

     //for ( row= 'h0 ; row < 13'd768 ; row++ ) begin 
     /*
     for ( row= 'h0 ; row < 13'd100 ; row++ ) begin 
         for ( col= 'h0 ; col <= 7'h7f ; col++ ) begin 
            addr = { bank, row, col } ; 
            u_mem0.memory[addr] = { 8{ 3'b000, row } } ;  
         end
     end
*/
     //$readmemh("init_ddr2.dat", u_mem0.memory ) ;  
     $readmemh("init_ddr2_3sections.dat", u_mem0.memory ) ;  

     $display("[DEBUG] DDR2 init has been done !!") ;  

     repeat (20) @(negedge mem_clk0 ) ; 
     fractal_top_inst.frac_disp_inst.req_rd_ddr = 1'b1 ; 
     fractal_top_inst.frac_disp_inst.req_ddr_addr_row  = 'h0 ; 
     $display("[DEBUG] Start to init low half of linebuf !!") ;  
     @(negedge mem_clk0 ) ; 
     fractal_top_inst.frac_disp_inst.req_rd_ddr = 1'b0 ; 
     repeat (20) @(negedge mem_clk0 ) ; 
     wait ( fractal_top_inst.frame_buf_inst.req_st_r == 2'b00 )  ; 
     $display("[DEBUG] Init low half of linebuf has been done !!") ;  

     repeat (2) @(negedge mem_clk0 ) ; 
     fractal_top_inst.frac_disp_inst.req_rd_ddr = 1'b1 ; 
     fractal_top_inst.frac_disp_inst.req_ddr_addr_row  = 'h1 ; 
     $display("[DEBUG] Start to init high half of linebuf !!") ;  
     @(negedge mem_clk0 ) ; 
     fractal_top_inst.frac_disp_inst.req_rd_ddr = 1'b0 ; 
     repeat (20) @(negedge mem_clk0 ) ; 
     wait ( fractal_top_inst.frame_buf_inst.req_st_r == 2'b00 )  ; 
     $display("[DEBUG] Init high half of linebuf has been done !!") ;  

     #5 rst = 1'b0;   
     $display("[DEBUG] fractal_top has been unfrozen !!" ) ;   
  end 



  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      #22ms $finish ; 
  end

`ifdef SVA 
/*
   property DDR2_VALUE_CHECKER ; 
      @( posedge clk ) 
         `DISP.linebuf_rd_en |-> ##2 ( `DISP.linebuf_rd_data == { 5'b00000, `DISP.pixel_y }  ) ; 
   endproperty 

   assert property ( DDR2_VALUE_CHECKER ) 
      else begin 
         $display( "[ASSERT ERR] %t: ddr2 data is not as expected !!!", $time ) ; 
         repeat (20 ) @( posedge clk ) ; 
         $finish ; 
      end   

   cover property ( DDR2_VALUE_CHECKER ) ;     
*/
   property DDR2_VALUE_CHECKER ; 
      @( posedge clk ) disable iff ( rst == 1'b1 )  
         `DISP.diag_err == 1'b0  ; 
   endproperty 

   assert property ( DDR2_VALUE_CHECKER ) 
      else begin 
         $display( "[ASSERT ERR] %t: ddr2 data is not as expected !!!", $time ) ; 
         repeat (20 ) @( posedge clk ) ; 
         $finish ; 
      end   

   cover property ( DDR2_VALUE_CHECKER ) ;     
`endif

endmodule 
