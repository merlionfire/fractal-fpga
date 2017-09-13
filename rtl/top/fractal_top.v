//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    fractal_top 
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

`include "ddr2_512M16_mig_parameters_0.v"

module fractal_top 
#( 
   parameter FONT_WIDTH_N_BITS = 3,  
   parameter FONT_HEIGH_N_BITS = 4  
)
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        mem_clk_s,
   input  wire        rst,
   input  wire        mem_rst_s_n,
   output wire        reset_over_remap,

   // PS/2 interface 
   inout              ps2_clk,
   inout              ps2_data,
   
   // uart interface 
   input  wire        uart_rx,
   output wire        uart_tx,               

   // --- VGA Singals
   output wire [3:0]  vga_red, 
   output wire [3:0]  vga_green, 
   output wire [3:0]  vga_blue, 
   output wire        vga_h_sync,
   output wire        vga_v_sync,

   // --- MIG and ddr2 device interface
   inout  wire [`DATA_WIDTH-1:0]         ddr2_dq_fpga,
   inout  wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_fpga,
   inout  wire [`DATA_STROBE_WIDTH-1:0]  ddr2_dqs_n_fpga,
   output wire [`DATA_MASK_WIDTH-1:0]    ddr2_dm_fpga,
   output wire [`CLK_WIDTH-1:0]          ddr2_clk_fpga,
   output wire [`CLK_WIDTH-1:0]          ddr2_clk_n_fpga,
   output wire [`ROW_ADDRESS-1:0]        ddr2_address_fpga,
   output wire [`BANK_ADDRESS-1:0]       ddr2_ba_fpga,
   output wire                           ddr2_ras_n_fpga,
   output wire                           ddr2_cas_n_fpga,
   output wire                           ddr2_we_n_fpga,
   output wire                           ddr2_cs_n_fpga,
   output wire                           ddr2_cke_fpga,
   output wire                           ddr2_odt_fpga,
   input  wire                           ddr2_rst_dqs_div_in,
   output wire                           ddr2_rst_dqs_div_out
) ; 

`include "vga_color_def.vh" 

   parameter  REG_DISP_BLK_ADDR  =  4'h0 ; 
   parameter  REG_DDR2_MGR_ADDR  =  4'h1 ;  
   parameter  REG_FRAC_UNIT_ADDR =  4'h2 ;  
   parameter  REG_MOUSE_ADDR     =  4'h3 ;
   parameter  REG_ALU_ADDR       =  4'h4 ;
   parameter  REG_UART_ADDR      =  4'h5 ;
   parameter  REG_CPU_ADDR       =  4'h6 ;

   parameter  DISP_BLK_SEL_BIT   =  4'h0 ;  
   parameter  DDR2_MGR_SEL_BIT   =  4'h1 ;    
   parameter  FRAC_UNIT_SEL_BIT  =  4'h2 ; 
   parameter  MOUSE_SEL_BIT      =  4'h3 ;
   parameter  ALU_SEL_BIT        =  4'h4 ;
   parameter  UART_SEL_BIT       =  4'h5 ;
   parameter  CPU_SEL_BIT        =  4'h6 ;

   wire [7:0 ] port_id, out_port,  in_port;
   wire        write_strobe,  read_strobe,  interrupt,  interrupt_ack ; 
   wire        interrupt_mouse, interrupt_uart, interrupt_alu ; 
   reg  [15:0] pi_blk_sel ; 
   wire [3:0]  pi_addr;
   wire        pi_wr_en, pi_rd_en ; 
   wire [7:0]  pi_wr_data, pi_disp_rd_data, pi_ddr2_mgr_rd_data, pi_unit_rd_data, pi_mouse_rd_data, pi_alu_rd_data, pi_uart_rd_data, pi_cpu_rd_data  ; 
   wire        cpu_rst ; 

   wire         req_rd_ddr;    
   wire [12:0]  req_ddr_addr_row;
   wire [10:0]  linebuf_rd_addr;
   wire [15:0 ] linebuf_rd_data;
   wire         linebuf_rd_en;      

   // connection siganls between frac_disp and mouse 

   wire [10:0] pixel_x; 
   wire [10:0] pixel_y; 
   wire        cursor_on;
   wire [2:0]  cursor_color;  

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
  

   // Diagnostic signals 

   //*************************************************************//
   // Module instatiation 
   //*************************************************************//

   cpu_top  cpu_top_inst (
      .clk              ( clk              ), //i
      .reset            ( rst          ), //i
      .port_id          ( port_id          ), //o
      .write_strobe     ( write_strobe     ), //o
      .read_strobe      ( read_strobe      ), //o
      .out_port         ( out_port         ), //o
      .in_port          ( in_port          ), //i
      .interrupt_uart   ( interrupt_uart   ), //i
      .interrupt_alu    ( interrupt_alu    ), //i
      .interrupt_mouse  ( interrupt_mouse  ), //i
      .interrupt_ack    ( interrupt_ack    ), //o
      .pi_blk_sel       ( pi_blk_sel[CPU_SEL_BIT] ), //i
      .pi_addr          ( pi_addr          ), //i
      .pi_wr_en         ( pi_wr_en         ), //i
      .pi_rd_en         ( pi_rd_en         ), //i
      .pi_wr_data       ( pi_wr_data       ), //i
      .pi_rd_data       ( pi_cpu_rd_data   ), //o
      .reset_over_remap ( reset_over_remap )  //o
   );


   frac_unit_top  frac_unit_top_inst (
      .clk        ( clk        ), //i
      .rst        ( rst        ), //i
      .pi_blk_sel ( pi_blk_sel[FRAC_UNIT_SEL_BIT]  ), //i
      .pi_addr    ( pi_addr    ), //i
      .pi_wr_en   ( pi_wr_en   ), //i
      .pi_rd_en   ( pi_rd_en   ), //i
      .pi_wr_data ( pi_wr_data ), //i
      .pi_rd_data ( pi_unit_rd_data )  //o
   );


   frac_disp  frac_disp_inst (
      .clk              ( clk              ), //i
      .rst              ( rst              ), //i
      .pi_blk_sel       ( pi_blk_sel[DISP_BLK_SEL_BIT] ), //i
      .pi_addr          ( pi_addr          ), //i
      .pi_wr_en         ( pi_wr_en         ), //i
      .pi_rd_en         ( pi_rd_en         ), //i
      .pi_wr_data       ( pi_wr_data       ), //i
      .pi_rd_data       ( pi_disp_rd_data  ), //o
      .vga_red          ( vga_red          ), //o
      .vga_green        ( vga_green        ), //o
      .vga_blue         ( vga_blue         ), //o
      .vga_h_sync       ( vga_h_sync       ), //o
      .vga_v_sync       ( vga_v_sync       ), //o
      .pixel_x          ( pixel_x          ), //o
      .pixel_y          ( pixel_y          ), //o
      .cursor_on        ( cursor_on        ), //i
      .cursor_color     ( cursor_color     ), //i
      .req_rd_ddr       ( req_rd_ddr       ), //o
      .req_ddr_addr_row ( req_ddr_addr_row ), //o
      .linebuf_rd_en    ( linebuf_rd_en    ), //o
      .linebuf_rd_addr  ( linebuf_rd_addr  ), //o
      .linebuf_rd_data  ( linebuf_rd_data  )  //i
   );
  
   mouse_top  mouse_top_inst (
      .clk          ( clk          ), //i
      .rst          ( rst          ), //i
      .pi_blk_sel   ( pi_blk_sel[MOUSE_SEL_BIT] ), //i
      .pi_addr      ( pi_addr      ), //i
      .pi_wr_en     ( pi_wr_en     ), //i
      .pi_rd_en     ( pi_rd_en     ), //i
      .pi_wr_data   ( pi_wr_data   ), //i
      .pi_rd_data   ( pi_mouse_rd_data   ), //o
      .interrupt_ack( interrupt_ack), //i
      .interrupt    ( interrupt_mouse    ), //o
      .pixel_x      ( pixel_x      ), //i
      .pixel_y      ( pixel_y      ), //i
      .cursor_on    ( cursor_on    ), //o
      .cursor_color ( cursor_color ), //o
      .ps2_clk      ( ps2_clk      ), //i
      .ps2_data     ( ps2_data     )  //i
   );

   frame_buf  frame_buf_inst (
      .mem_clk0        ( mem_clk0        ), //i
      .mem_clk90       ( mem_clk90       ), //i
      .mem_rst         ( mem_rst180      ), //i
      .disp_clk        ( clk             ), //i
      .rd_mem_req      ( rd_mem_req      ), //o
      .rd_mem_addr     ( rd_mem_addr     ), //o
      .rd_xfr_len      ( rd_xfr_len      ), //o
      .rd_mem_grant    ( rd_mem_grant    ), //i
      .rd_data         ( rd_data         ), //i
      .rd_data_valid   ( rd_data_valid   ), //i
      .rd_go           ( req_rd_ddr      ), //i
      .req_addr_row    ( req_ddr_addr_row), //i
      .linebuf_rd_en   ( linebuf_rd_en   ), //i
      .linebuf_rd_addr ( linebuf_rd_addr ), //o
      .linebuf_rd_data ( linebuf_rd_data )  //i
   );


   ddr2_mgr  ddr2_mgr_inst (
      .clk0                 ( mem_clk0             ), //i
      .rst0                 ( mem_rst0             ), //i
      .clk90                ( mem_clk90            ), //i
      .rst90                ( mem_rst90            ), //i
      .rst180               ( mem_rst180           ), //i
      .pi_clk               ( clk                  ), //i
      .pi_rst               ( rst                  ), //i
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
      .pi_blk_sel           ( pi_blk_sel[DDR2_MGR_SEL_BIT] ), //i
      .pi_addr              ( pi_addr              ), //i
      .pi_wr_en             ( pi_wr_en             ), //i
      .pi_rd_en             ( pi_rd_en             ), //i
      .pi_wr_data           ( pi_wr_data           ), //i
      .pi_rd_data           ( pi_ddr2_mgr_rd_data  ), //o
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
      .sys_clk_in                   ( mem_clk_s     ),//i      
      .reset_in_n                   ( mem_rst_s_n   ),//i
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

      // Mig interface 

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
      .cntrl0_rst_dqs_div_in        (ddr2_rst_dqs_div_in),
      .cntrl0_rst_dqs_div_out       (ddr2_rst_dqs_div_out)
   );

   alu  alu_inst (
      .clk           ( clk           ), //i
      .rst           ( rst           ), //i
      .pi_blk_sel    ( pi_blk_sel[ALU_SEL_BIT]    ), //i
      .pi_addr       ( pi_addr       ), //i
      .pi_wr_en      ( pi_wr_en      ), //i
      .pi_rd_en      ( pi_rd_en      ), //i
      .pi_wr_data    ( pi_wr_data    ), //i
      .pi_rd_data    ( pi_alu_rd_data    ), //o
      .interrupt_ack ( interrupt_ack ), //i
      .interrupt     ( interrupt_alu )  //o
   );

   uart  uart_inst (
      .clk           ( clk           ), //i
      .rst           ( rst           ), //i
      .rx            ( uart_rx       ), //i
      .tx            ( uart_tx       ), //o
      .pi_blk_sel    ( pi_blk_sel[UART_SEL_BIT]    ), //i
      .pi_addr       ( pi_addr       ), //i
      .pi_wr_en      ( pi_wr_en      ), //i
      .pi_rd_en      ( pi_rd_en      ), //i
      .pi_wr_data    ( pi_wr_data    ), //i
      .pi_rd_data    ( pi_uart_rd_data    ), //o
      .interrupt_ack ( interrupt_ack ), //i
      .interrupt     ( interrupt_uart     )  //o
   );
   
   //*************************************************************//
   // Register address decoder   
   //*************************************************************//
  
   always @(*) begin  
      pi_blk_sel   =  'h0;    
      case  ( port_id[7:4] ) 
         REG_DISP_BLK_ADDR    :  pi_blk_sel[DISP_BLK_SEL_BIT]   =  1'b1 ; 
         REG_DDR2_MGR_ADDR    :  pi_blk_sel[DDR2_MGR_SEL_BIT]   =  1'b1 ; 
         REG_FRAC_UNIT_ADDR   :  pi_blk_sel[FRAC_UNIT_SEL_BIT]  =  1'b1 ; 
         REG_MOUSE_ADDR       :  pi_blk_sel[MOUSE_SEL_BIT]      =  1'b1 ; 
         REG_ALU_ADDR         :  pi_blk_sel[ALU_SEL_BIT]        =  1'b1 ; 
         REG_UART_ADDR        :  pi_blk_sel[UART_SEL_BIT]       =  1'b1 ; 
         REG_CPU_ADDR         :  pi_blk_sel[CPU_SEL_BIT]        =  1'b1 ; 
      endcase 
   end

   //*************************************************************//
   // Control singals related to char window 
   //*************************************************************//

   assign   pi_wr_en    =  write_strobe ;
   assign   pi_rd_en    =  read_strobe ; 
   assign   pi_wr_data  =  out_port ; 
   assign   in_port     =    pi_ddr2_mgr_rd_data 
                           | pi_disp_rd_data
                           | pi_unit_rd_data 
                           | pi_mouse_rd_data 
                           | pi_alu_rd_data 
                           | pi_uart_rd_data
                           | pi_cpu_rd_data ;  
   assign   pi_addr     =  port_id[3:0] ; 

   assign   mem_clk0   =  mig_clk0 ; 
   assign   mem_clk90  =  mig_clk90;
   assign   mem_rst0   =  mig_rst0 ; 
   assign   mem_rst90  =  mig_rst90;
   assign   mem_rst180 =  mig_rst180 ; 

   //assign   cpu_rst    =  rst | reset_over_remap ; 

endmodule    
