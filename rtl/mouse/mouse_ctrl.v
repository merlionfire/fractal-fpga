
module mouse_ctrl
(
   // Clock and reset    
   input             clk,
   input             rst,

   // PS/2 rxtx interface 
   input             ps2_tx_ready,   
   input             ps2_rddata_valid,
   input [7:0]       ps2_rd_data, 
   output reg        ps2_wr_stb,
   output reg  [7:0] ps2_wr_data,

   // mouse interface
   output wire       ps2_byte_valid,
   output wire [7:0] ps2_byte_1, 
   output wire [7:0] ps2_byte_2, 
   output wire [7:0] ps2_byte_3, 
   
   // diagnostic singal  
   output reg         diag_wr_en, 
   output wire [35:0] diag_data_out  
);   


`include "ps2_pkg.vh" 

   // ---------------------------------------------------------
   //    Variables declaration   
   // ---------------------------------------------------------

   reg [3:0]   state_r, state_nxt ; 
   reg [7:0]   byte_1_r, byte_2_r, byte_3_r ; 
   reg         byte_valid_r ; 
   reg         cmd_no_ack ; 


   localparam  ST_IDLE                       =  4'b0000, 
               ST_SEND_RESET_CMD             =  4'b0001, 
               ST_RD_INIT_STATUS             =  4'b0010, 
               ST_RD_DEVICE_ID               =  4'b0011,
               ST_SENT_SET_STREAM_MODE_CMD   =  4'b0100, 
               ST_SENT_ENABLE_CMD            =  4'b0101, 
               ST_RD_BYTE_1                  =  4'b0110, 
               ST_RD_BYTE_2                  =  4'b0111, 
               ST_RD_BYTE_3                  =  4'b1000, 
               ST_DONE                       =  4'b1001, 
               ST_WAIT_CMD_ACK               =  4'b1010; 

   //parameter  CYCLE_NUM_PER_TICK = 16'h8000 ; 
   parameter  CYCLE_NUM_PER_TICK = 16'h1000 ; 

   reg  [3:0]  diag_state ; 
   reg  [7:0]  diag_hold ; 
   reg  [7:0]  tick_cnt ; 
   reg [15:0]  cycle_cnt ; 
   wire        cycle_tick ; 

   // ---------------------------------------------------------
   //    Main FSM    
   // ---------------------------------------------------------

   always @( posedge clk )  begin 
      if ( rst == 1'b1 ) begin 
         state_r        <= ST_IDLE ; 
         state_nxt      <= ST_IDLE ; 
         cmd_no_ack     <= 1'b0 ; 
         ps2_wr_stb     <= 1'b0 ; 
         ps2_wr_data    <= 8'h00;
         byte_valid_r   <= 1'b0 ; 
         byte_1_r       <= 8'h00; 
         byte_2_r       <= 8'h00; 
         byte_3_r       <= 8'h00; 
      end else begin 
         ps2_wr_stb     <= 1'b0 ; 
         byte_valid_r   <= 1'b0 ; 
         case ( state_r ) 
            ST_IDLE : begin 
               if ( ps2_tx_ready ) begin
                  state_r     <= ST_SEND_RESET_CMD ; 
               end
            end 
            ST_SEND_RESET_CMD : begin 
               ps2_wr_stb  <= 1'b1 ; 
               ps2_wr_data <= PS2_CMD_RESET_CMD;
               state_r     <= ST_WAIT_CMD_ACK ; 
               state_nxt   <= ST_RD_INIT_STATUS ; 
            end
            ST_RD_INIT_STATUS : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  state_r   <=  ST_RD_DEVICE_ID ; 
               end    
            end 
            ST_RD_DEVICE_ID : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  state_r   <=  ST_SENT_SET_STREAM_MODE_CMD   ; 
               end   
            end
            ST_SENT_SET_STREAM_MODE_CMD : begin 
               ps2_wr_stb  <= 1'b1 ; 
               ps2_wr_data <= PS2_CMD_SET_STREAM_MODE;
               state_r     <= ST_WAIT_CMD_ACK ; 
               state_nxt   <= ST_SENT_ENABLE_CMD ; 
            end 
            ST_SENT_ENABLE_CMD : begin 
               ps2_wr_stb  <= 1'b1 ; 
               ps2_wr_data <= PS2_CMD_ENABLE_DATA_REP;
               state_r     <= ST_WAIT_CMD_ACK ; 
               state_nxt   <= ST_RD_BYTE_1 ; 
            end 
            ST_RD_BYTE_1 : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  byte_1_r  <= ps2_rd_data ;  
                  state_r   <= ST_RD_BYTE_2  ; 
               end    
            end
            ST_RD_BYTE_2 : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  byte_2_r  <= ps2_rd_data ;  
                  state_r   <= ST_RD_BYTE_3  ; 
               end    
            end
            ST_RD_BYTE_3 : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  byte_3_r  <= ps2_rd_data ;  
                  state_r   <= ST_DONE  ; 
               end    
            end
            ST_DONE : begin 
               byte_valid_r   <= 1'b1 ; 
               state_r        <= ST_RD_BYTE_1  ; 
            end
            ST_WAIT_CMD_ACK : begin 
               if ( ps2_rddata_valid == 1'b1 ) begin 
                  if ( ps2_rd_data == PS2_RD_ACK ) begin 
                     state_r  <= state_nxt ; 
                  end else begin 
                     cmd_no_ack  <= 1'b1 ; 
                     state_r     <= ST_IDLE ; 
                  end
               end 
            end
            default : begin 
               state_r     <= ST_IDLE ; 
            end
               
         endcase
      end
   end


   //---------------------------------------
   //   Diagnostic Code  
   //---------------------------------------
   
   reg   [3:0] state_r_1d ; 

   assign   diag_data_out  =  {  byte_3_r,
                                 byte_2_r,
                                 byte_1_r,
                                 diag_hold , 
                                 diag_state 
                              }; 

   always @( posedge clk ) begin 
      if ( rst ) begin 
         state_r_1d  <= ST_IDLE ; 
      end else begin 
         state_r_1d  <= state_r ; 
      end
   end


   always @( posedge clk ) begin 
      if ( rst ) begin 
         diag_wr_en  <= 1'b0 ; 
         diag_state  <= 'h0 ; 
         diag_hold   <= 'h0 ; 
         tick_cnt   <= 'h0 ; 
      end else if ( state_r   != state_r_1d ) begin 
         diag_wr_en  <= 1'b1 ; 
         diag_state  <= state_r_1d ; 
         diag_hold   <= tick_cnt ; 
         tick_cnt    <= 'h0 ; 
      end else begin
         diag_wr_en  <= 1'b0 ; 
         if ( cycle_tick & (tick_cnt !=  8'hFF ) ) begin  
            tick_cnt <= tick_cnt + 8'h01 ; 
         end 
      end 
   end 



   always @( posedge clk ) begin 
      if ( rst ) begin 
         cycle_cnt  <= 'h0 ;  
      end else begin 
         if ( cycle_tick ) begin 
            cycle_cnt  <= 'h0 ;  
         end else begin 
            cycle_cnt   <= cycle_cnt   + 'b1 ;  
         end
      end 
   end 

   assign cycle_tick  =  ( cycle_cnt == CYCLE_NUM_PER_TICK ) ; 




   //---------------------------------------
   //   Output interface signals  
   //---------------------------------------


   

   assign   ps2_byte_1      =  byte_1_r ; 
   assign   ps2_byte_2      =  byte_2_r ; 
   assign   ps2_byte_3      =  byte_3_r ; 
   assign   ps2_byte_valid  =  byte_valid_r ; 
   
   

endmodule    
