`ifndef UP_IF__SV
`define UP_IF__SV
interface   up_if ( input logic    clk ) ; 

   parameter  REG_DISP_BLK_ADDR  =  4'h0 ; 
   parameter  REG_DDR2_MGR_ADDR  =  4'h1 ;  
   parameter  REG_FRAC_UNIT_ADDR =  4'h2 ;  
   parameter  REG_MOUSE_ADDR     =  4'h3 ;
   parameter  REG_ALU_ADDR       =  4'h4 ;
   parameter  REG_UART_ADDR      =  4'h5 ;
   parameter  REG_CPU_ADDR       =  4'h6 ;
   parameter  REG_DIAG_ADDR      =  4'hf ;

   parameter  DISP_BLK_SEL_BIT   =  4'h0 ;  
   parameter  DDR2_MGR_SEL_BIT   =  4'h1 ;    
   parameter  FRAC_UNIT_SEL_BIT  =  4'h2 ; 
   parameter  MOUSE_SEL_BIT      =  4'h3 ;
   parameter  ALU_SEL_BIT        =  4'h4 ;
   parameter  UART_SEL_BIT       =  4'h5 ;
   parameter  CPU_SEL_BIT        =  4'h6 ;
   parameter  DIAG_SEL_BIT       =  4'hf ;

   bit         rst;
   logic [15:0] pi_blk_sel;
   logic       pi_wr_en;
   logic       pi_rd_en;
   logic [7:0] pi_wr_data;
   logic [7:0] pi_alu_rd_data;
   logic [7:0] pi_mouse_rd_data;
   logic [7:0] pi_cpu_rd_data;
   logic [3:0] pi_addr; 
   logic [7:0] port_id;
   logic       write_strobe;
   logic       read_strobe;
   logic [7:0] out_port;
   logic [7:0] in_port;
   logic       interrupt;
   logic       interrupt_ack ; 
   logic       interrupt_alu;
   logic       interrupt_uart =  1'b0;
   logic       interrupt_mouse;
   
   clocking cb @( posedge clk ) ; 
      default input #1step output #2;
      input    clk;
      input    #1ns  output #2ns rst;
      input    pi_sel =  pi_blk_sel[MOUSE_SEL_BIT];
      input    pi_addr;
      input    pi_wr_en;
      input    pi_rd_en; 
      input    pi_wr_data;
      input    interrupt_ack ; 

   endclocking 

   modport  master ( 
         input    clk,
         input    rst,
         output   port_id,
         output   write_strobe,
         output   read_strobe,
         output   out_port,
         input    in_port,
         input    interrupt_alu,
         input    interrupt_uart,
         input    interrupt_mouse,
         output   interrupt_ack
   );

   modport  slave_cpu (
         input    clk,
         input    rst,
         input    .pi_blk_sel( pi_blk_sel[CPU_SEL_BIT] ),
         input    pi_addr,
         input    pi_wr_en,
         input    pi_rd_en, 
         input    pi_wr_data,
         output   .pi_rd_data ( pi_cpu_rd_data ) 
   );

   modport  slave_alu (
         input    clk,
         input    rst,
         input    .pi_blk_sel ( pi_blk_sel[ALU_SEL_BIT] ),
         input    pi_addr,
         input    pi_wr_en,
         input    pi_rd_en, 
         input    pi_wr_data,
         output   .pi_rd_data ( pi_alu_rd_data ) ,
         output   .interrupt  ( interrupt_alu  ) ,
         input    interrupt_ack
   );
/*
   modport  slave_mouse (
         input    clk,
         input    rst,
         input    .pi_sel ( pi_blk_sel[MOUSE_SEL_BIT] ),
         input    pi_addr,
         input    pi_wr_en,
         input    pi_rd_en, 
         input    pi_wr_data,
         output   .pi_rd_data ( pi_mouse_rd_data ) ,
         output   .interrupt_slave  ( interrupt_mouse  ) ,
         input    interrupt_ack
   );
*/
   modport  slave_mouse ( 
         clocking cb, 
         output   .pi_rd_data ( pi_mouse_rd_data ) ,
         output   .interrupt_slave  ( interrupt_mouse  ) 
   ); 

   modport  monitor ( 
         input    clk,
         input    rst,
         input    pi_blk_sel,
         input    pi_addr,
         input    pi_wr_en,
         input    pi_wr_data
   );

   //*******************************************************************//
   //     CPU strobe signals connection                                 // 
   //*******************************************************************//

   assign   #1 pi_wr_en    =   write_strobe ;
   assign   #1 pi_rd_en    =   read_strobe ; 
   assign   #1 pi_wr_data  =   out_port ; 
   assign   #2 in_port     =   pi_mouse_rd_data | pi_alu_rd_data | pi_cpu_rd_data ;  

   //*******************************************************************//
   //     Address decoder                                               // 
   //*******************************************************************//

   assign   pi_addr     =  port_id[3:0] ; 
   always_comb begin  
      pi_blk_sel   =  'h0;    
      case  ( port_id[7:4] ) 
         REG_DISP_BLK_ADDR    :  pi_blk_sel[DISP_BLK_SEL_BIT]   =  1'b1 ; 
         REG_DDR2_MGR_ADDR    :  pi_blk_sel[DDR2_MGR_SEL_BIT]   =  1'b1 ; 
         REG_FRAC_UNIT_ADDR   :  pi_blk_sel[FRAC_UNIT_SEL_BIT]  =  1'b1 ; 
         REG_MOUSE_ADDR       :  pi_blk_sel[MOUSE_SEL_BIT]      =  1'b1 ; 
         REG_ALU_ADDR         :  pi_blk_sel[ALU_SEL_BIT]        =  1'b1 ; 
         REG_UART_ADDR        :  pi_blk_sel[UART_SEL_BIT]       =  1'b1 ; 
         REG_CPU_ADDR         :  pi_blk_sel[CPU_SEL_BIT]        =  1'b1 ; 
         REG_DIAG_ADDR        :  pi_blk_sel[DIAG_SEL_BIT]       =  1'b1 ; 
      endcase 
   end
  
   /*
   always_ff @(posedge clk ) begin 
      if ( (~rst) && pi_rd_en ) begin 
           $display("@%0t: [DEBUG] Interface: ", $time) ; 
           $display("\t\tpi_mouse_rd_data = %2h", pi_mouse_rd_data) ; 
           $display("\t\tpi_alu_rd_data   = %2h", pi_alu_rd_data); 
           $display("\t\tpi_cpu_rd_data   = %2h", pi_cpu_rd_data); 
      end
   end
   */
endinterface

`endif //UP_IF__SV
