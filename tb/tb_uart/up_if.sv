
interface   up_if ( input logic    clk , input logic    rst) ; 

   logic       pi_blk_sel;
   logic       pi_wr_en, pi_rd_en;
   logic       interrupt, interrupt_ack ; 
   logic [7:0] pi_wr_data;
   logic [7:0] pi_rd_data;
   logic [3:0] pi_addr; 

   task write_reg( input logic [3:0]   addr, logic [7:0] data )  ;
      @( posedge clk )  ; 
      #1 ; 
      pi_blk_sel     =  1'b1 ; 
      pi_addr        =  addr ;
      pi_wr_data     =  data ; 
      @( posedge clk )  ; 
      #1 ; 
      pi_wr_en       =  1'b1 ; 
      @( posedge clk )  ; 
      pi_wr_en       =  1'b0 ; 
      pi_blk_sel     =  1'b0 ; 
   endtask 

   task read_reg( input logic [3:0]   addr,  output logic [7:0] data_out  )  ;

      @( posedge clk )  ; 
      #1 ; 
      pi_blk_sel     =  1'b1 ; 
      pi_addr        =  addr ;
      @( posedge clk )  ; 
      #1 ; 
      pi_rd_en       =  1'b1 ; 
      @( posedge clk )  ; 
      data_out       =  pi_rd_data ; 
      pi_rd_en       =  1'b0 ; 
      pi_blk_sel     =  1'b0 ; 
   endtask  

   always @( negedge rst )  begin
      pi_blk_sel     =  1'b0 ; 
      pi_addr        =  'h0  ;
      pi_wr_en       =  1'b0 ; 
      pi_rd_en       =  1'b0 ; 
      pi_wr_data     =  'h00 ; 
   end 

endinterface

