module region_select (

   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- VGA singal 
   input  wire [10:0] pixel_x,
   input  wire [10:0] pixel_y,
   output wire        cursor_on,
   output wire [2:0]  cursor_color,  

   // --- Mouse PS/2 interface
   input  wire        ps2_byte_valid,
   input  wire [7:0]  ps2_byte_1,
   input  wire [7:0]  ps2_byte_2, 
   input  wire [7:0]  ps2_byte_3, 

   // --- register control and status interface
   input  wire        reg_mouse_en,
   input  wire [10:0] cursor_x_orig,
   input  wire [10:0] cursor_y_orig,   
   input  wire [2:0]  cursor_contour_color,
   input  wire [2:0]  cursor_inter_color, 
   output wire [7:0]  cursor_x_low,
   output wire [7:0]  cursor_y_low,
   output wire [2:0]  cursor_x_high,
   output wire [2:0]  cursor_y_high,
   output wire        mouse_zoom, 
   output wire        mouse_restore,
   output wire        mouse_click, 
   output reg  [10:0] left_pos_x,
   output reg  [10:0] bot_pos_y,
   output reg  [9:0]  sel_length, 
   output wire        soft_rst,
   input  wire [1:0]  cursor_pic, 
   output wire [3:0]  cursor_pic_x_offset,
   output wire [3:0]  cursor_pic_y_offset, 
   input  wire        interrupt_ack, 
   output reg         interrupt
);

`include "vga_color_def.vh" 

   // ---------------------------------------------------------
   //    Variables declaration   
   // ---------------------------------------------------------

   // Variables for cursor display 

   wire [10:0]   x_move, y_move ;    
   wire          x_left_move, y_down_move ; 
   reg  [10:0]   cursor_x_move, cursor_y_move ;    
   wire          cursor_x_left_ov, cursor_x_right_ov,  cursor_y_up_ov, cursor_y_down_ov ; 
   reg           cursor_update ; 
   reg  [10:0]   cursor_x_nxt, cursor_y_nxt ; 
   reg  [10:0]   cursor_x, cursor_y ; 


   reg  [10:0]   x_offset, y_offset;
   reg           x_over_cursor, y_over_cursor ; 
   reg           cursor_active, cursor_display, cursor_display_1d ; 

   reg  [2:0]    color  ;  

   
   wire          cursor_pos_changed ; 
   wire          x_inside_cursor, y_inside_cursor ; 

   reg  [10:0]   first_pos_x, first_pos_y ;  
   reg  [10:0]   second_pos_x, second_pos_y ; 
   reg  [10:0]   abs_x_diff, abs_y_diff, abs_diff_max;
   reg  [10:0]   left_x_pre, right_x_pre, top_y_pre, bot_y_pre;
   reg  [10:0]   right_pos_x, top_pos_y;
   
   // variables related to mouse state machine 
   reg         selection_disp ; 
   wire        left_x_ov, right_x_ov, top_y_ov, bot_y_ov ; 
   reg  [6:0]  mlp_st ; 
   wire        ml_press, mr_press ; 
   //---------------------------------------
   //   Logics related to mouse move  
   //---------------------------------------

   // According PS2 mouse protocol:
   //   BYTE 1 : Yv Xv Y8 X8 1  M  R  L  
   //   BYTE 2 : X7 X6 X5 X4 X3 X2 X1 X0
   //   BYTE 3 : Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0
   //   
   // Since { X8, BYTE1 } is 2's-complement format, extend the MSB of 9bit to 11bit 
   assign x_move        =  { {3{ps2_byte_1[4] } }, ps2_byte_2 } ; 
   assign y_move        =  { {3{ps2_byte_1[5] } }, ps2_byte_3 } ;
   assign x_left_move   =  ps2_byte_1[4] ; 
   assign y_down_move   =  ps2_byte_1[5] ; 


   // Bewlow 4 wires indicates of cursor moves out of current screen
   // For new location of cursor, cursor_x_move[10] being 1 indicates :
   //    most right ( postive ) or most left ( negative )
   
   // Temp : checking logic needs to be reviewed    
   assign cursor_x_left_ov   =     x_left_move   & cursor_x_move[10] ;    
   // Since 1024 = 11'h400 = 11'b100_0000_0000
   //                            A98_7654_3210
   assign cursor_x_right_ov   =   (~x_left_move ) & cursor_x_move[10] ;    

   assign cursor_y_up_ov     =   (~y_down_move) &  cursor_y_move[10] ;    

   // Since 768 = 11'h011_0000_0000 
   //     bit index : A98_7654_3210
   assign cursor_y_down_ov   =   y_down_move    &  cursor_y_move[8] & cursor_y_move[9] ;    
   
   always @( posedge clk ) begin 
      //Note:
      //  (x,y) of cursor is always updated based on mouse movement.
      //  But, new location does NOT take effect untill ps2_byte_valid == 1.
      //  Below logic also checks if new (x,y) is out of screen,
      //  that is check 0 <= X < 1024 and 0 <= Y < 768. IF not , force
      //  cursor to stay at the border of screen  
      cursor_x_move     <= cursor_x + x_move ; 
      cursor_y_move     <= cursor_y + (~ y_move ) + 1 ; // Mouse moves down means Y increases 

      cursor_update     <= 1'b0 ;  
      if ( ps2_byte_valid == 1'b1 ) begin 
         if ( cursor_x_left_ov ) begin 
            cursor_x_nxt   <= 11'h0 ; 
         end else if ( cursor_x_right_ov ) begin 
            cursor_x_nxt   <= 11'd1023 ; 
         end else begin 
            cursor_x_nxt   <= cursor_x_move ; 
         end

         if ( cursor_y_down_ov ) begin 
            cursor_y_nxt   <= 11'd767 ; 
         end else if ( cursor_y_up_ov ) begin  
            cursor_y_nxt   <= 11'h0 ; 
         end else begin 
            cursor_y_nxt   <= cursor_y_move ; 
         end
         
         cursor_update  <= 1'b1 ;  
      end

   end 



   //---------------------------------------
   //   Logics related to cursor display  
   //---------------------------------------

   /* registers related to cursor location and color */ 
   assign   { cursor_x_high, cursor_x_low } = cursor_x[10:0] ; 
   assign   { cursor_y_high, cursor_y_low } = cursor_y[10:0] ; 

  /* cursor display control */
  always @( posedge clk ) begin 
      if ( rst ) begin 
         cursor_x    <= cursor_x_orig ; 
         cursor_y    <= cursor_y_orig ; 
      end else begin 
         if ( cursor_update ) begin 
            cursor_x <= cursor_x_nxt ; 
            cursor_y <= cursor_y_nxt ; 
         end 
      end
  end

  // 1-D domain.  Reference is input of pixel_x and pixel_y  
   always @ (posedge clk ) begin 
      { x_over_cursor,  x_offset }  <= { 1'b1, pixel_x } - { 1'b0, cursor_x } ;
      { y_over_cursor,  y_offset }  <= { 1'b1, pixel_y } - { 1'b0, cursor_y } ;
   end

   assign  cursor_pic_x_offset  =  x_offset[3:0] ; 
   assign  cursor_pic_y_offset  =  y_offset[3:0] ; 
   assign  x_inside_cursor      =  ~( |{x_offset[10:4]} ) ;  // All 0s 
   assign  y_inside_cursor      =  ~( |{y_offset[10:4]} ) ;  // All 0s


   // 2-D domain 
   always @ (posedge clk ) begin 
      // cursor_active is asserted when (x,y) is inside cursor picture
      cursor_active     <= x_over_cursor & y_over_cursor & x_inside_cursor & y_inside_cursor ;  
   end


   //---------------------------------------------------------------------
   //   Logics related to area selction by holding left-button of mouse  
   //---------------------------------------------------------------------
   //

   localparam  IDLE_ST  =  0 ; 
   localparam  MRP_ST   =  1 ; 
   localparam  MLP_ST   =  2 ;
   localparam  MSC_ST   =  3 ;
   localparam  MLH_ST   =  4 ;
   localparam  INTR_ST  =  5 ;
   localparam  MISC_ST  =  6 ;

   assign ml_press  = ps2_byte_1[0] ;  
   assign mr_press  = ps2_byte_1[1] ;  

   always @( posedge clk ) begin 
      if ( rst ) begin 
         mlp_st         <= 1'b1;
         first_pos_x    <= 'h0 ; 
         first_pos_y    <= 'h0 ; 
         second_pos_x   <= 'h0 ; 
         second_pos_y   <= 'h0 ; 
         selection_disp <= 1'b0 ;  
         interrupt      <= 1'b0 ;
      end else begin
         interrupt      <= 1'b0 ;
         selection_disp <= 1'b0 ;  
         mlp_st         <= 'h0  ; 
         case ( 1'b1 ) 
            mlp_st[IDLE_ST]  :  begin 
               if ( reg_mouse_en && cursor_update ) begin 
                  if ( ml_press ) begin  // Left Press
                     first_pos_x    <= cursor_x_nxt ; 
                     first_pos_y    <= cursor_y_nxt ; 
                     mlp_st[MLP_ST] <= 1'b1 ; 
                  end else if ( mr_press ) begin
                     mlp_st[MRP_ST] <= 1'b1 ; 
                  end else begin 
                     mlp_st[IDLE_ST]<= 1'b1 ; 
                  end
               end else begin 
                  mlp_st[IDLE_ST]   <= 1'b1 ; 
               end
            end
            mlp_st[MRP_ST]   :  begin 
               mlp_st[INTR_ST]   <= 1'b1 ; 
            end
            mlp_st[MLP_ST]   : begin 
               if ( cursor_update ) begin 
                  if ( ml_press ) begin   // Continuing Left Press means Move 
                     if ( first_pos_x  < 11'd768 ) begin /*check if point inside figure */ 
                        second_pos_x <= cursor_x_nxt ; 
                        second_pos_y <= cursor_y_nxt ; 
                        mlp_st[MLH_ST]    <= 1'b1 ;  
                     end else begin // Pressing and moving in MENU region is nothing to happend. Wait for all button released and go back to IDLE 
                        mlp_st[MISC_ST]   <= 1'b1 ;  
                     end
                  end else begin    
                     mlp_st[MSC_ST]    <= 1'b1 ; 
                  end 
               end else begin 
                  mlp_st[MLP_ST]   <= 1'b1 ; 
               end
            end 
            mlp_st[MSC_ST]   :  begin 
               mlp_st[INTR_ST]   <= 1'b1 ; 
            end 

            mlp_st[MLH_ST]   :  begin 
               selection_disp  <= 1'b1 ;  
               if ( cursor_update ) begin 
                  second_pos_x <= cursor_x_nxt ; 
                  second_pos_y <= cursor_y_nxt ; 
                  if ( ml_press ) begin 
                     mlp_st[MLH_ST]  <= 1'b1 ;  
                  end else begin 
                     mlp_st[INTR_ST] <= 1'b1 ;  
                  end
               end else begin 
                  mlp_st[MLH_ST] <= 1'b1 ; 
               end
            end
            mlp_st[INTR_ST]  :  begin 
               interrupt       <= 1'b1 ; 
               if ( interrupt_ack ) begin 
                  mlp_st[IDLE_ST]   <= 1'b1 ;  
               end else begin 
                  mlp_st[INTR_ST]   <= 1'b1 ; 
               end
            end
            mlp_st[MISC_ST]   : begin   // Wait for all button released then go back to IDLE
               if ( reg_mouse_en && cursor_update ) begin 
                  if ( ml_press | mr_press ) begin
                     mlp_st[MISC_ST]   <= 1'b1 ; 
                  end else begin
                     mlp_st[IDLE_ST]   <= 1'b1 ; 
                  end
               end else begin
                  mlp_st[MISC_ST]   <= 1'b1 ;  
               end
            end
            default  :  begin 
               mlp_st[IDLE_ST]   <= 1'b1 ;  
            end
         endcase       
      end 
   end 


   assign   mouse_zoom     = mlp_st[MLH_ST] ;  
   assign   mouse_restore  = mlp_st[MRP_ST] ; 
   assign   mouse_click    = mlp_st[MSC_ST] ;


   // Rectangel area is determined by 2 points
   // First point : 
   //    - Left Click 
   //    - indicate the central point of final rectangel area
   // Second point :
   //    - Left release after dragging mouse ( No dragging means one-click
   //    rather than area selection 
   //    - Outline of rectangle 
   //
   always @( posedge clk ) begin 

      // Stage 1
      if ( second_pos_x > first_pos_x ) begin 
         abs_x_diff  <= second_pos_x   -  first_pos_x ; 
      end else begin 
         abs_x_diff  <= first_pos_x    -  second_pos_x; 
      end

      if ( second_pos_y > first_pos_y ) begin 
         abs_y_diff  <= second_pos_y   -  first_pos_y ; 
      end else begin 
         abs_y_diff  <= first_pos_y    -  second_pos_y; 
      end

      // Stage 2
      if ( abs_y_diff   >  abs_x_diff  ) begin 
         abs_diff_max   <= abs_y_diff  ;  
      end else begin 
         abs_diff_max   <= abs_x_diff ; 
      end

      // Stage 3
      left_x_pre  <= first_pos_x -  abs_diff_max ; 
      right_x_pre <= first_pos_x +  abs_diff_max ; 
      top_y_pre   <= first_pos_y -  abs_diff_max ; 
      bot_y_pre   <= first_pos_y +  abs_diff_max ; 
      
      // Stage 4
      if( ! ( left_x_ov || right_x_ov || top_y_ov || bot_y_ov ) ) begin 
         left_pos_x  <= left_x_pre ; 
         top_pos_y   <= top_y_pre;
         right_pos_x <= right_x_pre;
         bot_pos_y   <= bot_y_pre; 
         sel_length  <= abs_diff_max[9:0] ; // half width of area selected.
      end 

   end 

   // X,Y range:   11'b000_0000_0000  - 11'b010_FFFF_FFFF ( 768-1 )     
   assign   left_x_ov   =  left_x_pre[10] ; 
   assign   right_x_ov  =  right_x_pre[9] && right_x_pre[8] ; 
   assign   top_y_ov    =  top_y_pre[10] ; 
   assign   bot_y_ov    =  bot_y_pre[9] & bot_y_pre[8] ; 

   reg   line_x_inside, line_x_equal ; 
   reg   line_y_inside, line_y_equal ; 
   reg   line_active ; 

   // 1-D domain with respective to pixel_x|y 
   always @( posedge clk ) begin 
      line_x_inside  <= ( pixel_x >= left_pos_x ) && ( right_pos_x >= pixel_x ) ;      
      line_y_inside  <= ( pixel_y >= top_pos_y ) && ( bot_pos_y >= pixel_y ) ;      
      line_x_equal   <= ( pixel_x == left_pos_x ) || ( pixel_x == right_pos_x ) ; 
      line_y_equal   <= ( pixel_y == top_pos_y ) || ( pixel_y == bot_pos_y ) ; 
   end

   
   // 2-D domain with respective to pixel_x|y 
   always @( posedge clk ) begin 
      if ( selection_disp == 1'b0 ) begin 
         line_active <= 1'b0 ; 
      end else begin 
         line_active <=  ( line_y_inside & line_x_equal ) || (line_x_inside & line_y_equal )  ;   
      end
   end

   //---------------------------------------------------------------------
   //   display and color output mux  
   //---------------------------------------------------------------------
   //
   // 3-D domain 
   always @ (posedge clk ) begin 
      // cursor is displayed when (x,y) is inside cursor 
      cursor_display    <= line_active | ( cursor_active & ( cursor_pic[0] | cursor_pic[1] ) )  ;      //3D 
      
   end
   // 3-D domain 
   
   parameter CONTOUR    = 2'b01 ; 
   parameter INTERIOR   = 2'b10 ; 

   always @( posedge clk ) begin 
      if ( line_active  == 1'b1 ) begin 
         color    <= WHITE ;
      end else begin 
         case ( cursor_pic )   
            CONTOUR  : color  <= cursor_contour_color ;  
            INTERIOR : color  <= cursor_inter_color ; 
            default  : color  <= 'hx ; 
         endcase 
      end
   end 
   //---------------------------------------
   //   Output interface signals  
   //---------------------------------------
   assign   cursor_color   =  color ; 
   assign   cursor_on      =  cursor_display ; 

   assign   soft_rst       =  mlp_st[INTR_ST]; 

endmodule 
