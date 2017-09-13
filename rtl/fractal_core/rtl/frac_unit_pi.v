
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

module frac_unit_pi 
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
   output reg  [7:0]  rd_data,

   // --- register output 
   output wire [31:0] frac_cx,  
   output wire [31:0] frac_cy,  
   output wire [15:0] frac_max_iter,  
   output wire        frac_go,

   // ---- outside status
   input  wire        frac_busy,
   input  wire        frac_done_tick,
   input  wire        frac_found

   // --- misc 
) ; 

`include "frac_unit_pi.vh" 

   //*************************************************************//
   // wire/reg declaration
   //*************************************************************//

   reg  [7:0]  frac_ctrl_status; 
   reg  [7:0]  frac_cx_7_0, frac_cx_15_8, frac_cx_23_16, frac_cx_31_24 ;   
   reg  [7:0]  frac_cy_7_0, frac_cy_15_8, frac_cy_23_16, frac_cy_31_24 ;   
   reg  [7:0]  frac_max_iter_low, frac_max_iter_high ; 
  
   reg  [7:0]  frac_py_15_8, frac_py_7_0 ;   
   reg  [7:0]  frac_px_15_8, frac_px_7_0 ;   
   reg  frac_found_r ; 

   //*************************************************************//
   // register write  
   //*************************************************************//


   always @( posedge clk ) begin    
      if ( rst ) begin 
         frac_ctrl_status     <= 'h0 ; 
         frac_cx_7_0          <= 'h0 ;   
         frac_cx_15_8         <= 'h0 ;   
         frac_cx_23_16        <= 'h0 ;   
         frac_cx_31_24        <= 'h0 ;   
         frac_cy_7_0          <= 'h0 ;   
         frac_cy_15_8         <= 'h0 ;   
         frac_cy_23_16        <= 'h0 ;   
         frac_cy_31_24        <= 'h0 ;   
         frac_max_iter_low    <= 'h0 ; 
         frac_max_iter_high   <= 'h0 ; 
         frac_py_15_8         <= 'h0 ;
         frac_py_7_0          <= 'h0 ;   
         frac_px_15_8         <= 'h0 ;
         frac_px_7_0          <= 'h0 ;   
      end else begin
         if ( wr_en && blk_sel ) begin 
            case ( addr ) 
               REG_FRAC_CTRL_STATUS       :  frac_ctrl_status     <= wr_data ; 
               REG_FRAC_CX_7_0_ADDR       :  frac_cx_7_0          <= wr_data ;   
               REG_FRAC_CX_15_8_ADDR      :  frac_cx_15_8         <= wr_data ;   
               REG_FRAC_CX_23_16_ADDR     :  frac_cx_23_16        <= wr_data ;   
               REG_FRAC_CX_31_24_ADDR     :  frac_cx_31_24        <= wr_data ;   
               REG_FRAC_CY_7_0_ADDR       :  frac_cy_7_0          <= wr_data ;   
               REG_FRAC_CY_15_8_ADDR      :  frac_cy_15_8         <= wr_data ;   
               REG_FRAC_CY_23_16_ADDR     :  frac_cy_23_16        <= wr_data ;   
               REG_FRAC_CY_31_24_ADDR     :  frac_cy_31_24        <= wr_data ;   
               REG_FRAC_MAX_ITER_LOW_ADDR :  frac_max_iter_low    <= wr_data ; 
               REG_FRAC_MAX_ITER_HIGH_ADDR : frac_max_iter_high   <= wr_data ; 
               REG_FRAC_PY_7_0_ADDR       :  frac_py_7_0          <= wr_data ;   
               REG_FRAC_PY_15_8_ADDR      :  frac_py_15_8         <= wr_data ;   
               REG_FRAC_PX_7_0_ADDR       :  frac_px_7_0          <= wr_data ;   
               REG_FRAC_PX_15_8_ADDR      :  frac_px_15_8         <= wr_data ;   
            endcase 
         end else begin 
         
            frac_ctrl_status[0] <= frac_busy ? 1'b0 : frac_ctrl_status[0] ;  
         end

      end
   end


   //*************************************************************//
   // register read  
   //*************************************************************//
  
   always @(*) begin
      rd_data  =  8'h00 ; 
      if ( rd_en && blk_sel ) begin 
            case ( addr ) 
               REG_FRAC_CTRL_STATUS       :  rd_data = { 6'b000000, frac_found_r, frac_busy }  ; 
            endcase 
      end
   end

   always @( posedge clk ) begin    
      if ( rst ) begin 
         frac_found_r <= 1'b0 ;
      end else begin 
         if ( frac_done_tick ) begin
            frac_found_r   <= frac_found ; 
         end 
      end
   end

   //*************************************************************//
   // output inpterface 
   //*************************************************************//

   assign frac_go          =  frac_ctrl_status[0] ; 

   assign frac_cx          =  { frac_cx_31_24, frac_cx_23_16, frac_cx_15_8, frac_cx_7_0 }   ;   
   assign frac_cy          =  { frac_cy_31_24, frac_cy_23_16, frac_cy_15_8, frac_cy_7_0 }   ;   
   assign frac_max_iter    =  { frac_max_iter_high, frac_max_iter_low } ;      

endmodule 
