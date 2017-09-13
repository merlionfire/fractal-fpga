//`define VGA_640X480_60HZ 
//`define VGA_800X600_72HZ 
`define VGA_1024X768_70HZ

module vga_sync_gen 
#( 
   parameter X_PIXEL_N_BITS = 11 ,    
   parameter Y_PIXEL_N_BITS = 11
)
(            
   input  wire       clk,
   input  wire       rst,
   output wire       h_sync,
   output wire       v_sync,
   output wire       vga_on,
   output wire       border_on,
   output wire       h_blnk,    
   output wire       v_blnk,    
   output wire [X_PIXEL_N_BITS-1 : 0 ] pixel_x,
   output wire [Y_PIXEL_N_BITS-1 : 0 ] pixel_y
);      

`ifdef VGA_640X480_60HZ 
   localparam HLB = 48  ; 
   localparam HD  = 640 ; 
   localparam HRB = 16  ; 
   localparam HTR = 96  ; 
   localparam HALL = HLB + HD + HRB + HTR ; 
   localparam VTB = 33  ;
   localparam VD  = 480 ;
   localparam VBB = 10  ;
   localparam VTR = 2   ;
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

`ifdef VGA_800X600_72HZ 
   localparam HLB = 64  ; 
   localparam HD  = 800 ; 
   localparam HRB = 56  ; 
   localparam HTR = 120  ; 
   localparam HALL = HLB + HD + HRB + HTR ; 
   localparam VTB = 23  ;
   localparam VD  = 600 ;
   localparam VBB = 37  ;
   localparam VTR = 6   ;
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

`ifdef VGA_1024X768_70HZ
   localparam HD  = 1024 ; 
   //localparam HRB = 24  ; 
   localparam HRB = 24  ;  // orig: 24 
   //localparam HTR = 136  ; 
   localparam HTR = 136  ;  // orig: 136 
   //localparam HLB = 144  ; 
   localparam HLB = 144  ; // orig : 144
   localparam HALL = HLB + HD + HRB + HTR ; 
   
   localparam VD  = 768 ;
   //localparam VBB = 3   ;
   localparam VBB = 3   ; // orig 3 
   //localparam VTR = 6   ;
   localparam VTR = 6   ; // orig : 6
   //localparam VTB = 29  ; 
   localparam VTB = 29  ; // orig 29
   localparam VALL = VTB + VD + VBB + VTR ;
`endif

   reg  h_sync_r, v_sync_r, vga_on_r, border_on_r, h_blnk_r, v_blnk_r  ;   
   reg  [X_PIXEL_N_BITS-1 : 0 ] pixel_x_r, pixel_y_r ; 

   reg [X_PIXEL_N_BITS-1 : 0 ] h_sync_cnt;
   reg [Y_PIXEL_N_BITS-1 : 0 ] v_sync_cnt;

   wire h_sync_end, v_sync_end ; 
   wire h_visible, v_visible ; 


   // Horizon sync signals generation 
   assign h_sync_end = ( h_sync_cnt == ( HALL - 1 ) ) ;

   always @( posedge clk ) begin 
      if ( rst ) begin 
         h_sync_cnt <= 'd0;  
      end else begin
         if ( h_sync_end ) begin 
            h_sync_cnt  <= 'd0 ; 
         end else begin 
            h_sync_cnt <= h_sync_cnt + 1'b1 ;  
         end   
      end    
   end 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         h_sync_r <= 1'b0 ; 
      end else begin 
         if ( ( h_sync_cnt >= ( HD + HRB ) ) && ( h_sync_cnt <= ( HD + HRB + HTR - 1 ) ) ) begin 
            h_sync_r <= 1'b1; 
         end else begin  
            h_sync_r <= 1'b0;
         end 
      end 
   end 


   // Vertical sync signals generation 
   assign v_sync_end = ( v_sync_cnt == ( VALL - 1 ) ) ;

   always @( posedge clk ) begin 
      if ( rst ) begin 
         //v_sync_cnt <= ( VD + VBB ) ; // for testing frame_buf  
         v_sync_cnt <= 'd0;  
      end else if ( h_sync_end ) begin
         if ( v_sync_end ) begin 
            v_sync_cnt  <= 'd0 ; 
         end else begin 
            v_sync_cnt <= v_sync_cnt + 1'b1 ;  
         end   
      end      
   end 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         v_sync_r <= 1'b0 ; 
      end else begin 
         if ( ( v_sync_cnt >= ( VD + VBB ) ) && ( v_sync_cnt <= ( VD + VBB + VTR - 1 ) ) ) begin 
            v_sync_r <= 1'b1; 
         end else begin  
            v_sync_r <= 1'b0;
         end 
      end 
   end 


   // signal allowing pixels are shown  
   assign h_visible = h_sync_cnt < HD ; 
   assign v_visible = v_sync_cnt < VD ; 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         vga_on_r <= 1'b0 ; 
      end else begin 
         if ( h_visible && v_visible )
            vga_on_r <= 1'b1 ; 
         else    
            vga_on_r <= 1'b0 ; 
      end 
   end 

   always @( posedge clk ) begin 
      pixel_x_r      <= h_sync_cnt ; 
      pixel_y_r      <= v_sync_cnt ; 
      h_blnk_r       <= ~h_visible ; 
      v_blnk_r       <= ~v_visible ; 
   end 
   

   // border generation 
   always @( posedge clk ) begin    
      if ( rst ) begin 
         border_on_r   <= 1'b0; 
      end else begin 
         if ( ( v_sync_cnt == 'h0 ) || ( v_sync_cnt == ( VD-1 ) ) || 
              ( h_sync_cnt == 'h0 ) || ( h_sync_cnt == ( HD-1 ) ) ) begin 
            border_on_r   <= 1'b1 ; 
         end else begin 
            border_on_r   <= 1'b0 ; 
         end
      end 
    end   

   //------ Output interface signals -------  
   assign   pixel_x  = pixel_x_r;
   assign   pixel_y  = pixel_y_r;
   assign   vga_on   = vga_on_r;
   assign   border_on   = border_on_r ;
   assign   h_sync   = h_sync_r;
   assign   v_sync   = v_sync_r;
   assign   h_blnk   = h_blnk_r;    
   assign   v_blnk   = v_blnk_r;    

   //*************************************************************//
   // SVA checker  
   //*************************************************************//

`ifdef SVA   
   property VGA_ON_MATCH_PIXEL_X_Y; 
      @( posedge clk ) 
            vga_on |-> ( pixel_x < HD ) && ( pixel_y < VD ) ; 
   endproperty 
   assert property ( VGA_ON_MATCH_PIXEL_X_Y ) else 
      $error("[vga_sync_gen] invalid pixel_x/pixel_y for vga_on" )  ; 

   property H_SYNC_MATCH_PIXEL_X; 
      @( posedge clk ) 
            $fell(h_sync) |-> ## HLB ( pixel_x == 0 ) ; 
   endproperty 
   assert property ( H_SYNC_MATCH_PIXEL_X ) else 
      $error("h_sync is NOY sync with pixel_x" )  ; 

`endif

endmodule 
