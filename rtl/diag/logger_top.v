module logger_top
#(
   parameter  DATA_WIDTH  =  36
)
(
   input  wire                   clk,
   input  wire                   rst,
   input  wire                   mouse_wr_en,
   input  wire [DATA_WIDTH-1:0]  mouse_data_in, 
   input  wire                   trigger  
); 

   reg   mouse_rd_start ; 
   wire  trigger_pos_edge ; 
   logger  mouse_ctrl_logger (
      .clk      ( clk            ), //i
      .rst      ( rst            ), //i
      .wr_en    ( mouse_wr_en    ), //i
      .data_in  ( mouse_data_in  ), //i
      .rd_start ( mouse_rd_start )  //i
   );

   reg   trigger_1d ; 
   assign   trigger_pos_edge = trigger & ( ~ trigger_1d ) ; 

   always @( posedge clk ) begin 
         mouse_rd_start <= trigger_pos_edge ; 
         trigger_1d     <= trigger ; 
   end 
   
endmodule 
