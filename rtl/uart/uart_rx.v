module uart_rx ( 
   input  wire        clk,
   input  wire        rst,         
   input  wire        serial_in,
   input  wire        baud_16x_tick,
   output wire [7:0]  data_in , 
   output reg         rx_done_tick
);

   localparam  IDLE  = 4'h0,
               BIT_START = 4'h1,
               BIT_0 = 4'h2,
               BIT_1 = 4'h3,
               BIT_2 = 4'h4,
               BIT_3 = 4'h5,
               BIT_4 = 4'h6,
               BIT_5 = 4'h7,
               BIT_6 = 4'h8,
               BIT_7 = 4'h9,
               BIT_STOP = 4'hA;

   wire neg_edge_det ; 
   reg serial_in_sync,  rx , rx_dly ; 
   reg [3:0] state_r, state_nxt ; 
   reg [8:0] data_in_r, data_in_nxt ; 
   reg [3:0] baud_16x_tick_cnt,  baud_16x_tick_cnt_nxt ; 


   always @ ( posedge clk ) begin 
      serial_in_sync  <= serial_in ; 
      rx             <= serial_in_sync ; 
      rx_dly         <= rx ; 
   end

   assign neg_edge_det  = ~rx & rx_dly ; 

   assign data_in = data_in_r[7:0] ;
  
   initial begin 
         state_r = IDLE ;
         baud_16x_tick_cnt = 0 ;  
         data_in_r  = 0 ; 
   end 

   always @( posedge clk ) 
      if ( rst ) begin 
         state_r <= IDLE ;
         baud_16x_tick_cnt <= 0 ;  
         data_in_r  <= 0 ; 
      end else begin 
         state_r <= state_nxt ;
         baud_16x_tick_cnt <= baud_16x_tick_cnt_nxt ; 
         data_in_r  <= data_in_nxt ; 
      end   

   always @(*) begin 
      baud_16x_tick_cnt_nxt = baud_16x_tick_cnt ; 
      state_nxt = state_r  ;  
      data_in_nxt = data_in_r ; 
      rx_done_tick = 1'b0 ; 
      if ( state_r == IDLE ) begin 
            if ( neg_edge_det ) begin 
               state_nxt = BIT_START ; 
               baud_16x_tick_cnt_nxt = 4'h0 ; 
            end    
      end else begin
         if ( baud_16x_tick == 1'b1 ) begin 
            baud_16x_tick_cnt_nxt = baud_16x_tick_cnt + 1  ; 
            if ( state_r == BIT_START ) begin 
               if ( baud_16x_tick_cnt == 4'h7 ) begin 
                  state_nxt = rx ? IDLE : BIT_0 ; 
                  baud_16x_tick_cnt_nxt = 4'h0 ; 
               end   
            end else  begin 
               if ( baud_16x_tick_cnt == 4'hF  ) begin 
                  data_in_nxt  = { rx, data_in_r[7:1] } ; 
                  case ( state_r ) 
                     BIT_0 : state_nxt  = BIT_1 ; 
                     BIT_1 : state_nxt  = BIT_2 ; 
                     BIT_2 : state_nxt  = BIT_3 ; 
                     BIT_3 : state_nxt  = BIT_4 ; 
                     BIT_4 : state_nxt  = BIT_5 ; 
                     BIT_5 : state_nxt  = BIT_6 ; 
                     BIT_6 : state_nxt  = BIT_7 ; 
                     BIT_7 : state_nxt  = BIT_STOP ; 
                     BIT_STOP : begin 
                                    state_nxt  = IDLE ; 
                                    rx_done_tick = 1'b1 ; 
                                end     
                  endcase
               end // baud_16x_tick_cnt == 4'hF 
            end   //  state_r == BIT_START   
         end   // baud_16x_tick == 1'b1     
      end  // state_r == IDLE   
   end 

`ifdef SVA

   assert property ( @( posedge clk ) 
         ( $fell( serial_in ) && state_r == IDLE ) |-> ##[2:3] $fell(rx) ## 1  ( state_r == BIT_START )     
   );

   assert property ( @( posedge baud_16x_tick ) 
         ( state_r == BIT_START  && ( rx ) )  |-> ##[1:8] ( state_r == IDLE )  
   );       

   assert property ( @( posedge baud_16x_tick ) 
         ( state_r == BIT_START ) ## 1  ( state_r == BIT_0 ) 
                              |-> ## 16  ( state_r == BIT_1 ) 
                                  ## 16  ( state_r == BIT_2 ) 
                                  ## 16  ( state_r == BIT_3 ) 
                                  ## 16  ( state_r == BIT_4 ) 
                                  ## 16  ( state_r == BIT_5 ) 
                                  ## 16  ( state_r == BIT_6 ) 
                                  ## 16  ( state_r == BIT_7 ) 
                                  ## 16  ( state_r == BIT_STOP ) 
   ) ;  


   assert property ( @ ( posedge clk ) 
        $rose( rx_done_tick ) |=> $past( state_r == BIT_STOP ) && ( state_r == IDLE )  
   ); 

`endif

endmodule 
