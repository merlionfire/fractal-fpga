//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   07/07/2017 
// Design Name: 
// Module Name:   mouse_pi 
// Function:      register configuation for mouse through processor interface      
//
// Note: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//
module   mouse_pi   (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   // --- uP interface
   input  wire        pi_blk_sel, 
   input  wire [3:0]  pi_addr, 
   input  wire        pi_wr_en, 
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output reg  [7:0]  pi_rd_data,
   // --- status and control interface
   output reg  [10:0] cursor_x_orig,
   output reg  [10:0] cursor_y_orig,   
   output reg         reg_mouse_en,
   output reg  [2:0]  cursor_contour_color,
   output reg  [2:0]  cursor_inter_color, 
   input  wire [7:0]  cursor_x_low,
   input  wire [7:0]  cursor_y_low,
   input  wire [2:0]  cursor_x_high,
   input  wire [2:0]  cursor_y_high,
   input  wire [10:0] left_pos_x,
   input  wire [10:0] bot_pos_y,
   input  wire [9:0]  sel_length, 
   input  wire        soft_rst, 
   input  wire        mouse_click,
   input  wire        mouse_restore,
   input  wire        mouse_zoom  
) ; 

`include "vga_color_def.vh" 
`include "mouse_pi.vh"

   reg        reg_click;
   reg        reg_restore;
   reg        reg_zoom;  

   always @( posedge clk ) begin    
      if ( rst ) begin 
         cursor_x_orig         <= 11'h1_00 ; 
         cursor_y_orig         <= 11'h0_10 ; 
         cursor_contour_color  <= RED ; 
         cursor_inter_color    <= WHITE ; 
      end else begin
         if ( pi_wr_en && pi_blk_sel ) begin 
            case ( pi_addr ) 
               REG_CURSOR_COLOR_ADDR        :  { cursor_contour_color, cursor_inter_color }  <= pi_wr_data[5:0] ; 
            endcase 
         end
      end
  end


   always @( posedge clk ) begin 
      if ( rst || soft_rst ) begin 
         reg_mouse_en   <= 1'b0 ; 
      end else if ( pi_wr_en && pi_blk_sel && ( pi_addr == REG_MOUSE_CTRL_STATUS_ADDR ) ) begin 
         reg_mouse_en   <= pi_wr_data[0] ; 
      end else if ( reg_click | reg_restore | reg_zoom ) begin
         reg_mouse_en   <= 1'b0 ; 
      end
   end
   
   always @( posedge clk ) begin 
      if ( rst || soft_rst ) begin 
         reg_click   <= 1'b0;  
      end else if ( pi_wr_en && pi_blk_sel && ( pi_addr == REG_MOUSE_CTRL_STATUS_ADDR ) ) begin 
         { reg_click, reg_restore, reg_zoom }    <= pi_wr_data[3:1]; 
      end else begin 
         if ( mouse_click     )  reg_click      <= 1'b1;  
         if ( mouse_restore   )  reg_restore    <= 1'b1;  
         if ( mouse_zoom      )  reg_zoom       <= 1'b1;  
      end
   end

  always @(*) begin
      pi_rd_data  =  8'h00 ; 
      if ( pi_rd_en && pi_blk_sel ) begin 
            case ( pi_addr ) 
               REG_MOUSE_CTRL_STATUS_ADDR   :  pi_rd_data   =  { 3'b0000,  reg_click, reg_restore, reg_zoom, reg_mouse_en }  ;  
               REG_CURSOR_X_LOW_ADDR        :  pi_rd_data   =  cursor_x_low ; // Current curosr (x,y) 
               REG_CURSOR_X_HIGH_ADDR       :  pi_rd_data   =  { 5'b00000, cursor_x_high } ;   
               REG_CURSOR_Y_LOW_ADDR        :  pi_rd_data   =  cursor_y_low ; 
               REG_CURSOR_Y_HIGH_ADDR       :  pi_rd_data   =  { 5'b00000, cursor_y_high } ;   
               REG_SEL_X_LEFT_LOW_ADDR      :  pi_rd_data   =  left_pos_x[7:0] ;    // When rectangle is selected, it indicates the left point (x,y) 
               REG_SEL_X_LEFT_HIGH_ADDR     :  pi_rd_data   =  { 5'b00000, left_pos_x[10:8] } ; 
               REG_SEL_Y_BOT_LOW_ADDR       :  pi_rd_data   =  bot_pos_y[7:0] ; 
               REG_SEL_Y_BOT_HIGH_ADDR      :  pi_rd_data   =  { 5'b00000, bot_pos_y[10:8] } ; 
               REG_SEL_HALF_LENGTH_LOW_ADDR :  pi_rd_data   =  sel_length[7:0] ;    // The second point (x,y) for rectangle selection is calculated on left/bottom and sel_length
               REG_SEL_HALF_LENGTH_HIGH_ADDR:  pi_rd_data   =  { 6'b000000, sel_length[9:8] } ;   
               default :                       pi_rd_data   =  'h0 ;  
            endcase 
      end
  end



endmodule 
