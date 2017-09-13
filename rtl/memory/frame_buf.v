

module frame_buf (
  
   // --- clock and reset 
   input  wire        mem_clk0,
   input  wire        mem_clk90,
   input  wire        mem_rst,
   input  wire        disp_clk,
   // --- ddr2_mgr interface 
   output wire        rd_mem_req,
   output wire [24:0] rd_mem_addr, 
   output reg  [9:0]  rd_xfr_len, 
   input  wire        rd_mem_grant,     
   input  wire [31:0] rd_data,
   input  wire        rd_data_valid,
   // --- VGA interface
   input  wire        rd_go, 
   input  wire [12:0] req_addr_row,
   input  wire        linebuf_rd_en,  
   input  wire [10:0] linebuf_rd_addr,  
   output wire [15:0] linebuf_rd_data 
) ; 

`include "ddr2_512M16_mig_parameters_0.v"

   reg   [ `COLUMN_ADDRESS-1:0 ]  addr_col ,addr_col_nxt  ; 
   reg   [ `ROW_ADDRESS-1:0 ]     addr_row , addr_row_nxt ;  
   reg   [ `BANK_ADDRESS-1:0 ]    addr_bank   = 'h0 ; 
 
   parameter  XFR_LEN_PER_LINE  = 10'h200 ; 

   // rd_xfr_len is based on bus data width with ddr2_mgr.
   //  For example : 
   //    data width = 32bit. 
   //    rd_xfr_len = 0x200,
   //       total words required is 0x200 * 2 words ( 1 word = 16bit ) = 0x400
   //       That is 1024 words ( 1 word expresses 1 pixel )  
   wire  rd_xfr_en, rd_xfr_en_sync, rd_data_valid_sync, rd_go_sync  ;

   reg   [1:0] req_st_nxt, req_st_r ; 
   reg   rd_req_nxt, rd_req_r ; 
   reg   [9:0] rd_xfr_len_nxt ;
   wire  linebuf_wr_addr_load, linebuf_wr_en ; 
   reg   [8:0]    linebuf_half_wr_addr ; 
   wire  [9:0]    linebuf_wr_addr ; 
   wire           line_odd; 

   wire  [31:0]   linebuf_wr_data ; 

   

   // ---------------------------------------------------------
   //     address generation for ddr2_mgr 
   // ---------------------------------------------------------

   assign   rd_mem_addr =  { addr_row, addr_col, addr_bank }  ; 

   // ---------------------------------------------------------
   //    Main FSM for ddr2 read request 
   // ---------------------------------------------------------

   parameter ST_IDLE       =  2'b00,
             ST_WAIT_GRANT =  2'b01, 
             ST_PRE_XFR    =  2'b10, 
             ST_DATA_XFR   =  2'b11; 


   assign rd_xfr_en  =  req_st_r[1] ; 

   synchro synchro_rd_data_valid (.async(rd_data_valid ),.sync( rd_data_valid_sync ),.clk( ~mem_clk0 ) ) ;
   synchro synchro_rd_go         (.async( rd_go ), .sync( rd_go_sync ), .clk( ~mem_clk0 ) ) ;


   always @( negedge mem_clk0 ) begin    
      if ( mem_rst ) begin 
         req_st_r    <= ST_IDLE ; 
         rd_req_r    <= 1'b0 ;  
         addr_row    <= 'h0  ; 
         addr_col    <= 'h0  ; 
         rd_xfr_len  <= 10'h0 ; 
      end else begin 
         req_st_r    <= req_st_nxt ;
         rd_req_r    <= rd_req_nxt ;  
         addr_row    <= addr_row_nxt  ; 
         addr_col    <= addr_col_nxt  ; 
         rd_xfr_len  <= rd_xfr_len_nxt ; 
      end
   end 


   always @( * ) begin    
      req_st_nxt     =  req_st_r ; 
      rd_req_nxt     =  1'b0 ; 
      addr_row_nxt   =  addr_row; 
      addr_col_nxt   =  addr_col; 
      rd_xfr_len_nxt =  rd_xfr_len ; 
      case ( req_st_r  )  
         ST_IDLE  : begin 
            if ( rd_go_sync ) begin 
               req_st_nxt     =  ST_WAIT_GRANT ; 
               rd_req_nxt     =  1'b1 ; 
               addr_row_nxt   =  req_addr_row ;   
               addr_col_nxt   =  'h0;          //address need to be updated  
               rd_xfr_len_nxt =  XFR_LEN_PER_LINE ; 
            end 
         end
         ST_WAIT_GRANT : begin 
            rd_req_nxt  =  1'b1 ; 
            if ( rd_mem_grant ) begin 
               req_st_nxt  =  ST_PRE_XFR ; 
               rd_req_nxt  =  1'b0 ; 
            end
         end
         ST_PRE_XFR  : begin 
            if ( rd_data_valid_sync ) begin 
               req_st_nxt  =  ST_DATA_XFR ; 
            end
         end
         ST_DATA_XFR : begin 
            if ( ~ rd_data_valid_sync ) begin 
               req_st_nxt  =  ST_IDLE ; 
            end
         end
      endcase 
   end 



   // ---------------------------------------------------------
   //    buffer line between DDR2 controller and VGA display  
   // ---------------------------------------------------------


   synchro synchro_rd_xfr_en (.async(rd_xfr_en),.sync( rd_xfr_en_sync ),.clk( mem_clk90 ) ) ;

   assign  linebuf_wr_addr_load = rd_mem_grant ; 

   assign  line_odd = addr_row[0] ;    

   always @( posedge mem_clk90 ) begin    
      if ( linebuf_wr_addr_load ) linebuf_half_wr_addr <=  'h0 ; 
      else if ( rd_xfr_en_sync & rd_data_valid )   linebuf_half_wr_addr <= linebuf_half_wr_addr + 1'b1 ; 
   end

   assign  linebuf_wr_addr =  { line_odd, linebuf_half_wr_addr } ; 

   assign  linebuf_wr_en   =  rd_data_valid & rd_xfr_en_sync ;  
   assign  linebuf_wr_data =  rd_data ; 

   linebuf linebuf_inst (
       .rd_clk       (  disp_clk          ),
       .rd_addr      (  linebuf_rd_addr   ),
       .rd_data      (  linebuf_rd_data   ),
       .rd_en        (  linebuf_rd_en     ),
       .wr_data      (  linebuf_wr_data   ),
       .wr_addr      (  linebuf_wr_addr   ),
       .wr_en        (  linebuf_wr_en     ),
       .wr_clk       (  mem_clk90          )   //Instead of mem_clk90, posedge of mem_clk0 has more timing tolerance for writing date into linebuf 
   );

   


   // ---------------------------------------------------------
   //    Interface singals connection  
   // ---------------------------------------------------------

   assign   rd_mem_req  =  rd_req_r ; 
    
   // ---------------------------------------------------------
   //    Monitor
   // ---------------------------------------------------------

   reg frame_wr_fault = 1'b0 ; 

   //synthesis attribute keep of frame_wr_fault is "true"

   always @( posedge mem_clk90 ) begin    
      if ( mem_rst ) begin 
         frame_wr_fault <= 1'b0 ; 
      end else begin 
         if ( linebuf_wr_en ) begin 
            if (  ( linebuf_wr_data != { 2{16'h00_F1} } )   &&
                  ( linebuf_wr_data != { 2{16'h0F_01} } )   &&
                  ( linebuf_wr_data != { 2{16'hF0_01} } )  
               ) begin 
               frame_wr_fault <= 1'b1 ;
            end
         end
      end
   end

         



   // ---------------------------------------------------------
   //    SVA for key signals   
   // ---------------------------------------------------------
`ifdef SVA 
   parameter  SVA_XFR_LEN =  XFR_LEN_PER_LINE  ; 

   property RD_XFR_EN_AND_RD_DATA_VALID_CHECKER  ;
      @( negedge mem_clk0 )  
         $rose( rd_data_valid ) |=> ( rd_data_valid[*SVA_XFR_LEN] ) 
         within 
         $rose( rd_mem_grant ) |=> $rose(rd_xfr_en) ## [1:$] $fell(rd_xfr_en ) ;   
   endproperty 

   assert property ( RD_XFR_EN_AND_RD_DATA_VALID_CHECKER  ) 
      else $display("[ASSERT ERR] The width of rd_xfr_en is shorted than expected or rd_xfr_en is worng !!" ) ;  
   
   cover property ( RD_XFR_EN_AND_RD_DATA_VALID_CHECKER  ) ; 

         
`endif

endmodule 
/*
  linebuf linebuf0_inst (
    .hcount       (hcount_frm_pipe[10:0]),
    .pixeldata    (pixeldata0),
    .readenable   (!vcount_frm_pipe[0]),
    .memorydata   (  linebuf_wr_data   ),
    .memoryaddr   (  linebuf_wr_addr   ),
    .memorywrite  (  linebuf_wr_en     ),
    .clk(bufged_aux)
  );




  linebuf linebuf1_inst (
    .hcount(hcount_frm_pipe[10:0]),
    .pixeldata(pixeldata1),
    .readenable(vcount_frm_pipe[0]),
    .memorydata(memorydata),
    .memoryaddr(memoryaddr),
    .memorywrite(memorywrite1),
    .clk(bufged_aux));
*/
