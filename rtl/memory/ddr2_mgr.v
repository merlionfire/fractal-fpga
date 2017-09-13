`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    02:24:07 07/27/2015 
// Design Name: 
// Module Name:    ddr2_mgr 
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

module ddr2_mgr(
    
   // --- clock and reset 
   input  wire        clk0,
   input  wire        rst0,
   input  wire        clk90,
   input  wire        rst90,
   input  wire        rst180,
   input  wire        pi_clk,
   input  wire        pi_rst, 
   
   // --- Mig User Interface Signals
   //   Address and command 
   output wire [2:0]  mig_user_input_cmds,
   output wire        mig_burst_done,
   output wire [24:0] mig_user_input_addr,
   //   Status output from MIG
   input  wire        mig_init_done,
   input  wire        mig_user_cmd_ack,
   //   Write 
   output wire [31:0] mig_user_input_data,
   output wire [3:0]  mig_user_input_mask,
   //   read
   input  wire [31:0] mig_user_output_data,
   input  wire        mig_user_data_valid,
   //   refresh
   input  wire        mig_auto_ref_req,
   input  wire        mig_ar_done,

   // --- uP interface 
   input  wire        pi_blk_sel,
   input  wire [3:0]  pi_addr,
   input  wire        pi_wr_en,
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data,

   // --- frame_buffer interface 
   input  wire        rd_mem_req,
   input  wire [24:0] rd_mem_addr, 
   input  wire [9:0]  rd_xfr_len, 
   output wire        rd_mem_grant,     
   output wire [31:0] rd_data,
   output wire        rd_data_valid
);

`include "ddr2_512M16_mig_parameters_0.v"

   localparam BANK_0 =  2'b00 ; 
   localparam BANK_1 =  2'b01 ; 
   localparam BANK_2 =  2'b10 ; 
   localparam BANK_3 =  2'b11 ; 

   parameter  WORDS_PER_XFR   = 4'h2 ;  
   parameter  WORDS_PER_BURST = 4'h4 ;     
   
   // ---------------------------------------------------------
   //    Variables declaration   
   // ---------------------------------------------------------
   reg   [31:0]   write_data_0, write_data_1 ; 
   reg   [23:0]   ddr_addr_reg; 
   reg   wr_mem_req ;
   wire  wr_mem_req_sync ; 
   wire  [22:0]   wr_16bit_addr ;  
   wire  reg_wr_strobe;
   wire  refresh_locked; 
   reg   refresh_active;
   reg   wr_cmd_active ;
   reg   [3:0]  state_r, state_nxt;
   reg   [2:0]  cmd_r, cmd_nxt;
   reg   [9:0]  xfr_len_r, xfr_len_nxt ;  
   reg   [9:0]  xfr_cnt_r, xfr_cnt_nxt ;  
   reg   [24:0] addr_r, addr_nxt ; 
   wire  [24:0] wr_mem_addr  ;
   reg   burst_done_r, burst_done_nxt ; 
   reg   rd_grant_r, rd_grant_nxt, wr_grant_r, wr_grant_nxt  ; 
   wire  last_req_xfr ; 
   wire  addr_inc;
   
   reg   [31:0] data_output_r ; 
   wire  ddr2_busy ;  


   assign reg_wr_strobe = pi_wr_en && pi_blk_sel ; 


   
   always @( posedge pi_clk ) begin    
      if ( pi_rst ) begin 
         write_data_0  <= 32'h0 ; 
         write_data_1  <= 32'h0 ; 
         ddr_addr_reg  <= 24'h0 ;  
      end else begin 
         if ( reg_wr_strobe ) begin 
            case ( pi_addr ) 
               4'h1  : write_data_0[7:0]   <= pi_wr_data ; 
               4'h2  : write_data_0[15:8]  <= pi_wr_data ; 
               4'h3  : write_data_0[23:16] <= pi_wr_data ; 
               4'h4  : write_data_0[31:24] <= pi_wr_data ; 
               4'h5  : write_data_1[7:0]   <= pi_wr_data ; 
               4'h6  : write_data_1[15:8]  <= pi_wr_data ; 
               4'h7  : write_data_1[23:16] <= pi_wr_data ; 
               4'h8  : write_data_1[31:24] <= pi_wr_data ; 
               4'h9  : ddr_addr_reg[7:0]   <= pi_wr_data ;  
               4'ha  : ddr_addr_reg[15:8]  <= pi_wr_data ;  
               4'hb  : ddr_addr_reg[23:16] <= pi_wr_data ;  
            endcase
         end
      end
   end
  
   assign pi_rd_data = (  pi_rd_en && pi_blk_sel &&  ( pi_addr == 4'h0 ) ) ? { 7'b0000000, ddr2_busy } : 8'h00 ; 


   always @( posedge pi_clk ) begin    
      if ( pi_rst             ) wr_mem_req   <= 1'b0; 
      else if ( wr_cmd_active ) wr_mem_req   <= 1'b0; 
      else if ( reg_wr_strobe && ( pi_addr == 4'h0 ) && pi_wr_data[0] ) 
         wr_mem_req   <= 1'b1; 
   end

   synchro #(.INITIALIZE("LOGIC1")) synchro_wr_req (
      .clk     (  clk0            ),
      .async   (  wr_mem_req      ),
      .sync    (  wr_mem_req_sync )
   ) ; 


   always @( negedge  clk0 ) begin    
     if ( rst180 )                wr_cmd_active   <= 1'b0 ; 
     else if ( wr_mem_req_sync )  wr_cmd_active   <= 1'b1 ; 
     else if ( wr_grant_r )       wr_cmd_active   <= 1'b0 ; 
   end


   always @( negedge  clk0 ) begin    
     if ( rst180 )                refresh_active  <= 1'b0 ; 
     else if ( mig_auto_ref_req ) refresh_active  <= 1'b1 ; 
     else if ( mig_ar_done )      refresh_active  <= 1'b0 ; 
   end

   assign refresh_locked =  mig_auto_ref_req | refresh_active ; 


   // ---------------------------------------------------------
   //    Main FSM    
   // ---------------------------------------------------------


   localparam CMD_NOP   = 3'b000,
              CMD_INIT  = 3'b010,
              CMD_WRITE = 3'b100,
              CMD_READ  = 3'b110;

   localparam ST_IDLE      = 4'h0,
              ST_INIT      = 4'h1,  
              ST_READY     = 4'h2,
              ST_WR_CMD    = 4'h3,
              ST_WR_DATA_0 = 4'h4,
              ST_WR_DATA_1 = 4'h5,
              ST_OP_DONE_0 = 4'h6,
              ST_OP_DONE_1 = 4'h7,
              ST_RD_CMD    = 4'h8,
              ST_RD_DATA   = 4'h9;

   assign   wr_mem_addr  = { ddr_addr_reg[23:1], BANK_0 }  ; 

   assign   addr_inc   =  xfr_cnt_r[0]  ; 

   // Roof number of words that are required to 32bit-align 
   // if rd_xfr_len = 0x200 , it means 0x200 * wors_per_xfr = 0x400 = 256
   // * 4 = 1024
   // 0, 1, 2,        , 0x1FE, 0x1FF , 
   // 0x1FE + 2 = 0x200 
   assign   last_req_xfr  =  ( xfr_cnt_nxt == xfr_len_r ) ? 1'b1 : 1'b0; 

   assign ddr2_busy  = ( state_r == ST_READY ) ? 1'b0 : 1'b1 ;  

   always @( negedge clk0 ) begin    
      if ( rst180 ) begin 
         cmd_r          <= CMD_NOP ; 
         addr_r         <= 'h0 ; 
         xfr_cnt_r      <= 'h0 ;   
         burst_done_r   <= 1'b0 ; 
         rd_grant_r     <= 1'b0 ; 
         wr_grant_r     <= 1'b0 ; 
         xfr_len_r      <= 'h0  ;  
         state_r        <= ST_IDLE ; 
      end else begin 
         cmd_r          <= cmd_nxt ; 
         addr_r         <= addr_nxt ;
         xfr_cnt_r      <= xfr_cnt_nxt ;   
         burst_done_r   <= burst_done_nxt ; 
         rd_grant_r     <= rd_grant_nxt ; 
         wr_grant_r     <= wr_grant_nxt ; 
         xfr_len_r      <= xfr_len_nxt ;  
         state_r        <= state_nxt  ;
      end
   end

   always @(*) begin 
      cmd_nxt           =  CMD_NOP ; 
      addr_nxt          =  addr_r  ; 
      xfr_cnt_nxt       =  'h0 ;   
      burst_done_nxt    =  1'b0 ; 
      rd_grant_nxt      =  1'b0 ; 
      wr_grant_nxt      =  1'b0 ; 
      xfr_len_nxt       =  xfr_len_r ;  
      state_nxt         =  state_r ; 
      case ( state_r ) 
         ST_IDLE : begin 
            state_nxt   =  ST_INIT ; 
            cmd_nxt     =  CMD_INIT ; 
         end
         ST_INIT : begin 
            if ( mig_init_done ) state_nxt   =  ST_READY ; 
         end
         ST_READY : begin 
            if ( ~ refresh_locked ) begin 
               if ( rd_mem_req  ) begin 
                  cmd_nxt  =  CMD_READ ; 
                  addr_nxt =  rd_mem_addr ; 
                  xfr_len_nxt = rd_xfr_len ; 
                  state_nxt =  ST_RD_CMD ;  
               end else if (  wr_cmd_active  ) begin 
                  cmd_nxt  =  CMD_WRITE ; 
                  addr_nxt =  wr_mem_addr ; 
                  state_nxt =  ST_WR_CMD ;  
               end
            end
         end
         ST_WR_CMD : begin 
            cmd_nxt  =  CMD_WRITE ; 
            if ( mig_user_cmd_ack ) begin 
               wr_grant_nxt  = 1'b1 ; 
               state_nxt =  ST_WR_DATA_0 ;  
            end
         end
         ST_WR_DATA_0 : begin 
            cmd_nxt  =  CMD_WRITE ; 
            state_nxt =  ST_WR_DATA_1 ; 
         end  
         ST_WR_DATA_1 : begin 
            cmd_nxt     = CMD_WRITE ; 
            burst_done_nxt  = 1'b1 ; 
            state_nxt   = ST_OP_DONE_0 ; 
         end  
         ST_OP_DONE_0 : begin 
            burst_done_nxt  = 1'b1 ; 
            state_nxt   = ST_OP_DONE_1 ; 
         end  
         ST_OP_DONE_1 : begin 
            if ( ~ mig_user_cmd_ack ) state_nxt   = ST_READY ; 
         end  
         ST_RD_CMD : begin 
            cmd_nxt  =  CMD_READ ; 
            if ( mig_user_cmd_ack ) begin 
               rd_grant_nxt  = 1'b1 ; 
               state_nxt     =  ST_RD_DATA ;  
            end 
         end
         ST_RD_DATA : begin 
            cmd_nxt  = CMD_READ ; 
            //xfr_cnt_nxt = xfr_cnt_r + WORDS_PER_XFR ; 
            xfr_cnt_nxt = xfr_cnt_r + 1'b1 ; 
            if ( addr_inc ) begin 
               addr_nxt =  addr_r + { WORDS_PER_BURST ,{`BANK_ADDRESS{1'b0}}  }  ;   
            end
            if ( last_req_xfr ) begin 
               burst_done_nxt  = 1'b1 ; 
               state_nxt   =  ST_OP_DONE_0 ; 
            end
         end

      endcase 
   end



   always @( posedge clk90 ) begin    
      if ( mig_user_cmd_ack && ( state_r == ST_WR_CMD ) ) data_output_r   <= write_data_0 ; 
      if ( state_r   ==  ST_WR_DATA_0 )    data_output_r   <= write_data_1 ; 
   end

   //---------------------------------------
   //   Output interface signals  
   //---------------------------------------
   
   assign mig_user_input_cmds =  cmd_r ; 
   assign mig_user_input_addr =  addr_r;       
   assign mig_user_input_data =  data_output_r ; 
   assign mig_user_input_mask =  4'h0 ; 
   assign mig_burst_done      =  burst_done_r  ; 
   assign rd_data             =  mig_user_output_data  ; 
   assign rd_data_valid       =  mig_user_data_valid   ; 
   assign rd_mem_grant        =  rd_grant_r ; 


   // ---------------------------------------------------------
   //    SVA for key signals   
   // ---------------------------------------------------------
`ifdef SVA 
   parameter SVA_XFR_LEN = 10'h200 ; 

   property LAST_RD_XFR_CHECKER ; 
      @( negedge clk0 )  
         $rose( rd_mem_grant ) |-> ## ( SVA_XFR_LEN -1 ) $rose( last_req_xfr ) ; 
   endproperty 

   assert property ( LAST_RD_XFR_CHECKER )  
      else $display( "[ASSERT ERR] The delay between and rd_mem_grant and last_req_xfr is not expected !!!" ) ; 

   cover property ( LAST_RD_XFR_CHECKER ) ;     


   property MEM_ADDR_INC_COUNTER_CHECKER ; 
      @( negedge clk0 )  
         $rose( rd_mem_grant ) |->  addr_inc[->SVA_XFR_LEN] ##1 $fell(last_req_xfr )  ; 
   endproperty 

   assert property ( MEM_ADDR_INC_COUNTER_CHECKER )  
      else $display( "[ASSERT ERR] There is no enough pulses of addr_inc during one transfer !!!" ) ; 

   cover property ( MEM_ADDR_INC_COUNTER_CHECKER ) ;     

`endif
endmodule
