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
`define  DISP fractal_top_inst.frac_disp_inst 
`define  CORE fractal_top_inst.frac_unit_top_inst.frac_unit_core_inst 
`define  CORE_PI fractal_top_inst.frac_unit_top_inst.frac_unit_pi_inst 

module testbench () ; 

`include "ddr2_512M16_mig_parameters_0.v"

  logic clk, rst ; 
  logic mem_clk_s, mem_rst_s_n ; 
  logic mem_clk0 ;  

  logic ps2_clk ; 
  logic ps2_data ; 

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
      .ps2_clk           ( ps2_clk           ), //io
      .ps2_data          ( ps2_data          ), //io
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

     #5 rst = 1'b0;   
     $display("[DEBUG] fractal_top has been unfrozen !!" ) ;   
     
     wait ( fractal_top_inst.frac_unit_top_inst.frac_unit_core_inst.found_r )  ; 

  end 



  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      wait( `CORE_PI.frac_py_15_8 == 8'h01  ) ;
      @( negedge clk ) ; 
      wait ( `CORE_PI.frac_py_15_8 == 8'h00 &&  `CORE_PI.frac_py_7_0 == 8'h00 ) ; 
      $display( "@%t Starting dump waveform ........", $time ) ; 
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      //$fsdbDumpvars(0, "testbench.fractal_top_inst");
      //#1ms $finish ; 
  end


  initial begin 
     wait( `CORE_PI.frac_py_15_8 == 8'h02  ) ;
     @( negedge clk ) ; 
     $display("@%t Starting fractal engine......", $time() ) ;  
     
     while ( ~ ( `CORE_PI.frac_py_15_8 == 8'h00 &&  `CORE_PI.frac_py_7_0 == 8'hFE) ) begin 
        wait( `CORE.mult_en && (`CORE.frac_st == 3'b010 ) ) ; 
        $write( "[%03h,%03h],", {`CORE_PI.frac_px_15_8 ,  `CORE_PI.frac_px_7_0 }, {`CORE_PI.frac_py_15_8 ,  `CORE_PI.frac_py_7_0 }  ) ; 
        $write("[cx=%08h,cy=%08h],", `CORE.x_r, `CORE.y_r) ; 
        wait( `CORE.done_tick )  ;  
        @( negedge clk ) ; 
        if ( `CORE.found_r ) begin 
           $display("1") ; 
        end else begin 
           $display("0") ; 
        end
     end
     /*
     $display("Start to dump memory.........");
     $writememh("memory_dump.dat", u_mem0.memory ) ; 
     $display("Memory has been dumpped in file <memory_dump.dat>");
     
     #100us $finish ; 
     */
      
      $display("Be waiting for the las top line of screen...") ; 
      wait ( `CORE_PI.frac_py_15_8 == 8'h00 &&  `CORE_PI.frac_py_7_0 == 8'h00 ) ; 
      $display("@%t: Now the top line is being processed ......", $time()) ; 
      @( negedge clk ) ; 
      fork
         begin 
            $display("@%t: Be waiting be last column......", $time()) ; 
            wait (  `CORE_PI.frac_px_15_8 == 8'h02 &&  `CORE_PI.frac_px_7_0 > 8'hF0 ) ;   
         end 
         begin 
            #1ms ;
         end
      join_any

      $display("Start to dump memory.........");
      $writememh("memory_dump.dat", u_mem0.memory ) ; 
      $display("Memory has been dumpped in file <memory_dump.dat>");
      #30ms $finish ; 

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
 */
`endif

endmodule 
