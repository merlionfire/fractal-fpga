
//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    06/07/2015 
// Design Name: 
// Module Name:    disp_pi 
// Target Devices:  
// Description:    register files configured by uP. 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module disp_pi 
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   
   // --- uP interface
   input  wire        blk_sel, 
   input  wire [3:0]  addr, 
   input  wire        wr_en, 
   input  wire        rd_en,
   input  wire [7:0]  wr_data,
   output wire [7:0]  rd_data,

   // --- register output 
   output reg  [7:0]  cw_x_orig,  
   output reg  [7:0]  cw_y_orig,  
   output reg  [7:0]  cw_x_size,  
   output reg  [7:0]  cw_y_size,  
   output wire        cb_wr_addr_inc, 
   output wire        buffer_init_done, 
   output wire [2:0]  char_fg_rgl , 
   output wire [2:0]  char_bg_rgl , 
   output wire [2:0]  graph_fg_rgl , 
   output wire [2:0]  graph_bg_rgl , 
   output wire [10:0] cb_addr_orig , 
   output wire        cb_wr_en,   
   output reg  [7:0]  cw_row,  
   output reg  [7:0]  cw_col,  


   // --- misc 
   output reg        cw_row_col_update
) ; 

`include "disp_pi.vh" 
`include "vga_color_def.vh"

   //*************************************************************//
   // wire/reg declaration
   //*************************************************************//

   wire  cw_row_wr_en, cw_col_wr_en ; 
   reg   [7:0] cw_cs ; 
   reg   [7:0] char_rgl, graph_rgl ; 
   reg   [7:0] cb_addr_orig_low,  cb_addr_orig_high ;   

   
   //*************************************************************//
   // register write  
   //*************************************************************//

   // reg : cb_wr_data 
   //   Writing data into this register will let data writting into char buffer     
   assign cb_wr_en   =  blk_sel && wr_en && ( addr == REG_CB_WR_DATA ) ; 


   // reg  cw_row : row number of char windows as stating point of  writing strings 
   // reg  cw_col : rol number of char windows as stating point of  writing strings 
   assign   cw_row_wr_en   =  ( blk_sel && wr_en && ( addr == REG_CW_ROW_ADDR ) ) ;
   assign   cw_col_wr_en   =  ( blk_sel && wr_en && ( addr == REG_CW_COL_ADDR ) );
   
   always @( posedge clk ) begin    
      if ( rst ) begin 
         cw_row   <= 8'h0;
         cw_row   <= 8'h0; 
      end else begin 
         if ( cw_row_wr_en ) cw_row   <=   wr_data ; 
         if ( cw_col_wr_en ) cw_col   <=   wr_data ; 
         cw_row_col_update <= cw_row_wr_en || cw_col_wr_en ; 
      end          
   end


   always @( posedge clk ) begin    
      if ( rst ) begin 
         cw_cs          <= 8'h00; 
         cw_x_orig      <= 8'd96;   // cw_x_orig + cw_x_size <= 128 ( that 1024 / 8 = 128 ) 
         cw_y_orig      <= 8'd0;
         cw_x_size      <= 8'd32; 
         cw_y_size      <= 8'd48;
         cb_addr_orig_low   <= 8'd0 ; 
         cb_addr_orig_high  <= 3'd0 ; 
         char_rgl       <= { 1'b0, BLACK, 1'b0,  YELLOW }  ;
         graph_rgl      <= { 1'b0, BLUE , 1'b0, RED } ;   

      end else begin
         if ( wr_en && blk_sel ) begin 
            case ( addr ) 
               REG_CW_CS_ADDR             :  cw_cs          <= wr_data ;   
               REG_CW_X_ORIG_ADDR         :  cw_x_orig      <= wr_data ;   
               REG_CW_Y_ORIG_ADDR         :  cw_y_orig      <= wr_data ;   
               REG_CW_X_SIZE_ADDR         :  cw_x_size      <= wr_data ;   
               REG_CW_Y_SIZE_ADDR         :  cw_y_size      <= wr_data ;   
               REG_CB_ADDR_ORIG_LOW_ADDR  :  cb_addr_orig_low   <= wr_data ;
               REG_CB_ADDR_ORIG_HIGH_ADDR :  cb_addr_orig_high  <= wr_data ;
               REG_CHAR_RGL_ADDR          :  char_rgl       <= wr_data ;
               REG_GRAPH_BG_RGL_ADDR      :  graph_rgl      <= wr_data ;
            endcase 
         end
      end
   end



   //*************************************************************//
   // output inpterface 
   //*************************************************************//


   assign cb_wr_addr_inc   =  cw_cs[0] ;   
   assign buffer_init_done =  cw_cs[1] ;   
   assign char_bg_rgl      =  char_rgl[6:4] ; 
   assign char_fg_rgl      =  char_rgl[2:0] ; 
   assign graph_bg_rgl     =  graph_rgl[6:4] ; 
   assign graph_fg_rgl     =  graph_rgl[2:0] ; 
   assign cb_addr_orig     =  { cb_addr_orig_high[2:0], cb_addr_orig_low[7:0] } ;  
   assign rd_data          = 'h0 ; 

endmodule 
