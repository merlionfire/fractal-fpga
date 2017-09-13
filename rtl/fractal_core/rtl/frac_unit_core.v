//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    frac_unit 
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
module frac_unit_core  #(
      parameter N =  32 , 
      parameter M =  4
   )  (
   // --- clock and reset 
   input  wire          frac_clk,
   input  wire          frac_rst,
    
   // --- argument  
   input  wire [N-1:0]  frac_cx,
   input  wire [N-1:0]  frac_cy,
   input  wire          frac_go,
   input  wire [15:0]   frac_max_iter,

   // --- output 
   output wire          frac_busy,
   output wire          frac_done_tick, 
   output wire          frac_found 
);

   localparam  F  =  N - M ;  //28 

   localparam  IDLE     = 0,
               CALC     = 1,
               UPDATE   = 2,
               ST_N     = 3; 
            
   // -------- Variable declaration ------------

   wire signed [ (2*N-1) : 0 ] x2_r, y2_r, xy_r ; 
   wire signed [ N-1 : 0 ]     x2_trim, y2_trim, xy_trim ; 
   wire [ N : 0 ]    sum_x2_y2 ; 
   reg  signed [ N-1 : 0 ] x_r, y_r, cx_r, cy_r ; 
   wire overflow, iter_end ;  
      
   reg [ST_N-1:0]   frac_st  = 3'b001 ;  
   reg         mult_en, busy_r, done_tick, found_r  ;   
   reg [15:0]  iter; 

   // -------- Multiplier ----------

   multiplier_wrapper  multiplier_wrapper_x2_inst (
      .clk ( frac_clk     ), //i
      .ce  ( mult_en ), //i
      .a   ( x_r     ), //i
      .b   ( x_r     ), //i
      .p   ( x2_r    )  //o
   );

   assign x2_trim =  x2_r[ ( (2*N-1)-M ):F ] ;   

   multiplier_wrapper  multiplier_wrapper_y2_inst (
      .clk ( frac_clk     ), //i
      .ce  ( mult_en ), //i
      .a   ( y_r     ), //i
      .b   ( y_r     ), //i
      .p   ( y2_r    )  //o
   );

   assign y2_trim =  y2_r[ ( (2*N-1)-M ):F ] ;   
   
   multiplier_wrapper  multiplier_wrapper_xy_inst (
      .clk ( frac_clk     ), //i
      .ce  ( mult_en ), //i
      .a   ( x_r     ), //i
      .b   ( y_r     ), //i
      .p   ( xy_r    )  //o
   );

   //assign xy_trim =  xy_r[ ( (2*N-1)-M ):F ] ;   
   assign xy_trim =  xy_r[ ( (2*N-1)-M-1 ): F-1 ] ;   

   assign sum_x2_y2 =  { 1'b0,  x2_trim } + { 1'b0, y2_trim }  ;  
   //assign overflow = ( x2_trim + y2_trim ) > 32'h4000_0000 ; 
   assign overflow = sum_x2_y2 > 33'h04000_0000 ; 
   assign iter_end = ( iter == 'b1 ) ;  

   // -------- Fractal engin state machine ----------
    
   always @( posedge frac_clk ) begin  
      if ( frac_rst ) begin 
         done_tick <= 1'b0 ;  
         mult_en   <= 1'b0 ; 
         found_r   <= 1'b0 ;  
         frac_st   <= 'b1 ; 
         iter      <= 'b0 ; 
      end else begin 
         done_tick <= 1'b0 ;  
         mult_en   <= 1'b0; 
         frac_st   <= 'b0 ; 
         case ( 1'b1 ) 
            frac_st[IDLE] : begin 
               busy_r     <= 1'b0 ; 
               if ( frac_go ) begin 
                  busy_r   <= 1'b1 ; 
                  found_r  <= 1'b0 ;  
                  x_r      <= frac_cx   ;  
                  y_r      <= frac_cy   ;
                  cx_r     <= frac_cx   ;  
                  cy_r     <= frac_cy   ;
                  mult_en  <= 1'b1; 
                  iter     <= frac_max_iter ; 
                  frac_st[CALC] <= 1'b1 ; 
               end else begin 
                  frac_st[IDLE] <= 1'b1 ; 
               end
            end 
            frac_st[CALC]  :  begin 
               iter            <= iter - 1'b1 ; 
               frac_st[UPDATE] <= 1'b1 ; 
            end                
            frac_st[UPDATE] : begin     
               x_r   <= x2_trim - y2_trim + cx_r ;                  
               y_r   <= xy_trim + cy_r ;                  
               if ( overflow ) begin 
                  done_tick      <= 1'b1 ;  
                  frac_st[IDLE]  <= 1'b1 ; 
               end else if ( iter_end ) begin 
                  done_tick      <= 1'b1 ;  
                  frac_st[IDLE]  <= 1'b1 ; 
                  found_r        <= 1'b1 ;  
               end else begin 
                  mult_en        <= 1'b1; 
                  frac_st[CALC]  <= 1'b1 ; 
               end
            end 
         endcase 
      end
   end

   //------ Output interface signals -------  

   assign frac_busy        =  busy_r ; 
   assign frac_done_tick   =  done_tick ; 
   assign frac_found       =  found_r ;   


endmodule
