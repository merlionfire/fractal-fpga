module uart_tx ( 
   input  wire       clk,
   input  wire       rst,         
   input  wire       baud_16x_tick,
   input  wire [7:0] data_in , 
   input  wire       data_valid , 
   output wire       serial_out , 
   output reg        tx_done_tick
);

   parameter   START_BIT   =  1'b0 ; 
   parameter   STOP_BIT    =  1'b1 ; 

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
 
   reg [3:0] state_r, state_nxt ; 
   reg [8:0] data_shift_r , data_shift_nxt  ; 
   reg [3:0] baud_16x_tick_cnt,  baud_16x_tick_cnt_nxt ; 


   assign serial_out = data_shift_r[0] ; 

   initial begin 
      state_r = IDLE ;
      baud_16x_tick_cnt = 0 ;  
      data_shift_r  = 9'h1F ; 
   end

   always @( posedge clk ) 
      if ( rst ) begin 
         state_r <= IDLE ;
         baud_16x_tick_cnt <= 0 ;  
         data_shift_r  <= 9'h1F ; 
      end else begin 
         state_r <= state_nxt ;
         baud_16x_tick_cnt <= baud_16x_tick_cnt_nxt ; 
         data_shift_r      <= data_shift_nxt  ; 
      end   
      
   always @(*) begin
      baud_16x_tick_cnt_nxt = baud_16x_tick_cnt ; 
      state_nxt = state_r  ;  
      data_shift_nxt = data_shift_r ; 
      tx_done_tick = 1'b0 ; 
      if ( state_r == IDLE ) begin 
         if ( data_valid ) begin 
            state_nxt = BIT_START ; 
            data_shift_nxt = { data_in, START_BIT } ; 
            baud_16x_tick_cnt_nxt = 4'b0 ; 
         end
      end else begin 
         if ( baud_16x_tick ) begin 
            baud_16x_tick_cnt_nxt = baud_16x_tick_cnt + 1 ; 
            if ( baud_16x_tick_cnt == 4'hF ) begin 
               data_shift_nxt = { STOP_BIT, data_shift_r[8:1] } ;   
               case ( state_r ) 
                  BIT_START : state_nxt = BIT_0 ; 
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
                                 tx_done_tick = 1'b1 ; 
                             end     
               endcase
            end // ( baud_16x_tick_cnt == 4'hF ) 
         end // baud_16x_tick   
      end // state_r == IDLE 
   end // awlays 


`ifdef SVA   
  assert property (  @( posedge clk ) 
      $rose(data_valid) |=> ( state_r == BIT_START ) 
  ) ;      

  assert property (  @(posedge baud_16x_tick ) 
      ( $past(state_r) == IDLE && state_r == BIT_START) 
                               |-> ##16 ( state_r == BIT_0 ) 
                                   ##16 ( state_r == BIT_1 ) 
                                   ##16 ( state_r == BIT_2 ) 
                                   ##16 ( state_r == BIT_3 ) 
                                   ##16 ( state_r == BIT_4 ) 
                                   ##16 ( state_r == BIT_5 ) 
                                   ##16 ( state_r == BIT_6 ) 
                                   ##16 ( state_r == BIT_7 ) 
                                   ##16 ( state_r == BIT_STOP ) 
  ) ; 

  assert property ( @( posedge baud_16x_tick ) 
     (  $fell( serial_out ) && ( state_r == BIT_START ) ) |-> ## ( 16*9 ) ( serial_out [*15] )  
  );    
 
  assert property ( @( posedge clk ) 
        $rose ( tx_done_tick ) |=> $past( state_r == BIT_STOP ) && ( state_r == IDLE ) 
  ) ;       

  assert property ( @( posedge clk ) 
        $rose( data_valid ) |-> ## [16*16*9 : 16*16*10] $rose(tx_done_tick) 
  );      
`endif

endmodule 
