//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    logger 
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
module logger
#(
   parameter  DATA_WIDTH  =  36
)
(
   input  wire                   clk,
   input  wire                   rst,
   input  wire                   wr_en,
   input  wire [DATA_WIDTH-1:0]  data_in, 
   input  wire                   rd_start  
) ; 


   reg   rd_en ; 
   wire  full, empty ; 
   reg [DATA_WIDTH-1:0]  data_out ; 
   wire [DATA_WIDTH-1:0]  dout ; 
   wire  rd_valid ; 
   //synthesis attribute keep of data_out is "true"

   logger_fifo logger_fifo_inst (
     .clk         (clk), // input clk
     .rst         (rst), // input rst
     .din         (data_in), // input [35 : 0] din
     .wr_en       (wr_en), // input wr_en
     .rd_en       (rd_en), // input rd_en
     .valid       (rd_valid), // output valid
     .dout        (dout), // output [35 : 0] dout
     .full        (full), // output full
     .empty       (empty) // output empty
   );



   always @(posedge clk ) begin 
      if ( rst ) begin 
         rd_en <= 1'b0;
      end begin 
         if ( rd_start ) begin
            rd_en <= 1'b1 ; 
         end else if ( empty ) begin 
            rd_en <= 1'b0 ; 
         end 
      end
   end


   always @( posedge clk ) begin 
      if ( rd_valid ) begin 
         data_out <= dout ; 
      end
   end 


endmodule 
