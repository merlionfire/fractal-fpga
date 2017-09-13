module   mouse_top (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- uP interface
   input  wire        pi_blk_sel, 
   input  wire [3:0]  pi_addr, 
   input  wire        pi_wr_en, 
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data,
   input  wire        interrupt_ack, 
   output wire        interrupt,

   // --- VGA singal 
   input  wire [10:0] pixel_x,
   input  wire [10:0] pixel_y,
   output wire        cursor_on,
   output wire [2:0]  cursor_color,  

   // PS/2 interface 
   inout              ps2_clk,
   inout              ps2_data

   // diagnostic singal  
);



   // ---------------------------------------------------------
   //    Variables declaration   
   // ---------------------------------------------------------

   // Variables for cursor display 

   // Variables for mouse moving 
   wire       ps2_tx_ready;
   wire       ps2_rddata_valid;
   wire       ps2_wr_stb; 
   wire [7:0] ps2_rd_data;
   wire [7:0] ps2_wr_data;
   wire       ps2_byte_valid ; 
   wire [7:0] ps2_byte_1; 
   wire [7:0] ps2_byte_2; 
   wire [7:0] ps2_byte_3; 
   wire       ps2_tx_done;
   wire       ps2_rx_ready;

   wire [10:0]   cursor_x_orig, cursor_y_orig;   
   wire          reg_mouse_en;

   wire [2:0]    cursor_contour_color;
   wire [2:0]    cursor_inter_color; 

   wire [7:0]    cursor_x_low, cursor_y_low;
   wire [2:0]    cursor_x_high, cursor_y_high;

   wire [3:0]    cursor_pic_x_offset, cursor_pic_y_offset ; 
   wire [1:0]    cursor_pic; 

   wire [10:0]   left_pos_x;
   wire [10:0]   bot_pos_y;
   wire [9:0]    sel_length; 
   wire          soft_rst; 

   wire          mouse_click, mouse_restore, mouse_zoom;  

   // diagnostic singal  
   wire        diag_wr_en ;
   wire [35:0] diag_data_out  ;


   // ---------------------------------------------------------
   //    Instance declaration   
   // ---------------------------------------------------------
   
   // 3-D domain. 
   // cursor has 1-cylce delay output. 
   cursor  cursor_inst (
      .clk     ( clk                   ), //i
      .x       ( cursor_pic_x_offset   ), //i
      .y       ( cursor_pic_y_offset   ), //i
      .data    ( cursor_pic            )  //o
   );

   ps2_host_rxtx  ps2_host_rxtx_inst (
      .clk               ( clk               ), //i
      .rst               ( rst               ), //i
      .ps2_clk           ( ps2_clk           ), //i
      .ps2_data          ( ps2_data          ), //i
      .ps2_wr_stb        ( ps2_wr_stb        ), //i
      .ps2_wr_data       ( ps2_wr_data       ), //i
      .ps2_tx_done       ( ps2_tx_done       ), //o
      .ps2_tx_ready      ( ps2_tx_ready      ), //o
      .ps2_rddata_valid  ( ps2_rddata_valid  ), //o
      .ps2_rd_data       ( ps2_rd_data       ), //o
      .ps2_rx_ready      ( ps2_rx_ready      )  //o
   );

   mouse_ctrl  mouse_ctrl_inst (
      .clk              ( clk              ), //i
      .rst              ( rst              ), //i
      .ps2_tx_ready     ( ps2_tx_ready     ), //i
      .ps2_rddata_valid ( ps2_rddata_valid ), //i
      .ps2_rd_data      ( ps2_rd_data      ), //i
      .ps2_wr_stb       ( ps2_wr_stb       ), //o
      .ps2_wr_data      ( ps2_wr_data      ), //o
      .ps2_byte_valid   ( ps2_byte_valid   ), //o
      .ps2_byte_1       ( ps2_byte_1       ), //o
      .ps2_byte_2       ( ps2_byte_2       ), //o
      .ps2_byte_3       ( ps2_byte_3       ), //o
      .diag_wr_en       ( diag_wr_en       ), //o
      .diag_data_out    ( diag_data_out    )  //o
   );

   region_select  region_select_inst (
      .clk                  ( clk                  ), //i
      .rst                  ( rst                  ), //i
      .pixel_x              ( pixel_x              ), //i
      .pixel_y              ( pixel_y              ), //i
      .cursor_on            ( cursor_on            ), //o
      .cursor_color         ( cursor_color         ), //o
      .ps2_byte_valid       ( ps2_byte_valid       ), //i
      .ps2_byte_1           ( ps2_byte_1           ), //i
      .ps2_byte_2           ( ps2_byte_2           ), //i
      .ps2_byte_3           ( ps2_byte_3           ), //i
      .reg_mouse_en         ( reg_mouse_en         ), //i
      .cursor_x_orig        ( cursor_x_orig        ), //i
      .cursor_y_orig        ( cursor_y_orig        ), //i
      .cursor_contour_color ( cursor_contour_color ), //i
      .cursor_inter_color   ( cursor_inter_color   ), //i
      .cursor_x_low         ( cursor_x_low         ), //o
      .cursor_y_low         ( cursor_y_low         ), //o
      .cursor_x_high        ( cursor_x_high        ), //o
      .cursor_y_high        ( cursor_y_high        ), //o
      .mouse_zoom           ( mouse_zoom           ), //o
      .mouse_restore        ( mouse_restore        ), //o
      .mouse_click          ( mouse_click          ), //o
      .left_pos_x           ( left_pos_x           ), //o
      .bot_pos_y            ( bot_pos_y            ), //o
      .sel_length           ( sel_length           ), //o
      .soft_rst             ( soft_rst             ), //o
      .cursor_pic           ( cursor_pic           ), //i
      .cursor_pic_x_offset  ( cursor_pic_x_offset  ), //o
      .cursor_pic_y_offset  ( cursor_pic_y_offset  ), //o
      .interrupt_ack        ( interrupt_ack        ), //i
      .interrupt            ( interrupt            )  //o
   );

   mouse_pi  mouse_pi_inst (
      .clk                  ( clk                  ), //i
      .rst                  ( rst                  ), //i
      .pi_blk_sel           ( pi_blk_sel           ), //i
      .pi_addr              ( pi_addr              ), //i
      .pi_wr_en             ( pi_wr_en             ), //i
      .pi_rd_en             ( pi_rd_en             ), //i
      .pi_wr_data           ( pi_wr_data           ), //i
      .pi_rd_data           ( pi_rd_data           ), //o
      .cursor_x_orig        ( cursor_x_orig        ), //o
      .cursor_y_orig        ( cursor_y_orig        ), //o
      .reg_mouse_en         ( reg_mouse_en         ), //o
      .cursor_contour_color ( cursor_contour_color ), //o
      .cursor_inter_color   ( cursor_inter_color   ), //o
      .cursor_x_low         ( cursor_x_low         ), //i
      .cursor_y_low         ( cursor_y_low         ), //i
      .cursor_x_high        ( cursor_x_high        ), //i
      .cursor_y_high        ( cursor_y_high        ), //i
      .left_pos_x           ( left_pos_x           ), //i
      .bot_pos_y            ( bot_pos_y            ), //i
      .sel_length           ( sel_length           ), //i
      .soft_rst             ( soft_rst             ), //i
      .mouse_click          ( mouse_click          ), //i
      .mouse_restore        ( mouse_restore        ), //i
      .mouse_zoom           ( mouse_zoom           )  //i
   );

   logger_top  logger_top_inst (
      .clk           ( clk                 ), //i
      .rst           ( rst                 ), //i
      .mouse_wr_en   ( diag_wr_en          ), //i
      .mouse_data_in ( diag_data_out       ), //i
      .trigger       ( ps2_byte_valid      )  //i
   );



endmodule 
