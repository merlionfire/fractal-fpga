;;;;////////////////////////////////////////////////////////////////////////////////
;; Author: merlionfire 
;; 
;; Create Date:    06/07/2015 
;; Design Name: 
;; File Name:      picocode.m4   
;; Project Name: 
;; Target Devices: spartan3AN-4 
;; Tool versions:  picosim 
;; Description:    Firmware code for perform manset fractal set compupation.
;;                   
;; Dependencies:   m4 file. Run below commands to covert to verilog code 
;;          Cmd: 
;;             > m4 picocode.m4 > picocode.psm 
;              > picasm -i picocode.psm 
;;
;; Revision: 
;; Revision 0.01 - File Created
;; Revision 1.00 - Fractal Engin works and picture can show on the screen 
;; Revision 2.00 - Add region selection and image restore functions
;; Revision 3.00 - Add Firmware code upload through UART 
;; Revision 3.00 - Add menu on the right side of screen with parametes displaying
;;                 on the fly  

;;============================================================================
;; Ascii table 
;;============================================================================
CONSTANT ascii_CR         , 0D    ; ascii code

CONSTANT ascii_SPACE      , 20    ; ascii code
CONSTANT ascii_EXCLAIM    , 21    ; ascii code
CONSTANT ascii_DBLQUOT    , 22    ; ascii code
CONSTANT ascii_NUMSIGN    , 23    ; ascii code
CONSTANT ascii_DOLLAR     , 24    ; ascii code
CONSTANT ascii_PERCENT    , 25    ; ascii code
CONSTANT ascii_AMP        , 26    ; ascii code
CONSTANT ascii_SINQUOT    , 27    ; ascii code
CONSTANT ascii_LPAREN     , 28    ; ascii code
CONSTANT ascii_RPAREN     , 29    ; ascii code
CONSTANT ascii_ASTERISK   , 2A    ; ascii code
CONSTANT ascii_PLUS       , 2B    ; ascii code
CONSTANT ascii_COMMA      , 2C    ; ascii code
CONSTANT ascii_MINUS      , 2D    ; ascii code
CONSTANT ascii_PERIOD     , 2E    ; ascii code
CONSTANT ascii_FWDSLASH   , 2F    ; ascii code

CONSTANT ascii_0          , 30    ; ascii code
CONSTANT ascii_1          , 31    ; ascii code
CONSTANT ascii_2          , 32    ; ascii code
CONSTANT ascii_3          , 33    ; ascii code
CONSTANT ascii_4          , 34    ; ascii code
CONSTANT ascii_5          , 35    ; ascii code
CONSTANT ascii_6          , 36    ; ascii code
CONSTANT ascii_7          , 37    ; ascii code
CONSTANT ascii_8          , 38    ; ascii code
CONSTANT ascii_9          , 39    ; ascii code
CONSTANT ascii_COLON      , 3A    ; ascii code
CONSTANT ascii_SEMI       , 3B    ; ascii code
CONSTANT ascii_LESS       , 3C    ; ascii code
CONSTANT ascii_EQUAL      , 3D    ; ascii code
CONSTANT ascii_GREATER    , 3E    ; ascii code
CONSTANT ascii_QUESTION   , 3F    ; ascii code

CONSTANT ascii_CIRCAT     , 40    ; ascii code
CONSTANT ascii_A          , 41    ; ascii code
CONSTANT ascii_B          , 42    ; ascii code
CONSTANT ascii_C          , 43    ; ascii code
CONSTANT ascii_D          , 44    ; ascii code
CONSTANT ascii_E          , 45    ; ascii code
CONSTANT ascii_F          , 46    ; ascii code
CONSTANT ascii_G          , 47    ; ascii code
CONSTANT ascii_H          , 48    ; ascii code
CONSTANT ascii_I          , 49    ; ascii code
CONSTANT ascii_J          , 4A    ; ascii code
CONSTANT ascii_K          , 4B    ; ascii code
CONSTANT ascii_L          , 4C    ; ascii code
CONSTANT ascii_M          , 4D    ; ascii code
CONSTANT ascii_N          , 4E    ; ascii code
CONSTANT ascii_O          , 4F    ; ascii code

CONSTANT ascii_P          , 50    ; ascii code
CONSTANT ascii_Q          , 51    ; ascii code
CONSTANT ascii_R          , 52    ; ascii code
CONSTANT ascii_S          , 53    ; ascii code
CONSTANT ascii_T          , 54    ; ascii code
CONSTANT ascii_U          , 55    ; ascii code
CONSTANT ascii_V          , 56    ; ascii code
CONSTANT ascii_W          , 57    ; ascii code
CONSTANT ascii_X          , 58    ; ascii code
CONSTANT ascii_Y          , 59    ; ascii code
CONSTANT ascii_Z          , 5A    ; ascii code
CONSTANT ascii_LBKT       , 5B    ; ascii code
CONSTANT ascii_BKSLASH    , 5C    ; ascii code
CONSTANT ascii_RBKT       , 5D    ; ascii code
CONSTANT ascii_CARET      , 5E    ; ascii code
CONSTANT ascii_DASH       , 5F    ; ascii code

CONSTANT ascii_TICK       , 60    ; ascii code
CONSTANT ascii_a          , 61    ; ascii code
CONSTANT ascii_b          , 62    ; ascii code
CONSTANT ascii_c          , 63    ; ascii code
CONSTANT ascii_d          , 64    ; ascii code
CONSTANT ascii_e          , 65    ; ascii code
CONSTANT ascii_f          , 66    ; ascii code
CONSTANT ascii_g          , 67    ; ascii code
CONSTANT ascii_h          , 68    ; ascii code
CONSTANT ascii_i          , 69    ; ascii code
CONSTANT ascii_j          , 6A    ; ascii code
CONSTANT ascii_k          , 6B    ; ascii code
CONSTANT ascii_l          , 6C    ; ascii code
CONSTANT ascii_m          , 6D    ; ascii code
CONSTANT ascii_n          , 6E    ; ascii code
CONSTANT ascii_o          , 6F    ; ascii code

CONSTANT ascii_p          , 70    ; ascii code
CONSTANT ascii_q          , 71    ; ascii code
CONSTANT ascii_r          , 72    ; ascii code
CONSTANT ascii_s          , 73    ; ascii code
CONSTANT ascii_t          , 74    ; ascii code
CONSTANT ascii_u          , 75    ; ascii code
CONSTANT ascii_v          , 76    ; ascii code
CONSTANT ascii_w          , 77    ; ascii code
CONSTANT ascii_x          , 78    ; ascii code
CONSTANT ascii_y          , 79    ; ascii code
CONSTANT ascii_z          , 7A    ; ascii code

;; ============================================================================
;;    Other constants.
;; ============================================================================

CONSTANT ZERO             , 00    ; zero
CONSTANT ONE              , 01    ; one


;; ============================================================================
;;    Firmware Flow for fractal set compuation assisted with ALU Engine
;; ============================================================================

;; variable 
;;   px : pixel position for x
;;   cx : poisition of fractal calculation 
;; px0   =  0;  (0,767) is the origin of pixel position  
;; py0   =  767 ; 
;; cx0   = -2 ; 
;; cy0   = -1.5
;; delta = 1/256 ;  delta =  fract_width/ pixel_width = ( 1.5- (-1.5 ) ) / 768 = 3/768 = 1/256

;; Calculation procedure: 
;; BEGIN :
;; cy = cy0 ; ;; 
;; for ( py = py0 ; py >= 0 ; py-- )  // from bottom to top 
;; {
;;    cx = cx0 ; 
;;    for ( px = px0 ; px < (width + px0 ) ; px ++ ) // from left to right
;;    {
;;       if ( cal_fract( cx, cy ) ) 
;;       {
;;          result <- 1 ; 
;; 
;;       } else {
;;          result <- 0 ;
;;       }
;; 
;;       if ( result has 4bits ) 
;;       {
;;          foreach ( result[i] ) 
;;          {
;;             reg  <- resilt[i] 
;;             addr <- ( px, py ) 
;;          }
;; 
;;          result = 0 ; 
;;       }
;;       
;;       cx += delta ; 
;; 
;;    }
;; 
;;    cy += delta  ; 
;; }
;; END

;; Remark :
;; Consider that hardware DDR2 mgr and MIG write burst size is 4 ,that is, 4 16-bit data will be written into DDR2 in one burst.
;; To simplify RTL design ( for DM of MIG ), write 4 pixel value in one burst. Therefor, firmware code will get 4 results and then 
;, execute the DDR write 

;;============================================================================
;; Ports and related constants.
;;============================================================================

CONSTANT pt_disp_cs       , 00    ; port disp_cs
CONSTANT pt_cw_x_orig     , 01    ; port cw_x_orig
CONSTANT pt_cw_y_orig     , 02    ; port cw_y_orig
CONSTANT pt_cw_x_size     , 03    ; port cw_x_size
CONSTANT pt_cw_y_size     , 04    ; port cw_y_size
CONSTANT pt_cb_addr_orig_l , 05   ; port cb_addr_orig_l 
CONSTANT pt_cb_addr_orig_h , 06   ; port cb_addr_orig_h 
CONSTANT pt_char_rgl      , 07    ; port char_rgl
CONSTANT pt_graph_rgl     , 08    ; port graph_rgl
CONSTANT pt_cw_row        , 09    ; port cw_row
CONSTANT pt_cw_col        , 0a    ; port cw_col
CONSTANT pt_cb_wr_data    , 0b    ; port cb_wr_data

;;---------------- ddr2 mgr registers ----------------------
CONSTANT reg_ddr2_status_ctrl  , 10    ; port 
CONSTANT reg_ddr2_data0_7_0    , 11    ; port 
CONSTANT reg_ddr2_data0_15_8   , 12    ; port 
CONSTANT reg_ddr2_data0_23_16  , 13    ; port 
CONSTANT reg_ddr2_data0_31_24  , 14    ; port 
CONSTANT reg_ddr2_data1_7_0    , 15    ; port 
CONSTANT reg_ddr2_data1_15_8   , 16    ; port 
CONSTANT reg_ddr2_data1_23_16  , 17    ; port 
CONSTANT reg_ddr2_data1_31_24  , 18    ; port 
CONSTANT reg_ddr2_addr_7_0     , 19    ; port 
CONSTANT reg_ddr2_addr_15_8    , 1a    ; port 
CONSTANT reg_ddr2_addr_23_16   , 1b    ; port 

CONSTANT active_ddr2_write     , 01    ; set auto in 
CONSTANT pic_fg_red_green      , 00    ; set auto in 
CONSTANT pic_fg_blue_bg        , F1    ; set auto in 


;;---------------- frac unit registers ----------------------
CONSTANT REG_FRAC_CTRL_STATUS        ,  20 ; port
CONSTANT REG_FRAC_CX_7_0_ADDR        ,  21 ; port
CONSTANT REG_FRAC_CX_15_8_ADDR       ,  22 ; port
CONSTANT REG_FRAC_CX_23_16_ADDR      ,  23 ; port
CONSTANT REG_FRAC_CX_31_24_ADDR      ,  24 ; port
CONSTANT REG_FRAC_CY_7_0_ADDR        ,  25 ; port
CONSTANT REG_FRAC_CY_15_8_ADDR       ,  26 ; port
CONSTANT REG_FRAC_CY_23_16_ADDR      ,  27 ; port
CONSTANT REG_FRAC_CY_31_24_ADDR      ,  28 ; port
CONSTANT REG_FRAC_MAX_ITER_LOW_ADDR  ,  29 ; port
CONSTANT REG_FRAC_MAX_ITER_HIGH_ADDR ,  2a ; port
CONSTANT REG_FRAC_PY_7_0_ADDR        ,  2b ; port
CONSTANT REG_FRAC_PY_15_8_ADDR       ,  2c ; port
CONSTANT REG_FRAC_PX_7_0_ADDR        ,  2d ; port
CONSTANT REG_FRAC_PX_15_8_ADDR       ,  2e ; port

CONSTANT start_frac_calc             ,  01 
CONSTANT frac_busy                   ,  01 
CONSTANT frac_found                  ,  02
CONSTANT color_red_green            , 00    ; set auto in 
CONSTANT color_blue_bg              , F1    ; set auto in 
CONSTANT frac_fg_high               , 00    
CONSTANT frac_fg_low                , F1    
CONSTANT frac_bg_high               , 00    
CONSTANT frac_bg_low                , 01    

CONSTANT set_auto_inc     , 01    ; set auto in 

;;---------------- mouse unit registers ----------------------
CONSTANT REG_MOUSE_CTRL_STATUS_ADDR  ,  30 ; port
CONSTANT REG_CURSOR_COLOR_ADDR       ,  34 ;
CONSTANT REG_CURSOR_X_LOW_ADDR       ,  35 ;
CONSTANT REG_CURSOR_X_HIGH_ADDR      ,  36 ;
CONSTANT REG_CURSOR_Y_LOW_ADDR       ,  37 ;
CONSTANT REG_CURSOR_Y_HIGH_ADDR      ,  38 ;
CONSTANT REG_SEL_X_LEFT_LOW_ADDR     ,  39 ; 
CONSTANT REG_SEL_X_LEFT_HIGH_ADDR    ,  3A ;
CONSTANT REG_SEL_Y_BOT_LOW_ADDR      ,  3B ;
CONSTANT REG_SEL_Y_BOT_HIGH_ADDR     ,  3C ; 
CONSTANT REG_SEL_HALF_LENGTH_LOW_ADDR     ,  3E ;
CONSTANT REG_SEL_HALF_LENGTH_HIGH_ADDR    ,  3F ;

CONSTANT mouse_ctrl_status_zoom_bit    ,  02
CONSTANT mouse_ctrl_status_restore_bit ,  04
CONSTANT mouse_ctrl_status_click_bit   ,  08
;;---------------- alu unit registers ----------------------

CONSTANT REG_ALU_CTRL_STATUS_ADDR   , 40
CONSTANT REG_ALU_A_0_ADDR           , 41
CONSTANT REG_ALU_A_1_ADDR           , 42
CONSTANT REG_ALU_A_2_ADDR           , 43
CONSTANT REG_ALU_A_3_ADDR           , 44
CONSTANT REG_ALU_B_0_ADDR           , 45
CONSTANT REG_ALU_B_1_ADDR           , 46
CONSTANT REG_ALU_B_2_ADDR           , 47
CONSTANT REG_ALU_B_3_ADDR           , 48
CONSTANT REG_ALU_Q_0_ADDR           , 41
CONSTANT REG_ALU_Q_1_ADDR           , 42
CONSTANT REG_ALU_Q_2_ADDR           , 43
CONSTANT REG_ALU_Q_3_ADDR           , 44
CONSTANT REG_ALU_R_0_ADDR           , 45
CONSTANT REG_ALU_R_1_ADDR           , 46
CONSTANT REG_ALU_R_2_ADDR           , 47
CONSTANT REG_ALU_R_3_ADDR           , 48

CONSTANT alu_go_bit                 , 03
CONSTANT alu_busy_bit               , 01
CONSTANT alu_en_bit                 , 02
CONSTANT alu_int_mask_bit           , 04
CONSTANT alu_clr_r_bit              , 08
CONSTANT alu_func_bit               , F0 
CONSTANT alu_div_op_val             , 00 
CONSTANT alu_mul_op_val             , 10 
;;---------------- uart unit registers ----------------------
CONSTANT REG_UART_STATUS_ADDR       , 50
CONSTANT REG_UART_CONTROL_ADDR      , 51
CONSTANT REG_UART_WRITE_FIFO_ADDR   , 52
CONSTANT REG_UART_READ_FIFO_ADDR    , 53

CONSTANT uart_rx_fifo_ready_bit     , 01  
CONSTANT uart_rx_fifo_overrun_bit   , 02  
CONSTANT uart_tx_fifo_ready_bit     , 04  
CONSTANT uart_tx_fifo_overrun_bit   , 08  

;;---------------- CPU unit registers ----------------------

CONSTANT REG_CPU_STATUS_ADDR        , 60
CONSTANT REG_CPU_CONTROL_ADDR       , 61
CONSTANT REG_CPU_INST_LOW_ADDR      , 62
CONSTANT REG_CPU_INST_HIGH_ADDR     , 63
CONSTANT REG_CPU_INST_PA_ADDR       , 64
CONSTANT REG_CPU_ADDR_LOW_ADDR      , 65
CONSTANT REG_CPU_ADDR_HIGH_ADDR     , 66

CONSTANT uart_intr_bit              , 01
CONSTANT mouse_intr_bit             , 02
CONSTANT alu_intr_bit               , 04

;;============================================================================
;; Time constants.
;;============================================================================
CONSTANT delay_1us_const  , 10    ; delay 1 us value


;;============================================================================
;; Fractal calculation constants.
;;============================================================================
CONSTANT PX0_0   ,  0   ;  low  byte of  pixel_x origin 
CONSTANT PX0_1   ,  0   ;  high byte of  pixel_x origin 
;; 0x2FF = 767 = ( 767 ---> 0 == 768 ) 
CONSTANT PY0_0   ,  FF  ;  low  byte of  pixel_y origin 
CONSTANT PY0_1   ,  02  ;  high byte of  pixel_y origin 

;; cx0 = -2 ( 0xe0_00_00_00 ) 
CONSTANT CX0_0 ,  00  ;  LSB of fractal x origin 
CONSTANT CX0_1 ,  00  ;  2nd of fractal x origin 
CONSTANT CX0_2 ,  00  ;  3nd of fractal x origin 
CONSTANT CX0_3 ,  e0  ;  MSB of fractal x origin 

;; cy0 = -1.5 ( 0xe8_00_00_00 ) 
CONSTANT CY0_0 ,  00  ;  LSB of fractal y origin 
CONSTANT CY0_1 ,  00  ;  2nd of fractal y origin 
CONSTANT CY0_2 ,  00  ;  3nd of fractal y origin 
CONSTANT CY0_3 ,  e8  ;  MSB of fractal y origin 

;; delta = [ 1 - ( -2 ) ] / 768 = 1/256 = 0x00_10_00_00  
CONSTANT DELTA_0, 00  ; 
CONSTANT DELTA_1, 00  ; 
CONSTANT DELTA_2, 10  ; 
CONSTANT DELTA_3, 00  ; 

;; interation number = 32 
;;CONSTANT ITER_0,  20  ; 
CONSTANT ITER_0,  40  ; 
CONSTANT ITER_1,  00  ; 

;;============================================================================
;; INTERNAL DATA RAM ( 0 - 3F ) 
;;============================================================================
;; memory location of Pixel x and y 
CONSTANT PX0_MEM    , 00  ; 
CONSTANT PX1_MEM    , 01  ; 
CONSTANT PY0_MEM    , 02  ; 
CONSTANT PY1_MEM    , 03  ; 

;; memory loc  ation of delta 
CONSTANT DELTA0_MEM , 04  ; 
CONSTANT DELTA1_MEM , 05  ; 
CONSTANT DELTA2_MEM , 06  ; 
CONSTANT DELTA3_MEM , 07  ; 

;; memory location of cx0 
CONSTANT CX0_MEM    , 08  ; 
CONSTANT CX1_MEM    , 09  ; 
CONSTANT CX2_MEM    , 0a  ; 
CONSTANT CX3_MEM    , 0b  ; 

;; memory location of cy0 
CONSTANT CY0_MEM    , 0c  ; 
CONSTANT CY1_MEM    , 0d  ; 
CONSTANT CY2_MEM    , 0e  ; 
CONSTANT CY3_MEM    , 0f  ; 
;;============================================================================
;; NAMEREG
;;============================================================================

namereg  s7,   result 

namereg  s8,   cx0    ; 1st byte 
namereg  s9,   cx1    ; 
namereg  sA,   cx2    ; 
namereg  sB,   cx3    ; 

namereg  sC,   cy0    ; 1st byte 
namereg  sD,   cy1    ; 
namereg  sE,   cy2    ; 
namereg  sF,   cy3    ; 
namereg  s6,   SP    ; 

;;============================================================================
;; M4 definition 
;;============================================================================
define(`PB3',`TRUE')
include(picoblaze.m4)

;;Define a macro in term of macro "use_bacwrite" with changes:
;;  1) keep full 0s ahead of nonzero digital.   
;;  2) Use "ascii_0" instead of "0".   
define(`use_fullbcdwrite', `; PRAGMA function $1 [$2, $3] begin
            $1: ; Write BCD array in memory as ASCII digits to port $4
              vars(`$2 is _src', `$3 is _count')
              push(_src, _count)
              add _count, _src
              sub _count, 01
              dowhile(`_src <= _count', `
                fetch _tempreg, (_src)
                add _tempreg, ascii_0 
                output _tempreg, $4
                add _src, 01')
              pop(_src, _count)
              return
              ; PRAGMA function end
              popvars')

use_strings(s0,,,tx_to_uart)

;;============================================================================
;; Start up routine goes here.
;;
;; Register usage convention is:
;; * s0, s1, s2, s3, s4, and s5 are are for general
;;   use in the main program loop.
;; * s7 is reserved for multiboot select variable.
;; * s8 is reserved for display state variable.
;; * s6, s9, sA, sB, sC, sD, sE are for general use
;;   in the interrupt service routine.
;; * sF is reserved for the control state variable.
;;============================================================================

;;      cold_start: LOAD     s0, set_auto_inc 
      cold_start: LOAD     s0, 3 
                  OUTPUT   s0, pt_disp_cs  
                  use_stack(SP, 0x3F) ; Start stack at end of 64-byte scratchpad
                  LOAD     s0, 08        
                  OUTPUT   s0, pt_cw_row
                  LOAD     s0, 10                       
                  OUTPUT   s0, pt_cw_col
                  LOAD     s0, ascii_6 
                  OUTPUT   s0, pt_cb_wr_data
                  LOAD     s0, ascii_4 
                  OUTPUT   s0, pt_cb_wr_data

                  CALL     print_welcome_msg 
                  CALL     print_prompt
;;============================================================================
;; Main program loop; for the most part, this continuously updates the LCD.
;; Everything else is done in the interrupt service routine.
;;============================================================================

         main:      CALL     set_cy_orig
                    CALL     set_cx_orig 
                    CALL     init_delta
                    CALL     task_frac_calc
         finish:    CALL     delay_20ms
                    LOAD     s0, 03
                    OUTPUT   s0, pt_disp_cs  
                    ENABLE INTERRUPT                   ; enable interrupt and allow mouse selection takes effect to zoom in fractal image.  
                    CALL     enable_mouse
         end_loop:  JUMP     end_loop                   ; 




;;============================================================================
;;
;;    Tasks group for displaying menu and parameter on right screen  
;;
;;============================================================================

use_int2bcd(int2bcd, 6, s0, s1, s2, s3, s4, s5)
use_int2bcd(int2bcd10, 10, s0, s1, s2, s3, s4, s5)
use_fullbcdwrite(fullbcdwrite, s0, s1, pt_cb_wr_data)
use_bcdwrite(bcdwrite, s0, s1, pt_cb_wr_data)

;;============================================================================
;; Function      : task_dispaly_cx 
;; Description   : convert cx from float format to BCD ASCII format. Then display on the screen. 
;; Input         : none
;; Output        : non
;; Temp register : s0, s1, s2, s3   
;;============================================================================
            
       task_display_cx :                       
                    LOAD     s0,    05        
                    OUTPUT   s0,    pt_cw_row
                    LOAD     s0,    10 
                    OUTPUT   s0,    pt_cw_col
                   
                    FETCH    s0,    CX0_MEM     
                    FETCH    s1,    CX1_MEM     
                    FETCH    s2,    CX2_MEM     
                    FETCH    s3,    CX3_MEM     
                    CALL     fraction2bcd
                    RETURN 

;;============================================================================
;; Function      : task_dispaly_cy 
;; Description   : convert cy from float format to BCD ASCII format. Then display on the screen. 
;; Input         : none
;; Output        : non
;; Temp register : s0, s1, s2, s3   
;;============================================================================

       task_dispaly_cy :                       
                    LOAD     s0,    06          
                    OUTPUT   s0,    pt_cw_row
                    LOAD     s0,    10 
                    OUTPUT   s0,    pt_cw_col
                   
                    FETCH    s0,    CY0_MEM     
                    FETCH    s1,    CY1_MEM     
                    FETCH    s2,    CY2_MEM     
                    FETCH    s3,    CY3_MEM     
                    CALL     fraction2bcd
                    RETURN 

;;============================================================================
;; Function      : task_dispaly_delta 
;; Description   : convert delta from float format to BCD ASCII format. Then display on the screen. 
;; Input         : none
;; Output        : non
;; Temp register : s0, s1, s2, s3   
;;============================================================================

       task_dispaly_delta :                       
                    LOAD     s0,    07          
                    OUTPUT   s0,    pt_cw_row
                    LOAD     s0,    10 
                    OUTPUT   s0,    pt_cw_col
                    LOAD     s0,    ascii_0 
                    OUTPUT   s0,    pt_cb_wr_data
                    LOAD     s0,    ascii_PERIOD 
                    OUTPUT   s0,    pt_cb_wr_data
                    LOAD     s0,    ascii_0 
                    OUTPUT   s0,    pt_cb_wr_data
                    OUTPUT   s0,    pt_cb_wr_data
                   
                    FETCH      s2,  DELTA2_MEM 

                    LOAD     s3,    00 
                    OUTPUT   s2,    REG_ALU_A_0_ADDR
                    OUTPUT   s3,    REG_ALU_A_1_ADDR
                    OUTPUT   s3,    REG_ALU_A_2_ADDR
                    OUTPUT   s3,    REG_ALU_A_3_ADDR

                    LOAD     s0,    51 
                    OUTPUT   s0,    REG_ALU_B_0_ADDR
                    LOAD     s0,    4A
                    OUTPUT   s0,    REG_ALU_B_1_ADDR
                    LOAD     s0,    8D 
                    OUTPUT   s0,    REG_ALU_B_2_ADDR
                    LOAD     s0,    0E 
                    OUTPUT   s0,    REG_ALU_B_3_ADDR

                    LOAD     s1,   alu_mul_op_val 
                    CALL     task_alu_exec

                    INPUT    s2,  REG_ALU_Q_0_ADDR            
                    INPUT    s3,  REG_ALU_Q_1_ADDR            
                    INPUT    s4,  REG_ALU_Q_2_ADDR            
                    INPUT    s5,  REG_ALU_Q_3_ADDR            

                    push(s2,s3,s4,s5)
                    LOAD     s0,    20
                    LOAD     s1,    04
                    CALL     int2bcd10

                    LOAD     s0,    20
                    LOAD     s1,    04
                    CALL     fullbcdwrite
   
                    RETURN 

;;============================================================================
;; Function      : fraction2bcd 
;; Description   : convert 32'hX.XXXXXXX float format to BCD ASCII format. Then display on the screen. 
;; Input         : none
;; Output        : non
;; Temp register : s0, s1, s2, s3, s4   
;;============================================================================

      fraction2bcd: TEST     s3,    80 
                    JUMP     Z,     exponent 
                    XOR      s0,    FF
                    XOR      s1,    FF
                    XOR      s2,    FF
                    XOR      s3,    FF
                    ADD      s0,    01
                    ADDCY    s1,    00 
                    ADDCY    s2,    00 
                    ADDCY    s3,    00 
                    LOAD     s4,    ascii_MINUS 
                    OUTPUT   s4,    pt_cb_wr_data
      exponent:     LOAD     s4,    s3
                    SR0      s4           ;; Right shift 4 bit and pad 0 on MSB
                    SR0      s4
                    SR0      s4
                    SR0      s4
                    ADD      s4,    30
                    OUTPUT   s4,    pt_cb_wr_data
                    LOAD     s4,    ascii_PERIOD 
                    OUTPUT   s4,    pt_cb_wr_data
      fraction:     ;;         .A3_A2_A1_A0  B7_B6 
                    ;;          A3_A2,  A1_A0_B7_B6
                    AND      s3,    0F   ;; Low 4bit for great fraction portion 
                    SL0      s2          ;; Left shift 2 bit and 
                    SLA      s3 
                    SL0      s2
                    SLA      s3 
      display_bcd:             
                    LOAD     s2,    00 
                    OUTPUT   s3,    REG_ALU_A_0_ADDR
                    OUTPUT   s2,    REG_ALU_A_1_ADDR
                    OUTPUT   s2,    REG_ALU_A_2_ADDR
                    OUTPUT   s2,    REG_ALU_A_3_ADDR

                    ;; Load  125 * 125 = 16'd15625 = 16'h3D_09 
                    LOAD     s0,    09
                    LOAD     s1,    3D
                    OUTPUT   s0,    REG_ALU_B_0_ADDR
                    OUTPUT   s1,    REG_ALU_B_1_ADDR
                    OUTPUT   s2,    REG_ALU_B_2_ADDR
                    OUTPUT   s2,    REG_ALU_B_3_ADDR

                    ;; A * 125 * 125 = 0.QQQQQQ   
                    LOAD     s1,   alu_mul_op_val 
                    CALL     task_alu_exec

                    ;; result  = 24'hXX_XX_XX
                    INPUT    s2,  REG_ALU_Q_0_ADDR            
                    INPUT    s3,  REG_ALU_Q_1_ADDR            
                    INPUT    s4,  REG_ALU_Q_2_ADDR            
                    
                    LOAD     s0,    20
                    LOAD     s1,    03
                    push(s2,s3,s4)
                    CALL     int2bcd

                    LOAD     s0,    20
                    LOAD     s1,    06
                    CALL     fullbcdwrite
                    RETURN
                  
   

;;============================================================================
;; Function name :  task_frac_calc 
;; Description   :  
;;============================================================================

         task_frac_calc:           
                    CALL     init_iter
                    CALL     init_cy
                    CALL     clear_result
                    CALL     init_py_orig  ; for ( py = py0 ; 
         loop_py_body:
                    CALL    set_py_reg  
                    CALL    init_cx_orig   ;       cx = cx0     
         loop_px_init:
                    CALL    init_px_orig   ;       for ( px = px0;
         loop_px_body:
                    CALL    set_px_reg  
                    CALL    start_calc  
         update_cx_advance:
                    CALL    inc_cx                       ;cx += delta ;  
         wait_calc_done:                                 ;wait for calc done 
                    INPUT   s0,  REG_FRAC_CTRL_STATUS
                    TEST    s0,  frac_busy 
                    JUMP    NZ,  wait_calc_done
;;   
;;         ---------------------------------
;;         | 0 | 0 | 0 | 1 | x | x | x | x | <-- R0  ( 1 : found ; 0: No found )
;;         ---------------------------------
;;
;;         ---------------------------------
;;         | 0 | 0 | 1 | x | x | x | x | R0| <-- R1 
;;         ---------------------------------
;;                   | |
;;                   V V
;; ---     ---------------------------------
;; |1| <-- | x | x | x | x | R0| R1| R2| R3|  
;; ---     ---------------------------------
         
         store_result:
                    INPUT   s0,  REG_FRAC_CTRL_STATUS    
                    TEST    s0,  frac_found 
                    JUMP    z,   frac_no_found         ;  if ( found ) {
                    SL1     result                     ;     result <-1 ; 
;;To accelerate sim, only run frac engine once and set result for all 4 points                     
                    JUMP    check_result_full          ;  } else { 
         frac_no_found: 
                    SL0     result                     ;     result <- 0 
         check_result_full:                            ;  }
                    JUMP    NC,  continue_calc         ;          if ( result has got 4 results )  go to "px++" of px loop ( cx+=delta has been done before )  
                    CALL    write_to_mem  
                    CALL    clear_result  
         continue_calc: 
                    CALL    inc_px                     ;  px++;    
                    CALL    check_px                   ;  check px >= width + px0 ; carry = 1 if  ">=" else carry = 0
                    JUMP    NC,   outside_of_px_loop   ;  exit px loop if px >= width + px0     
                    JUMP    loop_px_body
         outside_of_px_loop:
                    CALL    inc_cy                     ;  cy += delat
                    CALL    dec_py                     ;  py++      
                    CALL    check_py                   ;  check py == -1 ; 
                    JUMP    C,   outside_of_py_loop    ;  exit px loop if px >= width + px0     

                    JUMP    loop_py_body
         outside_of_py_loop:
                    RETURN


;;============================================================================
;; Delay routines.  These use s0 through s3 to implement a counter.  The
;; larger the delay, the more registers consumed.
;;============================================================================

       delay_1us: LOAD s0, delay_1us_const
        wait_1us: SUB s0, ONE
                  JUMP NZ, wait_1us
                  RETURN
      delay_40us: LOAD s1, 28                         ; 40 x 1us = 40us
       wait_40us: CALL delay_1us
                  SUB s1, ONE
                  JUMP NZ, wait_40us
                  RETURN
       delay_1ms: LOAD s2, 19                         ; 25 x 40us = 1ms
        wait_1ms: CALL delay_40us
                  SUB s2, ONE
                  JUMP NZ, wait_1ms
                  RETURN
      delay_20ms: LOAD s3, 14                         ; 20 x 1ms = 20ms
       wait_20ms: CALL delay_1ms
                  SUB s3, ONE
                  JUMP NZ, wait_20ms
                  RETURN
      delay_1s: LOAD s4, 40                         ; 64 x 20ms = 1.208s 
       wait_1s: CALL delay_20ms
                  SUB s4, ONE
                  JUMP NZ, wait_1s
                  RETURN
      write_to_mem:
                  ; Set btyes for 4 words of data. 

                  CALL     set_frac_fg_bg_color
                  OUTPUT   s0,  reg_ddr2_data0_7_0
                  OUTPUT   s1,  reg_ddr2_data0_15_8
                  CALL     set_frac_fg_bg_color
                  OUTPUT   s0,  reg_ddr2_data0_23_16
                  OUTPUT   s1,  reg_ddr2_data0_31_24
                  CALL     set_frac_fg_bg_color
                  OUTPUT   s0,  reg_ddr2_data1_7_0
                  OUTPUT   s1,  reg_ddr2_data1_15_8
                  CALL     set_frac_fg_bg_color
                  OUTPUT   s0,  reg_ddr2_data1_23_16
                  OUTPUT   s1,  reg_ddr2_data1_31_24

                  ; Set addr 
                  ;-------------------------------------- 
                  ;| py1, py0   |   px1,  px0           | 
                  ;--------------------------------------
                  ;23         10 9                     1

                  ; addr[7:0] = { px0[6:0] , 1'b0 } 
                  FETCH    s0,   PX0_MEM
                  AND      s0,   FC   ;; set 0 to 2LSB to make address 4-words alignment.   
                  SL0      s0,        ;; px0 << 1 
                  OUTPUT   s0,   reg_ddr2_addr_7_0
      
                  ; addr[15:8] = { py0[4:0], px1[2:0] } 
                  FETCH    s1,   PX1_MEM
                  SLA      s1
                  AND      s1,   07
                  FETCH    s2,   PY0_MEM
                  SL0      s2
                  SL0      s2
                  SL0      s2
                  OR       s1,   s2
                  OUTPUT   s1,   reg_ddr2_addr_15_8

                  ; addr[23:16] = { py1[4:0], py0[7:5] } 
                  FETCH    s2,   PY0_MEM
                  SR0      s2, 
                  SR0      s2, 
                  SR0      s2, 
                  SR0      s2, 
                  SR0      s2, 
                  FETCH    s1,   PY1_MEM
                  SL0      s1
                  SL0      s1
                  SL0      s1
                  OR       s1,   s2
                  OUTPUT   s1,   reg_ddr2_addr_23_16

                  ; initial write command 

                  LOAD     s0,  active_ddr2_write
                  OUTPUT   s0,  reg_ddr2_status_ctrl 
                  RETURN

set_frac_fg_bg_color:    ;;  According to fractal result, set color to fg ( front graphic ) or bg ( background graphic ) 
                  SR0      result
                  JUMP     NC,  draw_bg  
                  LOAD     s0,  frac_fg_low
                  LOAD     s1,  frac_fg_high
                  RETURN
      draw_bg:    LOAD     s0,  frac_bg_low
                  LOAD     s1,  frac_bg_high
                  RETURN 
                           
      init_iter: LOAD     s0, ITER_0  ; reg  <- max iteration number   
                 OUTPUT   s0, REG_FRAC_MAX_ITER_LOW_ADDR
                 LOAD     s0, ITER_1 
                 OUTPUT   s0, REG_FRAC_MAX_ITER_HIGH_ADDR
                 RETURN 

     init_delta: LOAD    s0,  DELTA_0   
                 STORE   s0,  DELTA0_MEM
                 LOAD    s0,  DELTA_1
                 STORE   s0,  DELTA1_MEM
                 LOAD    s0,  DELTA_2
                 STORE   s0,  DELTA2_MEM
                 LOAD    s0,  DELTA_3
                 STORE   s0,  DELTA3_MEM
                 CALL    task_dispaly_delta
                 RETURN

  set_cy_orig:   LOAD    cy0, CY0_0   ; set origin cy0 to internal mem 
                 LOAD    cy1, CY0_1  
                 LOAD    cy2, CY0_2  
                 LOAD    cy3, CY0_3  
                 STORE   cy0, CY0_MEM
                 STORE   cy1, CY1_MEM
                 STORE   cy2, CY2_MEM
                 STORE   cy3, CY3_MEM
                 CALL    task_dispaly_cy
                 RETURN 

      init_cy:   FETCH   cy0, CY0_MEM   ; cy = cy0 
                 FETCH   cy1, CY1_MEM  
                 FETCH   cy2, CY2_MEM  
                 FETCH   cy3, CY3_MEM  
                 RETURN 

   clear_result: ;; result = 0001_0000
                 LOAD      result,  00  
                 SR1       result 
                 SR0       result
                 SR0       result
                 SR0       result
                 RETURN   

   init_py_orig: LOAD      s0, PY0_0
                 STORE     s0, PY0_MEM
                 LOAD      s0, PY0_1
                 STORE     s0, PY1_MEM
                 RETURN

   set_cx_orig:  LOAD      cx0, CX0_0   ;       cx = cx0
                 LOAD      cx1, CX0_1 
                 LOAD      cx2, CX0_2 
                 LOAD      cx3, CX0_3 
                 STORE     cx0, CX0_MEM      
                 STORE     cx1, CX1_MEM      
                 STORE     cx2, CX2_MEM      
                 STORE     cx3, CX3_MEM      
                 CALL      task_display_cx 
                 ; Added
                 RETURN

   init_cx_orig: FETCH     cx0, CX0_MEM  ;       cx = cx0
                 FETCH     cx1, CX1_MEM 
                 FETCH     cx2, CX2_MEM 
                 FETCH     cx3, CX3_MEM 
                 ; Added
                 RETURN


   init_px_orig: LOAD      s0, PX0_0
                 STORE     s0, PX0_MEM
                 LOAD      s0, PX0_1
                 STORE     s0, PX1_MEM
                 RETURN
;;============================================================================
;; Function name :  start_calc
;; Description   :  
;;    *) store "cx" values stored in register to 4 fractal engine regiters
;;    *) store "cy" values stored in register to 4 fractal engine regiters
;;    *) initiate fractal engine by setting bit of fractal strl_status register
;;============================================================================
   start_calc:   OUTPUT    cx0, REG_FRAC_CX_7_0_ADDR     ; reg <- cx  
                 OUTPUT    cx1, REG_FRAC_CX_15_8_ADDR
                 OUTPUT    cx2, REG_FRAC_CX_23_16_ADDR
                 OUTPUT    cx3, REG_FRAC_CX_31_24_ADDR
                 OUTPUT    cy0, REG_FRAC_CY_7_0_ADDR     ; reg <- cy  
                 OUTPUT    cy1, REG_FRAC_CY_15_8_ADDR
                 OUTPUT    cy2, REG_FRAC_CY_23_16_ADDR
                 OUTPUT    cy3, REG_FRAC_CY_31_24_ADDR
                 LOAD      s0,  start_frac_calc          ; start fractal calcualtion 
                 OUTPUT    s0,  REG_FRAC_CTRL_STATUS  
                 RETURN

   inc_cx:       FETCH     s0,   DELTA0_MEM   
                 ADD       cx0,  s0 
                 FETCH     s0,   DELTA1_MEM   
                 ADDCY     cx1,  s0 
                 FETCH     s0,   DELTA2_MEM   
                 ADDCY     cx2,  s0 
                 FETCH     s0,   DELTA3_MEM   
                 ADDCY     cx3,  s0 
                 RETURN   

   inc_cy:       FETCH     s0,   DELTA0_MEM   
                 ADD       cy0,  s0 
                 FETCH     s0,   DELTA1_MEM   
                 ADDCY     cy1,  s0 
                 FETCH     s0,   DELTA2_MEM   
                 ADDCY     cy2,  s0 
                 FETCH     s0,   DELTA3_MEM   
                 ADDCY     cy3,  s0 
                 RETURN   

   inc_px:       FETCH     s0,   PX0_MEM
                 FETCH     s1,   PX1_MEM
                 ADD       s0,   01
                 ADDCY     s1,   00
                 STORE     s0,   PX0_MEM
                 STORE     s1,   PX1_MEM
                 RETURN

   check_px:     SUB       s0,   00   ;; px - 0x300 < 0 
                 SUBCY     s1,   03
                 RETURN

   dec_py:       FETCH     s0,   PY0_MEM
                 FETCH     s1,   PY1_MEM
                 SUB       s0,   01
                 SUBCY     s1,   00
                 STORE     s0,   PY0_MEM
                 STORE     s1,   PY1_MEM
                 RETURN

   check_py:     RETURN

   set_py_reg:   FETCH     s0,   PY0_MEM
                 OUTPUT    s0,   REG_FRAC_PY_7_0_ADDR    
                 FETCH     s1,   PY1_MEM
                 OUTPUT    s1,   REG_FRAC_PY_15_8_ADDR    
                 RETURN

   set_px_reg:   FETCH     s0,   PX0_MEM
                 OUTPUT    s0,   REG_FRAC_PX_7_0_ADDR    
                 FETCH     s1,   PX1_MEM
                 OUTPUT    s1,   REG_FRAC_PX_15_8_ADDR    
                 RETURN

   enable_mouse: LOAD      s0,   01
                 OUTPUT    s0,   REG_MOUSE_CTRL_STATUS_ADDR  
                 RETURN
;;============================================================================
;; Subroutines related to UART Read and Write.
;;============================================================================
string(`print_welcome_msg', `Welcome !!\n')   
string(`print_prompt', `>')   
string(`print_uart_intr_msg', `Uart IRQ\n')
string(`print_alu_intr_msg', `ALU IQR\n')
string(`print_uart_cmd_msg', `Uart cmd:') 
string(`print_code_update_msg', `Enter update mode..\n#')
string(`print_code_remap_msg', `Done!\n')
string(`print_uart_cmd_err_msg', `Wrong cmd!\n>')
string(`print_intr_err_msg', `unknown IRQ\n')
string(`print_restart_msg', `Sys restart..\n')
;;============================================================================
;; Function name : tx_to_uart 
;; Description   : Send ascii byte to uart tx fifo by writting to register
;; Input Option  : s0 : ascii byte to send out
;  Return value  : none
;;============================================================================
tx_to_uart:     INPUT    s1, REG_UART_STATUS_ADDR     ; read UART status
                TEST     s1, uart_tx_fifo_ready_bit   ; check if tx fifo is not full
                JUMP     Z,  tx_to_uart               ; if tx fifo is NOT ready, sit and spin. 
                OUTPUT   s0, REG_UART_WRITE_FIFO_ADDR ; write data to tx FIFO
                RETURN

rx_from_uart:   INPUT    s1, REG_UART_STATUS_ADDR     ; read UART status
                TEST     s1, uart_rx_fifo_ready_bit   ; check if tx fifo is not full
                JUMP     Z,  rx_from_uart             ; if rx fifo is NOT ready, sit and spin. 
                INPUT    s0, REG_UART_READ_FIFO_ADDR 
                RETURN
;;============================================================================
;; Interrupt service routine; 
;; this is responsible for re-calculate fractal image based on mouse selection
;;============================================================================
interrupt_srv:  INPUT      s0,   REG_CPU_STATUS_ADDR
                test       s0,   uart_intr_bit  
                JUMP       NZ,   uart_intr_srv
                test       s0,   mouse_intr_bit  
                JUMP       NZ,   mouse_intr_srv
                test       s0,   alu_intr_bit  
                JUMP       NZ,   alu_intr_srv
                CALL       print_intr_err_msg
                RETURNI ENABLE

;;============================================================================
;; Function name :  uart_intr_srv
;; Description   :  uart receiving interrupt handler
;; Detailes:
;;    1) Checking if char is "p" or "P" indicating program updating
;;    2) Ready for codes
;;    3) Remap
;;============================================================================
uart_intr_srv:  CALL      print_uart_intr_msg 
                CALL      rx_from_uart
                LOAD      s4,   s0         
                CALL      print_uart_cmd_msg
                CALL      tx_to_uart
                COMPARE   s4,   ascii_p
                JUMP      Z,    code_update
                COMPARE   s4,   ascii_P
                JUMP      Z,    code_update
                CALL      print_uart_cmd_err_msg   
                CALL      exit_uart_intr_srv
  code_update:  CALL      print_code_update_msg         
                LOAD      s0,   0
                OUTPUT    s0,   REG_CPU_ADDR_LOW_ADDR    
                OUTPUT    s0,   REG_CPU_ADDR_HIGH_ADDR    
                LOAD      s0,   02
                OUTPUT    s0,   REG_CPU_CONTROL_ADDR

    test_begin: LOAD      s5,   00            
                LOAD      s3,   04
    fetch_code: CALL      rx_from_uart 
                OUTPUT    s0,   REG_CPU_INST_LOW_ADDR 
                CALL      rx_from_uart 
                OUTPUT    s0,   REG_CPU_INST_HIGH_ADDR 
                CALL      rx_from_uart 
                OUTPUT    s0,   REG_CPU_INST_PA_ADDR 
                SUB       s5,   ONE
                SUBCY     s3,   00
                COMPARE   s3,   00 
                JUMP      NZ,   fetch_code
                COMPARE   s5,   00
                JUMP      NZ,   fetch_code  
         remap: CALL      print_code_remap_msg 
                CALL      delay_1s 
                CALL      print_restart_msg 
                LOAD      s0,   01
                OUTPUT    s0,   REG_CPU_CONTROL_ADDR
 wast_time_loop:            JUMP      wast_time_loop 
 exit_uart_intr_srv:   
                ENABLE    INTERRUPT                   ; enable interrupt and allow mouse selection takes effect to zoom in fractal image.  

                RETURNI    ENABLE

;;============================================================================
;; Function name :  mouse_intr_srv
;; Description   :  mouse action interrupt handler
;; Detailes:
;;    1) Compute new delta
;;    2) Compute new origin of new fractal image 
;;    3) Draw new fractal image in term of new starting points and delta
;;============================================================================
mouse_intr_srv: INPUT      s0,  REG_MOUSE_CTRL_STATUS_ADDR
                test       s0,  mouse_ctrl_status_zoom_bit
                JUMP       NZ,  process_zoom
                test       s0,  mouse_ctrl_status_restore_bit
                JUMP       NZ,  process_restore 
                CALL       enable_mouse   ;  do nothing if other status 
                RETURNI ENABLE

process_restore:
                CALL       set_cy_orig
                CALL       set_cx_orig 
                CALL       init_delta
                CALL       task_frac_calc
                CALL       enable_mouse
                RETURNI ENABLE
                
process_zoom:   CALL       task_check_length_limit
                JUMP       Z, mouse_pre_back
                CALL       task_check_delat_limit
                JUMP       Z, mouse_pre_back  ; 0x00_00_00_XX will NOT be processed.   
                CALL       task_load_delta_to_alu
                CALL       task_calc_new_cx_based_mouse
                CALL       task_load_delta_to_alu
                CALL       task_calc_new_cy_based_mouse
                CALL       task_load_delta_to_alu
                CALL       task_calc_new_delta_based_mouse
                CALL       task_frac_calc
mouse_pre_back: CALL       enable_mouse
                RETURNI ENABLE


task_check_length_limit:
                INPUT      s0,   REG_SEL_HALF_LENGTH_HIGH_ADDR     
                COMPARE    s0,   0
                RETURN     NZ    
                INPUT      s0,   REG_SEL_HALF_LENGTH_LOW_ADDR     
                TEST       s0,   F8
                RETURN
         
task_check_delat_limit:
                FETCH      s0,  DELTA3_MEM 
                compare    s0,  0
                RETURN     NZ    
                FETCH      s0,  DELTA2_MEM 
                compare    s0,  0
                RETURN     NZ    
                FETCH      s0,  DELTA1_MEM 
                compare    s0,  0
                RETURN
                
                
task_calc_new_cx_based_mouse:
                CALL       task_load_mouse_x_point_to_alu
                LOAD       s1,   alu_mul_op_val 
                CALL       task_alu_exec
                CALL       task_update_cx 
                RETURN

task_calc_new_cy_based_mouse:
                CALL       task_load_mouse_y_point_to_alu
                LOAD       s1,   alu_mul_op_val 
                CALL       task_alu_exec
                CALL       task_update_cy 
                RETURN

task_calc_new_delta_based_mouse:
                CALL       task_load_mouse_length_to_alu
                LOAD       s1,   alu_mul_op_val 
                CALL       task_alu_exec
                CALL       task_update_delta  
                RETURN 


task_alu_exec :      
                LOAD       s0,   alu_en_bit
                OUTPUT     s0,   REG_ALU_CTRL_STATUS_ADDR   
                ADD        s1,   alu_go_bit
                OUTPUT     s1,   REG_ALU_CTRL_STATUS_ADDR   
                ;;Wait ALU operation done
                LOAD       s0,   0 
check_alu_busy_bit: 
                INPUT      s0,   REG_ALU_CTRL_STATUS_ADDR
                test       s0,   alu_busy_bit
                JUMP       NZ,   check_alu_busy_bit
                LOAD       s0,   0
                OUTPUT     s0,   REG_ALU_CTRL_STATUS_ADDR   
                RETURN       

task_load_mouse_x_point_to_alu:
                INPUT      s0,   REG_SEL_X_LEFT_LOW_ADDR                 
                OUTPUT     s0,   REG_ALU_B_0_ADDR
                INPUT      s0,   REG_SEL_X_LEFT_HIGH_ADDR    
                OUTPUT     s0,   REG_ALU_B_1_ADDR
                LOAD       s0,   00
                OUTPUT     s0,   REG_ALU_B_2_ADDR
                OUTPUT     s0,   REG_ALU_B_3_ADDR
                RETURN 

;; 767 =   0010_1111_1111
task_load_mouse_y_point_to_alu:
                INPUT      s0,   REG_SEL_Y_BOT_LOW_ADDR                 
                LOAD       s1,   FF
                SUB        s1,   s0
                OUTPUT     s1,   REG_ALU_B_0_ADDR

                INPUT      s0,   REG_SEL_Y_BOT_HIGH_ADDR    
                LOAD       s1,   02 
                SUBCY      s1,   s0
                OUTPUT     s1,   REG_ALU_B_1_ADDR

                LOAD       s0,   00
                OUTPUT     s0,   REG_ALU_B_2_ADDR
                OUTPUT     s0,   REG_ALU_B_3_ADDR
                RETURN 

task_load_mouse_length_to_alu:
                INPUT      s0,   REG_SEL_HALF_LENGTH_LOW_ADDR     
                SL0        s0
                OUTPUT     s0,   REG_ALU_B_0_ADDR

                INPUT      s0,   REG_SEL_HALF_LENGTH_HIGH_ADDR     
                SLA        s0
                OUTPUT     s0,   REG_ALU_B_1_ADDR

                LOAD       s0,   00
                OUTPUT     s0,   REG_ALU_B_2_ADDR
                OUTPUT     s0,   REG_ALU_B_3_ADDR

                RETURN 


task_load_delta_to_alu:
                FETCH      s0,  DELTA0_MEM 
                OUTPUT     s0,  REG_ALU_A_0_ADDR
                FETCH      s0,  DELTA1_MEM 
                OUTPUT     s0,  REG_ALU_A_1_ADDR
                FETCH      s0,  DELTA2_MEM 
                OUTPUT     s0,  REG_ALU_A_2_ADDR
                FETCH      s0,  DELTA3_MEM 
                OUTPUT     s0,  REG_ALU_A_3_ADDR
                RETURN     

task_update_cx:
                FETCH      cx0, CX0_MEM
                FETCH      cx1, CX1_MEM 
                FETCH      cx2, CX2_MEM 
                FETCH      cx3, CX3_MEM 
                INPUT      s0,  REG_ALU_Q_0_ADDR            
                ADD        cx0, s0 
                INPUT      s0,  REG_ALU_Q_1_ADDR            
                ADDCY      cx1, s0 
                INPUT      s0,  REG_ALU_Q_2_ADDR            
                ADDCY      cx2, s0 
                INPUT      s0,  REG_ALU_Q_3_ADDR            
                ADDCY      cx3, s0 
                STORE      cx0, CX0_MEM 
                STORE      cx1, CX1_MEM 
                STORE      cx2, CX2_MEM 
                STORE      cx3, CX3_MEM 
                CALL       task_display_cx 
                RETURN 

task_update_cy:
                FETCH      cy0, CY0_MEM
                FETCH      cy1, CY1_MEM 
                FETCH      cy2, CY2_MEM 
                FETCH      cy3, CY3_MEM 
                INPUT      s0,  REG_ALU_Q_0_ADDR            
                ADD        cy0, s0 
                INPUT      s0,  REG_ALU_Q_1_ADDR            
                ADDCY      cy1, s0 
                INPUT      s0,  REG_ALU_Q_2_ADDR            
                ADDCY      cy2, s0 
                INPUT      s0,  REG_ALU_Q_3_ADDR            
                ADDCY      cy3, s0 
                STORE      cy0, CY0_MEM 
                STORE      cy1, CY1_MEM 
                STORE      cy2, CY2_MEM 
                STORE      cy3, CY3_MEM 
                CALL       task_dispaly_cy
                RETURN 

task_update_delta:
                INPUT      s0,  REG_ALU_Q_0_ADDR            
                OUTPUT     s0,  REG_ALU_A_0_ADDR 
                INPUT      s0,  REG_ALU_Q_1_ADDR            
                OUTPUT     s0,  REG_ALU_A_1_ADDR 
                INPUT      s0,  REG_ALU_Q_2_ADDR            
                OUTPUT     s0,  REG_ALU_A_2_ADDR 
                INPUT      s0,  REG_ALU_Q_3_ADDR            
                OUTPUT     s0,  REG_ALU_A_3_ADDR 
;;768=0x0011_0000_0000
                LOAD       s0,  00
                OUTPUT     s0,  REG_ALU_B_0_ADDR
                OUTPUT     s0,  REG_ALU_B_2_ADDR
                OUTPUT     s0,  REG_ALU_B_3_ADDR
                LOAD       s0,  03
                OUTPUT     s0,  REG_ALU_B_1_ADDR

                LOAD       s1,   alu_div_op_val 
                CALL       task_alu_exec

                INPUT      s0,  REG_ALU_Q_0_ADDR            
                STORE      s0,  DELTA0_MEM
                INPUT      s0,  REG_ALU_Q_1_ADDR            
                STORE      s0,  DELTA1_MEM
                INPUT      s0,  REG_ALU_Q_2_ADDR            
                STORE      s0,  DELTA2_MEM
                INPUT      s0,  REG_ALU_Q_3_ADDR            
                STORE      s0,  DELTA3_MEM
                CALL       task_dispaly_delta
                RETURN 

;;============================================================================
;; Function name :  alu_intr_srv
;; Description   :  alu_operationinterrupt handler
;; Detailes:
;;    1) Compute new delta
;;    2) Compute new origin of new fractal image 
;;    3) Draw new fractal image in term of new starting points and delta
;;============================================================================
alu_intr_srv:   CALL       print_alu_intr_msg
                RETURNI ENABLE

;;============================================================================
;;             Diagnostic routines.  
;; All tasks related to debug and UART print 
;;============================================================================

   ;;============================================================================
   ;; Function name : byte2ascii 
   ;; Description   : Print byte to uart with high 4bit first out  
   ;; Input options : s0
   ;; internal regs : s2,
   ;;                 s1   -  tx_to_uart
   ;; output        : s0
   ;;============================================================================
   byte2ascii :     LOAD    s2,   s0
                    CALL    right_shfit_4  
                    CALL    hex2ascii
                    LOAD    s0,   s2 
                    CALL    hex2ascii
                    RETURN

   ;;============================================================================
   ;; Function name : right_shfit_4 
   ;; Description   : move high 4bits to low 4bits  
   ;; Input options : s0
   ;; output        : s0
   ;;============================================================================
   right_shfit_4:   SR0      s0
                    SR0      s0  
                    SR0      s0  
                    SR0      s0  
                    RETURN

   ;;============================================================================
   ;; Function name : hex2ascii
   ;; Description   : convert hex digital to ascii and then print to uart   
   ;; Input options : s0
   ;; output        : none 
   ;;============================================================================
   hex2ascii    :   AND      s0,    0F  
                    COMPARE  s0,    0A  
                    JUMP     C,     digital2ascii
                    ADD      s0,    37  
                    JUMP     print_ascii  
     digital2ascii: OR       s0,    30
     print_ascii:   CALL     tx_to_uart 
                    RETURN 

   ;;============================================================================
   ;; Function name : print_cr 
   ;; Description   : pint "CR" to uart   
   ;; Input options : none 
   ;; output        : none 
   ;;============================================================================

   print_cr     :   LOAD     s0,    0A 
                    CALL     tx_to_uart 
                    RETURN 



;;============================================================================
;; Interrupt service routine vector.
;;============================================================================
                 ADDRESS   3FF
                 JUMP      interrupt_srv 

;;============================================================================
;;    End of File 
;;============================================================================
