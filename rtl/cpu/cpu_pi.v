`timescale  1ns / 100ps 
`default_nettype  none 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   12/04/2017 
// Design Name: 
// Module Name:   cpu_pi 
// Function:      cpu register configuation through processor interface      
//
// Note: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//
module   cpu_pi   (

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

   // --- setting relates to CPU  
   output wire        inst_update,
   output wire [9:0]  inst_address,
   output wire [17:0] inst_data_out,  
   output wire        remap,

   // --- status from other modules
   input  wire        interrupt_uart,
   input  wire        interrupt_alu,
   input  wire        interrupt_mouse

) ; 

   parameter REG_CPU_STATUS_ADDR      =  4'h0;
   parameter REG_CPU_CONTROL_ADDR     =  4'h1;
   parameter REG_CPU_INST_LOW_ADDR    =  4'h2;
   parameter REG_CPU_INST_HIGH_ADDR   =  4'h3;
   parameter REG_CPU_INST_PA_ADDR     =  4'h4;
   parameter REG_CPU_ADDR_LOW_ADDR    =  4'h5;
   parameter REG_CPU_ADDR_HIGH_ADDR   =  4'h6;

   wire        reg_control_wr_stb;
   wire        reg_inst_low_wr_stb;
   wire        reg_inst_high_wr_stb;
   wire        reg_inst_pa_wr_stb;
   wire        reg_addr_low_wr_stb;
   wire        reg_addr_high_wr_stb;
   reg [7:0]   reg_control       =  'h00  ;         
   reg [7:0]   reg_inst_low;
   reg [7:0]   reg_inst_high;
   reg [7:0]   reg_inst_pa;
   reg [7:0]   reg_addr_low;
   reg [7:0]   reg_addr_high;
   reg         reg_intr_alu_r; 
   reg         reg_intr_mouse_r;
   reg         reg_intr_uart_r;
   wire        reg_addr_inc_en;        
   reg         codeword_done; 
 // -------------------------------------------------------------------------------
 //    Register write address decoder    
 // -------------------------------------------------------------------------------

   assign   reg_control_wr_stb      =  (  pi_addr  == REG_CPU_CONTROL_ADDR )    & pi_wr_en & pi_blk_sel ; 
   assign   reg_inst_low_wr_stb     =  (  pi_addr  == REG_CPU_INST_LOW_ADDR )   & pi_wr_en & pi_blk_sel ; 
   assign   reg_inst_high_wr_stb    =  (  pi_addr  == REG_CPU_INST_HIGH_ADDR )  & pi_wr_en & pi_blk_sel ; 
   assign   reg_inst_pa_wr_stb      =  (  pi_addr  == REG_CPU_INST_PA_ADDR )    & pi_wr_en & pi_blk_sel ; 
   assign   reg_addr_low_wr_stb     =  (  pi_addr  == REG_CPU_ADDR_LOW_ADDR )   & pi_wr_en & pi_blk_sel ; 
   assign   reg_addr_high_wr_stb    =  (  pi_addr  == REG_CPU_ADDR_HIGH_ADDR )  & pi_wr_en & pi_blk_sel ; 

 // -------------------------------------------------------------------------------
 //    Register Write    
 // -------------------------------------------------------------------------------

   always @( posedge clk ) begin 
      if ( reg_control_wr_stb )      reg_control     <= pi_wr_data[7:0] ; 
      if ( reg_inst_low_wr_stb )     reg_inst_low    <= pi_wr_data[7:0] ; 
      if ( reg_inst_high_wr_stb )    reg_inst_high   <= pi_wr_data[7:0] ; 
      if ( reg_inst_pa_wr_stb )      reg_inst_pa     <= pi_wr_data[7:0] ; 
      if ( reg_addr_low_wr_stb )     reg_addr_low    <= pi_wr_data[7:0] ; 
      if ( reg_addr_high_wr_stb )    reg_addr_high   <= pi_wr_data[7:0] ; 

      if ( reg_addr_inc_en && codeword_done ) begin 
         { reg_addr_high[1:0], reg_addr_low } <= ( inst_address + 10'b1 ) & {10{1'b1}} ; 
      end 

   end 


   always @( posedge clk ) begin 
      if ( rst ) begin 
         reg_intr_alu_r   <= 1'b0; 
         reg_intr_mouse_r <= 1'b0;
         reg_intr_uart_r  <= 1'b0;
      end else begin
         if ( pi_rd_en & pi_blk_sel & ( pi_addr == REG_CPU_STATUS_ADDR ) ) begin 
            reg_intr_alu_r   <= 1'b0; 
            reg_intr_mouse_r <= 1'b0;
            reg_intr_uart_r  <= 1'b0;
         end else begin 
            
            if ( interrupt_mouse ) begin 
               reg_intr_mouse_r <= 1'b1 ; 
            end

            if ( interrupt_uart ) begin 
               reg_intr_uart_r   <= 1'b1 ; 
            end

            if ( interrupt_alu ) begin 
               reg_intr_alu_r    <= 1'b1 ; 
            end

         end
      end 
   end


 // -------------------------------------------------------------------------------
 //    Register  rename    
 // -------------------------------------------------------------------------------
   assign   remap             =  reg_control[0] ; 
   assign   reg_addr_inc_en   =  reg_control[1];
   assign   inst_data_out     =  { reg_inst_pa[1:0], reg_inst_high, reg_inst_low} ; 
      
   assign   inst_address      =  { reg_addr_high[1:0], reg_addr_low} ; 

   always @( posedge clk ) begin 
       codeword_done <= reg_inst_pa_wr_stb ;   
   end

   assign  inst_update       =   codeword_done;  

 // -------------------------------------------------------------------------------
 //    Register  read    
 // -------------------------------------------------------------------------------

   always @(*) begin 
      pi_rd_data  =  8'h00;
      if ( pi_rd_en & pi_blk_sel ) begin 
         case ( pi_addr ) 
            REG_CPU_STATUS_ADDR   :  pi_rd_data  =  {  5'b00000, reg_intr_alu_r, reg_intr_mouse_r, reg_intr_uart_r } ;  
            REG_CPU_INST_LOW_ADDR :  pi_rd_data  = reg_inst_low;
            REG_CPU_INST_HIGH_ADDR : pi_rd_data  = reg_inst_high;
            REG_CPU_INST_PA_ADDR  :  pi_rd_data  = reg_inst_pa;
         endcase 
      end
   end
 // -------------------------------------------------------------------------------
 //    Interface connection     
 // -------------------------------------------------------------------------------


endmodule     
