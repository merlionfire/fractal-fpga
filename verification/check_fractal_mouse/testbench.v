//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    frac_calc 
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

`timescale 1ns / 100ps

module testbench  ( ) ; 

`include "vga_color_def.vh" 

   parameter  REG_DISP_BLK_ADDR  =  4'h0 ; 
   parameter  REG_DDR2_MGR_ADDR  =  4'h1 ;  
   parameter  REG_FRAC_UNIT_ADDR =  4'h2 ;  
   parameter  REG_MOUSE_ADDR     =  4'h3 ;

   parameter  DISP_BLK_SEL_BIT   =  4'h0 ;  
   parameter  DDR2_MGR_SEL_BIT   =  4'h1 ;    
   parameter  FRAC_UNIT_SEL_BIT  =  4'h2 ; 
   parameter  MOUSE_SEL_BIT      =  4'h3 ;

   // --- clock and reset 
   logic        clk;
   logic        rst;

   // PS/2 interface 
   wire              ps2_clk;
   wire              ps2_data;
   
   // --- VGA Singals
   logic [3:0]  vga_red; 
   logic [3:0]  vga_green; 
   logic [3:0]  vga_blue; 
   logic        vga_h_sync;
   logic        vga_v_sync;
   logic [7:0 ] port_id, out_port,  in_port;
   logic        write_strobe,  read_strobe,  interrupt,  interrupt_ack ; 

   reg  [15:0]  pi_blk_sel ; 
   logic [3:0]  pi_addr;
   logic        pi_wr_en, pi_rd_en ; 
   logic [7:0]  pi_wr_data, pi_disp_rd_data,pi_mouse_rd_data  ; 

   logic         req_rd_ddr;    
   logic [12:0]  req_ddr_addr_row;
   logic [10:0]  linebuf_rd_addr;
   logic [15:0 ] linebuf_rd_data;
   logic         linebuf_rd_en;      

   // connection siganls between frac_disp and mouse 

   logic [10:0]  pixel_x; 
   logic [10:0]  pixel_y; 
   logic         cursor_on;
   logic [2:0]   cursor_color;  

   
   // PS/2 device interface singals  
   logic   ps2_device_soft_rst ; 

   // Diagnostic signals 

   //*************************************************************//
   // Module instatiation 
   //*************************************************************//
/*
   picoblaze  picoblaze_inst (
      .clk           ( clk           ), //i
      .reset         ( rst           ), //i
      //.reset         ( 1'b1          ), //i
      .port_id       ( port_id       ), //o
      .write_strobe  ( write_strobe  ), //o
      .read_strobe   ( read_strobe   ), //o
      .out_port      ( out_port      ), //o
      .in_port       ( in_port       ), //i
      .interrupt     ( interrupt     ), //i
      .interrupt_ack ( interrupt_ack )  //o
   );
*/


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
      .pixel_x      ( pixel_x      ), //i
      .pixel_y      ( pixel_y      ), //i
      .cursor_on    ( cursor_on    ), //o
      .cursor_color ( cursor_color ), //o
      .ps2_clk      ( ps2_clk      ), //i
      .ps2_data     ( ps2_data     )  //i
   );


  ps2_mouse_top #(
  ) ps2_mouse_top_inst  (       
      .clk           ( clk ),
      .rst           ( ps2_device_soft_rst ),
      .ps2_clk       ( ps2_clk      ), 
      .ps2_data      ( ps2_data     )
  );

  pullup( ps2_data ) ;
  pullup( ps2_clk  ) ; 

   //*************************************************************//
   // Register address decoder   
   //*************************************************************//
  
   always @(*) begin  
      pi_blk_sel   =  4'h0;    
      case  ( port_id[7:4] ) 
         REG_DISP_BLK_ADDR    :  pi_blk_sel[DISP_BLK_SEL_BIT]   =  1'b1 ; 
         REG_DDR2_MGR_ADDR    :  pi_blk_sel[DDR2_MGR_SEL_BIT]   =  1'b1 ; 
         REG_FRAC_UNIT_ADDR   :  pi_blk_sel[FRAC_UNIT_SEL_BIT]  =  1'b1 ; 
         REG_MOUSE_ADDR       :  pi_blk_sel[MOUSE_SEL_BIT]      =  1'b1 ; 
      endcase 
   end

   //*************************************************************//
   // Control singals related to char window 
   //*************************************************************//

   assign   pi_wr_en    =  write_strobe ;
   assign   pi_rd_en    =  read_strobe ; 
   assign   pi_wr_data  =  out_port ; 
   assign   in_port     =  pi_disp_rd_data | pi_mouse_rd_data ;  
   assign   pi_addr     =  port_id[3:0] ; 


   //*************************************************************//
   // FSDB dumper
   //*************************************************************//

   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
   end


   //*************************************************************//
   // Clock generator
   //************************************************************//

   always #10ns clk = ~ clk ; 


   //*************************************************************//
   // Task and function definition 
   //*************************************************************//


   task write_reg( input logic [7:0]   addr, logic [7:0] data )  ;

      @( posedge clk )  ; 
      #1 ; 
      write_strobe   =  1'b1 ; 
      port_id        =  addr ;
      out_port       =  data ; 
      @( posedge clk )  ; 
      #1 ; 
      write_strobe   =  1'b0 ; 
      @( posedge clk )  ; 
   endtask 



   task read_reg( input logic [7:0]   addr,  output logic [7:0] data_out  )  ;

      @( posedge clk )  ; 
      #1 ; 
      port_id        =  addr ;
      read_strobe    =  1'b1 ; 
      @( posedge clk )  ; 
      data_out       =  in_port ; 
      #1 ; 
      read_strobe   =  1'b0 ; 
      @( posedge clk )  ; 
   endtask  
   



   //*************************************************************//
   //    Main code for testing  
   //*************************************************************//

   initial begin 
      clk   =  1'b0; 
      rst   =  1'b1 ; 
      ps2_device_soft_rst =   1'b1 ; 
      repeat (20) @( negedge clk )  ; 
      ps2_device_soft_rst =   1'b0 ; 
      repeat (20) @( negedge clk )  ; 
      rst   =  1'b0 ; 
      repeat (20) @( negedge clk )  ; 
      write_reg( 8'h00 ,8'h02 ) ; 
      
      #100ms $finish ;       
   end 



endmodule    
