`ifndef  SCOREBOARD__SV
`define  SCOREBOARD__SV 
class  scoreboard ; 
   mouse_packet pkt_src[$] ; 
   mouse_packet pkt_dest[$] ; 
  
   function void write_expect ( mouse_packet pkt ) ; 
      pkt_src.push_back( pkt ) ;  
      `ifdef DEBUG
         $display("[DEBUG] Scoreboad: a port get 0x%08h", pkt.a) ; 
      `endif
   endfunction

   function void write_actual ( mouse_packet pkt ) ; 
      pkt_dest.push_back( pkt ) ;  
      `ifdef DEBUG
         $display("[DEBUG] Scoreboad b port get 0x%08h", pkt.a) ; 
      `endif
   endfunction

   function void perform_check() ; 
      int  total_test_num  ; 
      int  error_test_num ; 

      error_test_num = 0 ; 
      total_test_num =  pkt_src.size() ; 

      $display("[INFO] Scoreboard: Check Result ") ; 
      foreach ( pkt_src[i] ) begin 
         $write("<%1d> ", i) ; 
         if ( compare_real( pkt_src[i].new_cx, pkt_dest[i].new_cx ) && 
              compare_real( pkt_src[i].new_cy, pkt_dest[i].new_cy ) &&
              compare_real( pkt_src[i].new_delta,pkt_dest[i].new_delta ) ) begin 
            $display("Match") ; 
         end else begin
            $display("Mismatch !!!") ; 
            error_test_num++ ; 
         end   

         $display("------------------------------");
         $display("\t\tExpect\tActual"); 
         $display("\tcx:\t%1.10f\t%1.10f", pkt_src[i].new_cx, pkt_dest[i].new_cx); 
         $display("\tcy:\t%1.10f\t%1.10f", pkt_src[i].new_cy, pkt_dest[i].new_cy); 
         $display("\tdelta:\t%1.10f\t%1.10f", pkt_src[i].new_delta, pkt_dest[i].new_delta); 
         $display("");
      end


      $display("[INFO] Scoreboard: Summary ") ; 
      $display("\t Total Testcase   : %3d", total_test_num ) ; 
      $display("\t    Passed Test   : %3d", total_test_num - error_test_num ) ; 
      $display("\t    failed test   : %3d", error_test_num ) ; 
      pkt_src.delete();
      pkt_dest.delete();

   endfunction

   function int   compare_real( shortreal a, b, int prec = 4 ) ; 
      real  diff ; 
      real  diff_min ; 
      if ( a > b) diff  =  a - b; 
      else        diff  =  b - a; 

      if ( diff * ( 10 ** prec ) < 1 ) return 1 ; 
      else                          return 0 ; 
   endfunction 

endclass : scoreboard 

`endif 

