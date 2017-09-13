`ifndef MOUSE_PACKET__SV
`define MOUSE_PACKET__SV

class mouse_packet;
   
   int      packet_id  ;

   rand  bit [10:0]  left_x;
   rand  bit [10:0]  bot_y;
   rand  bit [9:0]   half_len;
   int   unsigned    screen_size ; 
   
   shortreal         delta ; 
   shortreal         cx;
   shortreal         cy; 
   
   shortreal         new_delta ; 
   shortreal         new_cx;
   shortreal         new_cy; 

   constraint  c_left_x_limit { left_x inside { [0:(screen_size-1)] } ;}  

   constraint  c_bot_y_limt   { bot_y  inside { [0:(screen_size-1)] } ;}

   constraint  c_half_len_limit {   
      half_len inside {[1:(screen_size/2-1)] } ; 
      left_x + half_len * 2  < screen_size ; 
      bot_y  >  half_len * 2 ; 
      solve left_x  before half_len ; 
      solve bot_y   before half_len ; 
   } 
   
   function real abs( input shortreal a ) ; 
      return (a > 0 ) ? a : -a ;  
   endfunction

   function  new( int unsigned id = 0, int size = 768, shortreal cx = -2.0 , cy = -1.5 ) ; 
      real  cx_abs, cy_abs ; 
      this.packet_id    =  id ; 
      if ( (size <= 0 ) || ( size > 768 ) ) begin 
         $display("[ERR] @t: %m says 'screen size must be within [1,767]!!!'", $time ) ;    
         $finish;
      end 
      screen_size =  size ; 
      this.cx  =  cx ;
      this.cy  =  cy ; 

      cx_abs  =  abs(cx); 
      cy_abs  =  abs(cy); 

      if ( cx_abs < cy_abs ) begin 
         this.delta    =   ( cx_abs * 2 ) / screen_size ; 
      end else begin 
         this.delta    =   ( cy_abs * 2 ) / screen_size ; 
      end 
   endfunction 

   function void post_randomize(); 
      new_cx   =  cx + left_x * delta ; 
      new_cy   =  cy + (767-bot_y) * delta; 
      new_delta=  half_len * 2 * delta / screen_size ; 
   endfunction
   
   virtual function mouse_packet clone(); 
      mouse_packet  pkt ; 
      pkt   =  new() ; 
      pkt.packet_id =   packet_id ;
      pkt.left_x    =   left_x;
      pkt.bot_y     =   bot_y;
      pkt.half_len  =   half_len;
      pkt.screen_size = screen_size ; 
      pkt.delta     =   delta;  
      pkt.cx        =   cx;
      pkt.cy        =   cy;
      pkt.new_delta =   new_delta ; 
      pkt.new_cx    =   new_cx;
      pkt.new_cy    =   new_cy;

      return pkt ; 
   endfunction

   virtual function void print() ; 
      $display("[INFO] Packet: <%1d>:", packet_id); 
      $display("\tscreen size : %3d X %3d", screen_size, screen_size); 
      $display("\tOrigin fractal point :" ); 
      $display("\t\tcx    = %1.10f", cx) ; 
      $display("\t\tcy    = %1.10f", cy) ; 
      $display("\t\tdelta = %1.10f", delta) ; 
      $display("\tSelected Sqaure region :" ); 
      $display("\t\tx     = %3d", left_x); 
      $display("\t\ty     = %3d", bot_y); 
      $display("\t\tlen/2 = %3d", half_len) ; 
   endfunction

endclass

`endif 
