//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    timing_test  
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

module timing_test 
#( 
   parameter FONT_WIDTH_N_BITS = 3,  
   parameter FONT_HEIGH_N_BITS = 4  
)
(
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   
   // --- VGA Singals
   output wire [3:0]  vga_red, 
   output wire [3:0]  vga_green, 
   output wire [3:0]  vga_blue, 
   output wire        vga_h_sync,
   output wire        vga_v_sync
) ; 

`include "vga_color_def.vh" 

   wire [10:0] pixel_x,  pixel_y;
   wire h_sync, v_sync, vga_on, border_on, h_blnk, v_blnk ; 


   reg  [3:0]  h_sync_dly, v_sync_dly ; 
   reg  [2:0]  rgl ; 

   //synthesis attribute keep of rgl is "true"

   //*************************************************************//
   // Module instatiation 
   //*************************************************************//

   vga_sync_gen  vga_sync_gen_inst (
      .clk       ( clk       ), //i
      .rst       ( rst       ), //i
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
   // Initialization  
   //*************************************************************//


   //*************************************************************//
   // Control singals related to char window 
   //*************************************************************//

   always @( posedge clk ) begin  
      h_sync_dly[3:0] <= { h_sync_dly[2:0], ~h_sync } ;     
      v_sync_dly[3:0] <= { v_sync_dly[2:0], ~v_sync } ;     
   end
   
   //*************************************************************//
   // Mux all objects  
   //*************************************************************//

   always @( posedge clk ) begin // 4D 
      if ( vga_on ) begin 
         if ( border_on )  rgl   <= BLUE ; 
         else              rgl   <= GREEN; 
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

   assign vga_h_sync  =  h_sync_dly[0] ; 
   assign vga_v_sync  =  v_sync_dly[0] ; 

endmodule    
