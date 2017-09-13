module baud_rate_generator(
   input             clk , 
   input             rst ,
   input wire [7:0]  baud_16x_in_cycles,
   output reg        baud_16x_tick 
);
 

  reg [ 7 : 0 ] clk_cnt ;  

  initial begin 
      clk_cnt = 0 ;
      baud_16x_tick = 1'b0 ; 
  end

  always @( posedge clk ) begin 
      if ( rst ) begin
         clk_cnt <= 0 ;
         baud_16x_tick <= 1'b0 ; 
      end else begin  
         clk_cnt <= clk_cnt + 1 ; 
         if ( clk_cnt == baud_16x_in_cycles  ) begin 
            baud_16x_tick <= 1'b1 ; 
            clk_cnt       <= 0 ;  
         end else 
            baud_16x_tick <= 1'b0 ; 
      end
  end 

endmodule   
