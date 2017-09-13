//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    06/09/2015 
// Design Name: 
// Module Name:    frac_disp 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    Top module related to VGA display  
//
// Dependencies: 

//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module frac_disp 
#( 
   parameter FONT_WIDTH_N_BITS = 3,  
   parameter FONT_HEIGH_N_BITS = 4  
)
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   
   // --- uP interface 
   input  wire        pi_blk_sel,
   input  wire [3:0]  pi_addr,
   input  wire        pi_wr_en,
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data,

   // --- VGA interface
   output wire [3:0]  vga_red, 
   output wire [3:0]  vga_green, 
   output wire [3:0]  vga_blue, 
   output wire        vga_h_sync,
   output wire        vga_v_sync,

   // --- Mouse interface
   output wire [10:0] pixel_x, 
   output wire [10:0] pixel_y, 
   input  wire        cursor_on,
   input  wire [2:0]  cursor_color,  

   // --- frame_buf interface
   output reg         req_rd_ddr,   
   output reg  [12:0] req_ddr_addr_row,  
   output reg         linebuf_rd_en,  
   output reg  [10:0] linebuf_rd_addr,  
   input  wire [15:0] linebuf_rd_data 
) ; 

`include "vga_color_def.vh" 
`include "ddr2_512M16_mig_parameters_0.v"

   wire h_sync, v_sync, vga_on, border_on, h_blnk, v_blnk ; 

   wire [10:0] font_bitmap_addr; 
   wire [7:0]  font_bitmap_byte; 

   reg  [10:0] cb_rd_addr;
   wire [7:0]  cb_rd_data;
   reg  [10:0] cb_wr_addr;
   wire        cb_wr_en;
   wire [7:0]  cb_wr_data;
   wire [7:0]  cw_x_orig, cw_y_orig , cw_x_size, cw_y_size, cw_row, cw_col ;  
   wire [10:0] cb_addr_orig ;   
   reg  cwindow_l, cwindow_r, cwindow_t, cwindow_b, cwindow_on, cwindow_on_dly ;
   reg  [1:0]  pixel_y_dly    [0:FONT_HEIGH_N_BITS-1] ; 
   wire [FONT_HEIGH_N_BITS-1:0] font_y_idx; 

   reg  [2:0]   pixel_x_dly   [0:FONT_WIDTH_N_BITS-1] ; 
   wire [FONT_WIDTH_N_BITS-1:0] font_x_idx; 

   reg  [2:0]  vga_on_dly ; 
   reg  [2:0]  border_on_dly ; 
   reg  [3:0]  h_sync_dly, v_sync_dly ; 
   wire [2:0]  char_fg_rgl, char_bg_rgl, graph_bg_rgl, graph_fg_rgl ; 
   reg  [2:0]  rgl ; 
   wire        cw_row_col_update , cb_wr_addr_inc ; 
 
   wire        buffer_init_done; 

   wire        rst_internal ;

   wire h_sync_visible, h_sync_visible_pg_pulse ;
   reg  h_sync_visible_1d, req_rd_ddr_pulse, req_rd_ddr_pulse_1d , req_rd_ddr_pulse_2d ; 

   //*************************************************************//
   // Module instiataion 
   //*************************************************************//

   char_buffer_wrapper  char_buffer_wrapper_inst (
      .clk        ( clk        ), //i
      .cb_rd_addr ( cb_rd_addr ), //i
      .cb_rd_data ( cb_rd_data ), //o
      .cb_wr_addr ( cb_wr_addr ), //i
      .cb_wr_en   ( cb_wr_en   ), //i
      .cb_wr_data ( cb_wr_data )  //i
   );


   ascii_font16X8  ascii_font16X8_inst (
      .clk               ( clk              ), //i
      .font_bitmap_addr  ( font_bitmap_addr ), //i
      .font_bitmap_byte  ( font_bitmap_byte )  //o
   );


   disp_pi  disp_pi_inst (
      .clk               ( clk               ), //i
      .rst               ( rst               ), //i
      .blk_sel           ( pi_blk_sel        ), //i
      .addr              ( pi_addr           ), //i
      .wr_en             ( pi_wr_en          ), //i
      .rd_en             ( pi_rd_en          ), //i
      .wr_data           ( pi_wr_data        ), //i
      .rd_data           ( pi_rd_data        ), //o
      .cw_x_orig         ( cw_x_orig         ), //o
      .cw_y_orig         ( cw_y_orig         ), //o
      .cw_x_size         ( cw_x_size         ), //o
      .cw_y_size         ( cw_y_size         ), //o
      .cb_wr_addr_inc    ( cb_wr_addr_inc    ), //o
      .buffer_init_done  ( buffer_init_done  ), //o
      .char_fg_rgl       ( char_fg_rgl       ), //o
      .char_bg_rgl       ( char_bg_rgl       ), //o
      .graph_fg_rgl      ( graph_fg_rgl      ), //o
      .graph_bg_rgl      ( graph_bg_rgl      ), //o
      .cb_addr_orig      ( cb_addr_orig      ), //o
      .cb_wr_en          ( cb_wr_en          ), //o
      .cw_row            ( cw_row            ), //o
      .cw_col            ( cw_col            ), //o
      .cw_row_col_update ( cw_row_col_update )  //o
   );

   vga_sync_gen  vga_sync_gen_inst (
      .clk       ( clk       ), //i
      .rst       ( rst_internal       ), //i
      .h_sync    ( h_sync    ), //o
      .v_sync    ( v_sync    ), //o
      .vga_on    ( vga_on    ), //o
      .border_on ( border_on ), //o
      .h_blnk    ( h_blnk    ), //o
      .v_blnk    ( v_blnk    ), //o
      .pixel_x   ( pixel_x   ), //o
      .pixel_y   ( pixel_y   )  //o
   );
   
   

   //*************************************************************//
   // Control singals related to char window 
   //*************************************************************//
   always @( posedge clk ) begin // 1D 
      cwindow_l  <= ( pixel_x[10:FONT_WIDTH_N_BITS] >= cw_x_orig )  ; 
      cwindow_r  <= ( pixel_x[10:FONT_WIDTH_N_BITS] < ( cw_x_orig + cw_x_size ) ) ; 
      cwindow_t  <= ( pixel_y[10:FONT_HEIGH_N_BITS] >= cw_y_orig );
      cwindow_b  <= ( pixel_y[10:FONT_HEIGH_N_BITS] < ( cw_y_orig + cw_y_size ) ) ;
      cwindow_on <= cwindow_l && cwindow_r && cwindow_t && cwindow_b ;  
      cwindow_on_dly <=  cwindow_on ;   
   end


   always @( posedge clk ) begin  // 1D 
      cb_rd_addr <=  cb_addr_orig 
                   + pixel_x[10:FONT_WIDTH_N_BITS] - cw_x_orig 
                   + ( pixel_y[10:FONT_HEIGH_N_BITS] - cw_y_orig ) * cw_x_size ;
   end
       
   // cb_rd_data  2D
   assign   font_bitmap_addr  =  { cb_rd_data[6:0], font_y_idx } ; 
   // font_bitmap_byte 3D

   assign   rst_internal = rst |  ( ~buffer_init_done ) ;  

   always @( posedge clk ) begin    
      if ( cw_row_col_update ) begin 
         cb_wr_addr  <= cb_addr_orig + cw_col  + cw_row * cw_x_size ;  
      end else if ( cb_wr_addr_inc & cb_wr_en ) begin
         cb_wr_addr  <=  cb_wr_addr + 'h1  ;  
      end
   end

   assign   cb_wr_data  = pi_wr_data ;  

   //*************************************************************//
   // Control singals related to fractal bitmap window 
   //*************************************************************//
  


   reg [2:0] pic_rgl ; 
   reg   v_sync_1d ; 
   wire  v_sync_pg_pulse, v_sync_ng_pulse ; 

   always @( posedge clk ) begin    
      linebuf_rd_en   <= vga_on ;    
      linebuf_rd_addr <= { pixel_y[0], pixel_x[9:0] } ;  
   end

   always @(*) begin 
      if ( linebuf_rd_data[0] == 1'b1 ) begin 
         //pic_rgl <= { linebuf_rd_data[12], linebuf_rd_data[8],linebuf_rd_data[4] } ;
         pic_rgl = {  linebuf_rd_data[12], linebuf_rd_data[8], linebuf_rd_data[4] } ;
      end else begin 
         pic_rgl =  linebuf_rd_data[3:1] ;   
      end
   end

   assign v_sync_pg_pulse =   v_sync      & ( ~v_sync_1d ) ; 
   assign v_sync_ng_pulse =   (~ v_sync ) & v_sync_1d      ; 

   assign h_sync_visible = h_sync & ~ v_blnk ; 
   
   always @( posedge clk ) begin    
      h_sync_visible_1d <= h_sync_visible ; 
   end

   assign h_sync_visible_pg_pulse = h_sync_visible & ~ h_sync_visible_1d ; 


   
   
   always @( posedge clk ) begin    
       req_rd_ddr_pulse  <= v_sync_pg_pulse | v_sync_ng_pulse | h_sync_visible_pg_pulse    ; 
       req_rd_ddr_pulse_1d <= req_rd_ddr_pulse ; 
       req_rd_ddr_pulse_2d <= req_rd_ddr_pulse_1d ; 
       if ( req_rd_ddr_pulse == 1'b1 ) begin
         req_rd_ddr  <= 1'b1 ; 
       end else if ( req_rd_ddr_pulse_2d == 1'b1 ) begin 
         req_rd_ddr  <= 1'b0; 
       end
   end

   always @( posedge clk ) begin    
     v_sync_1d   <= v_sync ; 
     if ( v_sync_pg_pulse ) begin 
         req_ddr_addr_row <=  {13{1'b0}} ;          
     end else if  ( v_sync_ng_pulse ) begin 
         req_ddr_addr_row <=  { { 12{1'b0} } , 1'b1 }  ;          
     end else if ( h_sync_visible_pg_pulse ) begin 
         req_ddr_addr_row <= { 3'b000, pixel_y[9:0] } + 2'b10 ;          
     end 
   end 
   
   
   //*************************************************************//
   // Delay singals to synchronize eatch other   
   //*************************************************************//

   genvar   i ; 
   generate
      for ( i=0; i < FONT_HEIGH_N_BITS ; i = i +1 ) begin:delay_pixel_y
         always @( posedge clk ) pixel_y_dly[i][1:0] <= { pixel_y_dly[i][0], pixel_y[i] } ;          
      end
   endgenerate

   generate 
      for ( i=0; i < FONT_HEIGH_N_BITS ; i = i +1 ) begin: font_y_idx_comb 
         assign font_y_idx[i] = pixel_y_dly[i][1] ;  
      end
   endgenerate

   generate
      for ( i=0; i < FONT_WIDTH_N_BITS ; i = i +1 ) begin:delay_pixel_x
         always @( posedge clk ) pixel_x_dly[i][2:0] <= { pixel_x_dly[i][1:0], pixel_x[i] } ;          
      end
   endgenerate

   generate 
      for ( i=0; i < FONT_WIDTH_N_BITS ; i = i +1 ) begin:font_x_idx_comb 
         assign font_x_idx[i] = ~ pixel_x_dly[i][2] ;  
      end
   endgenerate

   always @( posedge clk ) begin  
      vga_on_dly[2:0] <= { vga_on_dly[1:0], vga_on } ; 
      border_on_dly[2:0] <= { border_on_dly[1:0], border_on } ; 
      h_sync_dly[3:0] <= { h_sync_dly[2:0], ~h_sync } ;     
      v_sync_dly[3:0] <= { v_sync_dly[2:0], ~v_sync } ;     
   end


   //*************************************************************//
   // Mux all objects  
   //*************************************************************//

   always @( posedge clk ) begin // 4D 
      if ( vga_on_dly[2] ) begin 
         if ( border_on_dly[2] ) begin 
            rgl   <= WHITE ; 
         end else if ( cursor_on ) begin 
            rgl   <= cursor_color ; 
         end else if ( cwindow_on_dly ) begin  
            rgl   <= font_bitmap_byte[ font_x_idx ] ? char_fg_rgl  :  char_bg_rgl ; 
         end else begin 
            //rgl   <= graph_bg_rgl ; 
            rgl   <= pic_rgl ; 
         end
      end else begin 
         rgl   <= RED ; 
      end
   end


   //*************************************************************//
   // Output interface signals 
   //*************************************************************//

   assign vga_red   =  {4{rgl[2]}} ; 
   assign vga_green =  {4{rgl[1]}} ; 
   assign vga_blue  =  {4{rgl[0]}} ; 

   // vga_h_sync : justed 
   // Signal h_sync should be delayed 4 clocks to be sync with rgl.
   // But observe the visible window is left-shifted 1 colum. 
   // In otjer words, left border line is not shown whereas right border 
   // is shown with extra colum. 
   // 
   // Fix it by left-shifting vga_h_sync 1 colum, 
   // that is, vga_h_sync is from h_sync delayed 3 clock instead of 4   
   // 
   // vga_v_sync is working fine. Both of top and bottom border lines 
   // can be seen. So it is still from 4 clock delayed v_synv
   //
   //assign vga_h_sync  =  h_sync_dly[3] ; 
   assign vga_h_sync  =  h_sync_dly[2] ; 
   assign vga_v_sync  =  v_sync_dly[3] ; 

   //*************************************************************//
   // Monitor  
   //*************************************************************//


   
   




   //*************************************************************//
   // SVA checker  
   //*************************************************************//
   
`ifdef SVA   
   property VGA_ON_VALID ; 
      @( posedge clk ) vga_on_dly[2] |=> vga_h_sync && vga_v_sync ; 
   endproperty    
   assert property ( VGA_ON_VALID ) ; 

   property CHAR_WIN_VALID ; 
      @( posedge clk ) cwindow_on_dly |-> vga_on_dly[2] ; 
   endproperty 
   assert property ( CHAR_WIN_VALID ) ; 

   property FONT_X_IDX_REVERT ;
      @( posedge clk ) $rose(cwindow_on_dly) 
                     |->   ( font_x_idx == 3'h7 ) 
                      ##1  ( font_x_idx == 3'h6 )  
                      ##1  ( font_x_idx == 3'h5 )  
                      ##1  ( font_x_idx == 3'h4 )  
                      ##1  ( font_x_idx == 3'h3 )  
                      ##1  ( font_x_idx == 3'h2 )  
                      ##1  ( font_x_idx == 3'h1 )  
                      ##1  ( font_x_idx == 3'h0 ) ;  
   endproperty 
   assert property ( FONT_X_IDX_REVERT ) ; 

   property CHAR_ADDR_VALID ; 
      @( posedge clk )  $rose( cwindow_on ) && ( pixel_y == 11'h000 )   
                        |-> $past( cb_rd_addr == 11'h000 ) && ( cb_rd_data == 8'h30 ) && ( font_bitmap_addr == ( 7'h30 << 4 ) )  ;
   endproperty 
   assert property ( CHAR_ADDR_VALID ) ; 

`endif

/*
  assert property (  @( posedge clk ) 
      $rose(data_valid) |=> ( state_r == BIT_START ) 
  ) ;      

  assert property (  @(posedge baud_16x_tick ) 
      ( $past(state_r) == IDLE && state_r == BIT_START) 
                               |-> ##16 ( state_r == BIT_0 ) 
                                   ##16 ( state_r == BIT_1 ) 
                                   ##16 ( state_r == BIT_2 ) 
                                   ##16 ( state_r == BIT_3 ) 
                                   ##16 ( state_r == BIT_4 ) 
                                   ##16 ( state_r == BIT_5 ) 
                                   ##16 ( state_r == BIT_6 ) 
                                   ##16 ( state_r == BIT_7 ) 
                                   ##16 ( state_r == BIT_STOP ) 
  ) ; 

  assert property ( @( posedge baud_16x_tick ) 
     (  $fell( serial_out ) && ( state_r == BIT_START ) ) |-> ## ( 16*9 ) ( serial_out [*15] )  
  );    
 
  assert property ( @( posedge clk ) 
        $rose ( tx_done_tick ) |=> $past( state_r == BIT_STOP ) && ( state_r == IDLE ) 
  ) ;       

  assert property ( @( posedge clk ) 
        $rose( data_valid ) |-> ## [16*16*9 : 16*16*10] $rose(tx_done_tick) 
  );      
`endif
*/
endmodule    
