//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   13/02/2017 
// Design Name: 
// Module Name:   alu_pi 
// Function:      register configuation through processor interface      
//
// Note: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//
module   alu_pi   (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   // --- uP interface
   input  wire        pi_blk_sel, 
   input  wire [3:0]  pi_addr, 
   input  wire        pi_wr_en, 
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output reg  [7:0]  pi_rd_data,
   input  wire        interrupt_ack, 
   output wire        interrupt,
   // --- engine interface
   output reg         alu_go_r,
   output wire        alu_en_r,
   output wire [3:0]  alu_func_r,
   output wire [31:0] alu_op_a_r, 
   output wire [31:0] alu_op_b_r, 
   input  wire        alu_op_done,
   input  wire [31:0] q_in, 
   input  wire [31:0] r_in 
) ; 


`include "alu_pi.vh"

 wire    reg_ctrl_status_wr_stb;
 wire    reg_a_0_wr_stb;   
 wire    reg_a_1_wr_stb;   
 wire    reg_a_2_wr_stb;   
 wire    reg_a_3_wr_stb;   
 wire    reg_b_0_wr_stb;   
 wire    reg_b_1_wr_stb;   
 wire    reg_b_2_wr_stb;   
 wire    reg_b_3_wr_stb;   

 wire       reg_go_in, reg_en_in, reg_int_mask_in, reg_clr_in; 
 wire [3:0] reg_func_in;
 wire [7:0] reg_a_0_in;
 wire [7:0] reg_a_1_in;
 wire [7:0] reg_a_2_in;
 wire [7:0] reg_a_3_in;
 wire [7:0] reg_b_0_in;
 wire [7:0] reg_b_1_in;
 wire [7:0] reg_b_2_in;
 wire [7:0] reg_b_3_in;


 reg  [7:0] reg_ctrl_status;
 reg  [7:0] reg_a_0;
 reg  [7:0] reg_a_1;
 reg  [7:0] reg_a_2;
 reg  [7:0] reg_a_3;
 reg  [7:0] reg_b_0;
 reg  [7:0] reg_b_1;
 reg  [7:0] reg_b_2;
 reg  [7:0] reg_b_3;

 reg  [31:0]   reg_q_r;
 reg  [31:0]   reg_r_r;

 wire       alu_clr_r ;  
 wire       alu_busy_r;
 wire       alu_int_mask_r;

 // -------------------------------------------------------------------------------
 //    Register write strobes   
 // -------------------------------------------------------------------------------

   assign   reg_ctrl_status_wr_stb  =  ( pi_addr === REG_ALU_CTRL_STATUS_ADDR ) & pi_wr_en & pi_blk_sel ;  

   assign   reg_a_0_wr_stb  = ( pi_addr == REG_ALU_A_0_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_a_1_wr_stb  = ( pi_addr == REG_ALU_A_1_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_a_2_wr_stb  = ( pi_addr == REG_ALU_A_2_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_a_3_wr_stb  = ( pi_addr == REG_ALU_A_3_ADDR ) & pi_wr_en & pi_blk_sel ;  

   assign   reg_b_0_wr_stb  = ( pi_addr == REG_ALU_B_0_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_b_1_wr_stb  = ( pi_addr == REG_ALU_B_1_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_b_2_wr_stb  = ( pi_addr == REG_ALU_B_2_ADDR ) & pi_wr_en & pi_blk_sel ;  
   assign   reg_b_3_wr_stb  = ( pi_addr == REG_ALU_B_3_ADDR ) & pi_wr_en & pi_blk_sel ;  


 // -------------------------------------------------------------------------------
 //    Register write data distribution    
 // -------------------------------------------------------------------------------

   assign   reg_go_in         =  pi_wr_data[0] ; 
   assign   reg_en_in         =  pi_wr_data[1] ; 
   assign   reg_int_mask_in   =  pi_wr_data[2] ; 
   assign   reg_clr_in        =  pi_wr_data[3] ; 
   assign   reg_func_in       =  pi_wr_data[7:4] ; 

   assign   reg_a_0_in        =  pi_wr_data[7:0] ; 
   assign   reg_a_1_in        =  pi_wr_data[7:0] ; 
   assign   reg_a_2_in        =  pi_wr_data[7:0] ; 
   assign   reg_a_3_in        =  pi_wr_data[7:0] ; 

   assign   reg_b_0_in        =  pi_wr_data[7:0] ; 
   assign   reg_b_1_in        =  pi_wr_data[7:0] ; 
   assign   reg_b_2_in        =  pi_wr_data[7:0] ; 
   assign   reg_b_3_in        =  pi_wr_data[7:0] ; 

 // -------------------------------------------------------------------------------
 //    Register Write    
 // -------------------------------------------------------------------------------

   always @( posedge clk ) begin 
      if ( rst ) begin 
         reg_ctrl_status <= 'h0;
         reg_a_0 <= 'h0;
         reg_a_1 <= 'h0;
         reg_a_2 <= 'h0;
         reg_a_3 <= 'h0;
         reg_b_0 <= 'h0;
         reg_b_1 <= 'h0;
         reg_b_2 <= 'h0;
         reg_b_3 <= 'h0;
      end else begin    
         if ( reg_ctrl_status_wr_stb == 1'b1 ) begin 
            reg_ctrl_status[1]   <= reg_en_in;
            reg_ctrl_status[2]   <= reg_int_mask_in;
            reg_ctrl_status[3]   <= reg_clr_in;
            reg_ctrl_status[7:4] <= reg_func_in;
         end 

         if ( reg_ctrl_status_wr_stb & reg_go_in ) begin 
             reg_ctrl_status[0]  <= 1'b1 ; 
         end else if ( alu_clr_r || alu_op_done ) begin 
             reg_ctrl_status[0]  <= 1'b0 ; 
         end
     
         if ( reg_ctrl_status_wr_stb & reg_go_in ) begin 
             alu_go_r    <= 1'b1   ; 
         end else begin 
             alu_go_r    <= 1'b0   ; 
         end

         if ( reg_a_0_wr_stb ) reg_a_0 <= reg_a_0_in ; 
         if ( reg_a_1_wr_stb ) reg_a_1 <= reg_a_1_in ; 
         if ( reg_a_2_wr_stb ) reg_a_2 <= reg_a_2_in ; 
         if ( reg_a_3_wr_stb ) reg_a_3 <= reg_a_3_in ; 
         if ( reg_b_0_wr_stb ) reg_b_0 <= reg_b_0_in ; 
         if ( reg_b_1_wr_stb ) reg_b_1 <= reg_b_1_in ; 
         if ( reg_b_2_wr_stb ) reg_b_2 <= reg_b_2_in ; 
         if ( reg_b_3_wr_stb ) reg_b_3 <= reg_b_3_in ; 
      end
   end 

  always @( posedge clk ) begin 
    if ( rst ) begin 
       reg_q_r  <=  'b0 ; 
       reg_r_r  <=  'b0 ; 
    end else begin 
      if ( alu_op_done ) begin 
          reg_q_r  <=  q_in ; 
          reg_r_r  <=  r_in ; 
      end
    end
  end
 

 // -------------------------------------------------------------------------------
 //    Register  rename    
 // -------------------------------------------------------------------------------

   assign   alu_busy_r  =  reg_ctrl_status[0] ; 
   assign   alu_en_r    =  reg_ctrl_status[1] ; 
   assign   alu_int_mask_r    =  reg_ctrl_status[2]; 
   assign   alu_clr_r   =  reg_ctrl_status[3] ; 
   assign   alu_func_r  =  reg_ctrl_status[7:4] ; 
   assign   alu_op_a_r  =  { reg_a_3, reg_a_2, reg_a_1, reg_a_0 }; 
   assign   alu_op_b_r  =  { reg_b_3, reg_b_2, reg_b_1, reg_b_0 }; 
 
   
 // -------------------------------------------------------------------------------
 //    Register  read    
 // -------------------------------------------------------------------------------
   
   always @(*) begin 
      pi_rd_data  =  8'h00;
      if ( pi_rd_en & pi_blk_sel ) begin 
         case ( pi_addr ) 
            REG_ALU_CTRL_STATUS_ADDR : pi_rd_data  = { alu_func_r, 1'b0, alu_int_mask_r, alu_en_r, alu_busy_r } ; 
            REG_ALU_Q_0_ADDR  :  pi_rd_data  =  reg_q_r[7:0];  
            REG_ALU_Q_1_ADDR  :  pi_rd_data  =  reg_q_r[15:8];  
            REG_ALU_Q_2_ADDR  :  pi_rd_data  =  reg_q_r[23:16];  
            REG_ALU_Q_3_ADDR  :  pi_rd_data  =  reg_q_r[31:24];  
            REG_ALU_R_0_ADDR  :  pi_rd_data  =  reg_r_r[7:0];  
            REG_ALU_R_1_ADDR  :  pi_rd_data  =  reg_r_r[15:8];  
            REG_ALU_R_2_ADDR  :  pi_rd_data  =  reg_r_r[23:16];  
            REG_ALU_R_3_ADDR  :  pi_rd_data  =  reg_r_r[31:24];  
         endcase 
      end     
   end


   assign   interrupt   =  1'b0 ; 

endmodule 
