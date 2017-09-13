`ifndef COV_CALLBACKS__SV
`define COV_CALLBACKS__SV

class slave_driver_cov_callbacks extends slave_driver_callbacks;
   local mouse_packet   pkt ; 

   covergroup mouse_packet_cov ( input int unsigned screen_size ); 
      option.auto_bin_max = 8;
      option.per_instance = 1; // Must have for Modelsim covergroup display !!!!

      px: coverpoint pkt.left_x {
             bins  left    =  {[1                     :  screen_size/3]} ; 
             bins  mid_x   =  {[ screen_size/3+1    :  (screen_size * 2 ) /3 ]} ; 
             bins  right   =  {[(screen_size*2)/3+1 :  screen_size-1 ]} ; 
             illegal_bins  misc   =  default ;
          } 

      py: coverpoint pkt.bot_y {  
             bins  top     =  {[1                     :  screen_size/3]} ; 
             bins  mid_y   =  {[ screen_size/3+1    :  (screen_size * 2 ) /3 ]} ; 
             bins  bottom  =  {[(screen_size*2)/3+1 :  screen_size-1 ]} ; 
             illegal_bins  misc   =  default ;
          } 

      region:cross px,py;

      len: coverpoint pkt.half_len {
             bins short    =  {[1:screen_size/6]} ; 
             bins middle   =  {[screen_size/6+1:screen_size/3]};
             bins long     =  {[screen_size/3+1 : screen_size/2-1]};
             illegal_bins misc = default ; 
         }
   endgroup 


   function new(); 
     mouse_packet_cov =  new( 768);  
   endfunction 

   virtual task post_tx( mouse_packet pkt ) ; 
      this.pkt =  pkt ; 
      mouse_packet_cov.sample();
   endtask 

endclass

`endif // COV_CALLBACKS__SV
