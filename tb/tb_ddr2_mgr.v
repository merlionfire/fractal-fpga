`timescale 1ns / 100ps
`default_nettype none 
`define  SIM 
`define  SVA 
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


module testbench () ; 

`include "ddr2_512M16_mig_parameters_0.v"

  logic clk, rst ; 


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
  
   //Signals between ddr2_mgr and MIG  

   wire                                  mig_burst_done;
   wire                                  mig_init_done;
   wire                                  mig_ar_done;
   wire                                  mig_user_data_valid;
   wire                                  mig_auto_ref_req;
   wire                                  mig_user_cmd_ack;
   wire [2:0]                            mig_user_input_cmds;
   wire                                  mig_clk0;
   wire                                  mig_clk90;
   wire                                  mig_rst0;
   wire                                  mig_rst90;
   wire                                  mig_rst180;
   wire [((`DATA_MASK_WIDTH*2)-1): 0]    mig_user_input_mask;
   wire [(2*`DATA_WIDTH)-1: 0]           mig_user_input_data;
   wire [(2*`DATA_WIDTH)-1: 0]           mig_user_output_data;
   wire [((`ROW_ADDRESS + `COLUMN_ADDRESS + `BANK_ADDRESS)-1): 0] mig_user_input_addr;
   wire                                  rst_dqs_div_loop;

   wire  mem_clk0, mem_clk90, mem_rst0, mem_rst90, mem_rst180 ; 


   wire rd_mem_req, rd_mem_grant, rd_data_valid;
   wire [24:0] rd_mem_addr; 
   wire [9:0]  rd_xfr_len; 
   wire [31:0] rd_data;
   
   
   logic        pi_clk;
   logic        pi_rst; 
   logic        pi_blk_sel;
   logic [3:0]  pi_addr;
   logic        pi_wr_en;
   logic        pi_rd_en;
   logic [7:0]  pi_wr_data;
   logic [7:0]  pi_rd_data;
   //*******************************************************************//
   //     Instatiation                                                  // 
   //*******************************************************************//

   frame_buf  frame_buf_inst (
      .mem_clk0      ( mem_clk0      ), //i
      .mem_clk90     ( mem_clk90     ), //i
      .mem_rst       ( mem_rst180    ), //i
      .rd_mem_req    ( rd_mem_req    ), //o
      .rd_mem_addr   ( rd_mem_addr   ), //o
      .rd_xfr_len    ( rd_xfr_len    ), //o
      .rd_mem_grant  ( rd_mem_grant  ), //i
      .rd_data       ( rd_data       ), //i
      .rd_data_valid ( rd_data_valid )  //i
   );

   ddr2_mgr  ddr2_mgr_inst (
      .clk0                 ( mem_clk0             ), //i
      .rst0                 ( mem_rst0             ), //i
      .clk90                ( mem_clk90            ), //i
      .rst90                ( mem_rst90            ), //i
      .rst180               ( mem_rst180           ), //i
      .pi_clk               ( pi_clk               ), //i
      .pi_rst               ( pi_rst               ), //i
      .mig_user_input_cmds  ( mig_user_input_cmds  ), //o
      .mig_burst_done       ( mig_burst_done       ), //o
      .mig_user_input_addr  ( mig_user_input_addr  ), //o
      .mig_init_done        ( mig_init_done        ), //i
      .mig_user_cmd_ack     ( mig_user_cmd_ack     ), //i
      .mig_user_input_data  ( mig_user_input_data  ), //o
      .mig_user_input_mask  ( mig_user_input_mask  ), //o
      .mig_user_output_data ( mig_user_output_data ), //i
      .mig_user_data_valid  ( mig_user_data_valid  ), //i
      .mig_auto_ref_req     ( mig_auto_ref_req     ), //i
      .mig_ar_done          ( mig_ar_done          ), //i
      .pi_blk_sel           ( pi_blk_sel           ), //i
      .pi_addr              ( pi_addr              ), //i
      .pi_wr_en             ( pi_wr_en             ), //i
      .pi_rd_en             ( pi_rd_en             ), //i
      .pi_wr_data           ( pi_wr_data           ), //i
      .pi_rd_data           ( pi_rd_data           ), //o
      .rd_mem_req           ( rd_mem_req           ), //i
      .rd_mem_addr          ( rd_mem_addr          ), //i
      .rd_xfr_len           ( rd_xfr_len           ), //i
      .rd_mem_grant         ( rd_mem_grant         ), //o
      .rd_data              ( rd_data              ), //o
      .rd_data_valid        ( rd_data_valid        )  //o
   );



   ddr2_512M16_mig u_mem_controller
   (
      // Clock and reset for MIG 
      .sys_clk_in                   ( clk         ),//i      
      .reset_in_n                   ( rst         ),//i
      // DDR2 interface  
      .cntrl0_ddr2_ras_n            (ddr2_ras_n_fpga),
      .cntrl0_ddr2_cas_n            (ddr2_cas_n_fpga),
      .cntrl0_ddr2_we_n             (ddr2_we_n_fpga),
      .cntrl0_ddr2_cs_n             (ddr2_cs_n_fpga),
      .cntrl0_ddr2_cke              (ddr2_cke_fpga),
      .cntrl0_ddr2_odt              (ddr2_odt_fpga),
      .cntrl0_ddr2_dm               (ddr2_dm_fpga),
      .cntrl0_ddr2_dq               (ddr2_dq_fpga),
      .cntrl0_ddr2_dqs              (ddr2_dqs_fpga),
      .cntrl0_ddr2_dqs_n            (ddr2_dqs_n_fpga),
      .cntrl0_ddr2_ck               (ddr2_clk_fpga),
      .cntrl0_ddr2_ck_n             (ddr2_clk_n_fpga),
      .cntrl0_ddr2_ba               (ddr2_ba_fpga),
      .cntrl0_ddr2_a                (ddr2_address_fpga),

      // Mih interface 

      .cntrl0_burst_done            (mig_burst_done),
      .cntrl0_init_done             (mig_init_done),
      .cntrl0_ar_done               (mig_ar_done),
      .cntrl0_user_data_valid       (mig_user_data_valid),
      .cntrl0_auto_ref_req          (mig_auto_ref_req),
      .cntrl0_user_cmd_ack          (mig_user_cmd_ack),
      .cntrl0_user_command_register (mig_user_input_cmds),
      .cntrl0_clk_tb                (mig_clk0),
      .cntrl0_clk90_tb              (mig_clk90),
      .cntrl0_sys_rst_tb            (mig_rst0),
      .cntrl0_sys_rst90_tb          (mig_rst90),
      .cntrl0_sys_rst180_tb         (mig_rst180),
      .cntrl0_user_output_data      (mig_user_output_data),
      .cntrl0_user_input_data       (mig_user_input_data),
      .cntrl0_user_input_address    (mig_user_input_addr),
      .cntrl0_user_data_mask        (mig_user_input_mask), 
      .cntrl0_rst_dqs_div_in        (rst_dqs_div_loop),
      .cntrl0_rst_dqs_div_out       (rst_dqs_div_loop)
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



  assign mem_clk0   =  mig_clk0 ; 
  assign mem_clk90  =  mig_clk90;
  assign mem_rst0   =  mig_rst0 ; 
  assign mem_rst90  =  mig_rst90;
  assign mem_rst180 =  mig_rst180 ; 
 
  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  task write_reg ( input [3:0] addr, input [7:0] data ) ; 
     pi_blk_sel = 1'b1 ; 
     pi_wr_en   = 1'b1 ; 
     pi_addr    = addr ; 
     pi_wr_data    = data ; 
     @(posedge pi_clk ) ;  
     @(posedge pi_clk ) ;  
     pi_blk_sel = 1'b0 ; 
     pi_wr_en   = 1'b0 ; 
     @(posedge pi_clk ) ;  
  endtask    
  
  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  // CK(Avg) of Micron 512Mb DDR2 -5E is [5ns,8ns] Or [125MHz, 200Mhz] 
  always #4ns clk = ~ clk ;  // CK=8ns or 125Mhz 

  always #10ns pi_clk = ~ pi_clk ; 
   
  

  //*******************************************************************//
  //     Main test                                                     // 
  //*******************************************************************//

  initial begin 
     rst   =  1'b1; clk   =  1'b0;  
     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #5 rst = 1'b1;   
  end

  initial begin 
     logic [15:0] addr = 16'h0008  ; 
     pi_rst   =  1'b0; pi_clk   =  1'b0;  
     pi_blk_sel = 1'b0 ; 
     pi_rd_en   = 1'b0 ; 
     pi_wr_en   = 1'b0 ; 
     
     repeat (100) @(posedge pi_clk ) ; 
     #5 pi_rst = 1'b0;   

     repeat (20) @(posedge pi_clk ) ; 
     
     do 
     begin  
        pi_blk_sel = 1'b0 ; 
        pi_rd_en   = 1'b0 ; 
        repeat (20) @(posedge pi_clk ) ; 
        pi_blk_sel = 1'b1 ; 
        pi_rd_en   = 1'b1 ; 
        pi_addr    = 4'h0 ; 
        @(posedge pi_clk ) ;  
        @(posedge pi_clk ) ;  
     end 
     while ( pi_rd_data[0] == 1'b1 )  ;  
     pi_blk_sel = 1'b0 ; 
     pi_rd_en   = 1'b0 ; 

     write_reg( 4'h1, 8'h21 ) ; 
     write_reg( 4'h2, 8'h43 ) ; 
     write_reg( 4'h3, 8'h65 ) ; 
     write_reg( 4'h4, 8'h87 ) ; 
     write_reg( 4'h5, 8'ha9 ) ; 
     write_reg( 4'h6, 8'hcb ) ; 
     write_reg( 4'h7, 8'hed ) ; 
     write_reg( 4'h8, 8'hff ) ; 
      
     write_reg( 4'h9, 8'h00 ) ; 
     write_reg( 4'ha, 8'h00 ) ; 
     write_reg( 4'hb, 8'h00 ) ; 
     
     write_reg( 4'h0, 8'h01 ) ; 
   

     for ( int i=1 ; i <= 255 ; i++ ) begin 
         for ( int j=1 ; j <= 8 ; j++ ) begin 
            write_reg( j, i ) ; 
         end
         write_reg( 4'h9, addr[7:0] ) ; 
         write_reg( 4'ha, addr[15:8] ) ; 
         write_reg( 4'h0, 8'h01 ) ; 
         $display(" Write 0x%16h to 0x%h" , i, addr ) ;  
         addr = addr + 16'h08 ; 
     end 


     repeat (20) @(negedge mem_clk0 ) ; 
     frame_buf_inst.rd_go = 1'b1 ; 
     @(negedge mem_clk0 ) ; 
     frame_buf_inst.rd_go = 1'b0 ; 


  end 

  initial begin 
      #1ms  $finish ; 
  end 

  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
  end




endmodule 
