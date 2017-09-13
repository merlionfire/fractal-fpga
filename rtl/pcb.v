`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    06:16:55 04/12/2015 
// Design Name: 
// Module Name:    pcb 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module pcb(
    input         CLK_50M,
    input         CLK_AUX,
    output [3:0]  VGA_B,
    output [3:0]  VGA_G,
    output [3:0]  VGA_R,
    output        VGA_HSYNC,
    output        VGA_VSYNC,

    inout         PS2_CLK1,
    inout         PS2_DATA1,

    input  wire   RS232_DCE_RXD,
    output wire   RS232_DCE_TXD,

    input         BTN_SOUTH , 
    input [3:0]   SW,

    output wire [12:0] SD_A,
    output wire  [1:0] SD_BA,
    output wire        SD_CAS,
    output wire        SD_CK_P,
    output wire        SD_CK_N,
    output wire        SD_CKE,
    output wire        SD_CS,
    inout  wire [15:0] SD_DQ,
    output wire        SD_LDM,
    output wire        SD_RAS,
    output wire        SD_UDM,
    output wire        SD_ODT,
    output wire        SD_UDQS_P,
    output wire        SD_UDQS_N,
    output wire        SD_LDQS_P,
    output wire        SD_LDQS_N,
    output wire        SD_WE,
    output wire        SD_LOOP_OUT,
    input  wire        SD_LOOP_IN
);
    

   wire clk_50m_i, clk_50m_o, clk_100m, clk_75m, clk_25m,  dcm_locked, rst, global_rst ; 
   wire mem_clk_s, mem_rst_s_n ;  

   wire  reset_over_remap ; 
   wire  sw_0_filter, fractal_rst_mask ;
   wire  btn_south_io, btn_south_io_filter ; 

   wire        fractal_clk,  fractal_rst, vga_h_sync,  vga_v_sync ; 
   wire [3:0 ] vga_red, vga_green, vga_blue;
  
   //synthesis attribute keep of fractal_rst_mask is "true"

   //  Instantiate the module
   clock_gen clock_gen_inst (
       .CLKIN_IN        (  CLK_50M    ), 
       .CLKDV_OUT       (  clk_25m    ), 
       .CLKFX_OUT       (  clk_75m    ), 
       .CLKIN_IBUFG_OUT (  clk_50m_i  ), 
       .CLK0_OUT        (  clk_50m_o  ), 
       .CLK2X_OUT       (  clk_100m   ), 
       .LOCKED_OUT      (  dcm_locked )
   );

   synchro #(.INITIALIZE("LOGIC1"))
   synchro_reset (.async(!dcm_locked),.sync(rst),.clk(clk_75m));

   btn_filter  #(.PIN_NUM (2 ) ) top_btn_filter_inst (
     .clk     ( clk_75m   ),
     .pin_in  ( { btn_south_io,        SW[0]        } ),
     .pin_out ( { btn_south_io_filter, sw_0_filter  } ) 
   );

   //synchro synchro_mem_reset_n (.async(dcm_locked),.sync(mem_rst_s_n),.clk(clk_100m));

/*
   fractal_top  fractal_top_inst (
      .clk        ( fractal_clk        ), //i
      .rst        ( rst        ), //i
      .vga_red    ( vga_red    ), //o
      .vga_green  ( vga_green  ), //o
      .vga_blue   ( vga_blue   ), //o
      .vga_h_sync ( vga_h_sync ), //o
      .vga_v_sync ( vga_v_sync )  //o
   );
*/

   fractal_top  fractal_top_inst (
      .clk               ( fractal_clk       ), //i
      .mem_clk_s         ( mem_clk_s         ), //i
      .rst               ( fractal_rst       ), //i
      .mem_rst_s_n       ( mem_rst_s_n       ), //i
      .reset_over_remap  ( reset_over_remap  ), //o
      .ps2_clk           ( PS2_CLK1          ), //io
      .ps2_data          ( PS2_DATA1         ), //io
      .uart_rx           ( RS232_DCE_RXD     ), //i
      .uart_tx           ( RS232_DCE_TXD     ), //o
      .vga_red           ( vga_red           ), //o
      .vga_green         ( vga_green         ), //o
      .vga_blue          ( vga_blue          ), //o
      .vga_h_sync        ( vga_h_sync        ), //o
      .vga_v_sync        ( vga_v_sync        ), //o
      .ddr2_dq_fpga      ( SD_DQ             ), //o
      .ddr2_dqs_fpga     ( {SD_UDQS_P,SD_LDQS_P}), //o
      .ddr2_dqs_n_fpga   ( {SD_UDQS_N,SD_LDQS_N}), //o
      .ddr2_dm_fpga      ( {SD_UDM,SD_LDM}   ), //o
      .ddr2_clk_fpga     ( SD_CK_P           ), //o
      .ddr2_clk_n_fpga   ( SD_CK_N           ), //o
      .ddr2_address_fpga ( SD_A              ), //o
      .ddr2_ba_fpga      ( SD_BA             ), //o
      .ddr2_ras_n_fpga   ( SD_RAS            ), //o
      .ddr2_cas_n_fpga   ( SD_CAS            ), //o
      .ddr2_we_n_fpga    ( SD_WE             ), //o
      .ddr2_cs_n_fpga    ( SD_CS             ), //o
      .ddr2_cke_fpga     ( SD_CKE            ), //o
      .ddr2_odt_fpga     ( SD_ODT            ), //o
      .ddr2_rst_dqs_div_in  ( SD_LOOP_IN     ), //i
      .ddr2_rst_dqs_div_out ( SD_LOOP_OUT    )  //o
   );

/*
   timing_test  timing_test_inst (
      .clk        ( clk_75m    ), //i
      .rst        ( rst        ), //i
      .vga_red    ( vga_red    ), //o
      .vga_green  ( vga_green  ), //o
      .vga_blue   ( vga_blue   ), //o
      .vga_h_sync ( vga_h_sync ), //o
      .vga_v_sync ( vga_v_sync )  //o
   );
*/

   // VGA singals connection 
   assign   fractal_clk   =   clk_75m ;  
   assign   fractal_rst   =   rst | fractal_rst_mask | global_rst ;  
   assign   VGA_HSYNC     =   vga_h_sync ; 
   assign   VGA_VSYNC     =   vga_v_sync ; 
   assign   VGA_B         =   vga_blue ; 
   assign   VGA_G         =   vga_green ; 
   assign   VGA_R         =   vga_red ; 

   assign   mem_clk_s    = CLK_AUX  ;   // 133Mhz 
   assign  mem_rst_s_n = dcm_locked & ( ~ global_rst ) ; 
   //assign  mem_rst_s_n = dcm_locked  ; 
	
   assign   fractal_rst_mask = sw_0_filter ;   
   assign   btn_south_io  = BTN_SOUTH ;  
   assign   global_rst    = btn_south_io_filter | reset_over_remap ; 

   //IBUFG mem_clk_ibuf ( .I(clk_100m), .O(mem_clk_s ) ) ;  
endmodule
