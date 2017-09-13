
class  scoreboard ; 
   uart_packet pkt_src[$] ; 
   uart_packet pkt_dest[$] ; 
  
   function void write_a ( uart_packet pkt ) ; 
      pkt_src.push_back( pkt ) ;  
      `ifdef DEBUG
         foreach ( pkt_src[i] ) begin 
            $display(  "pkt_sec[%3d] = 0x%2h", i, pkt_src[i].payload) ; 
         end

         $display("[Scoreboard] Scoreboad a port get 0x%2h", pkt.payload) ; 
      `endif
   endfunction

   function void write_b ( uart_packet pkt ) ; 
      pkt_dest.push_back( pkt ) ;  
      `ifdef DEBUG
         $display("[Scoreboard] Scoreboad b port get 0x%2h", pkt.payload) ; 
      `endif
   endfunction

   function void perform_check() ; 
      int  total_test_num  ; 
      int  error_test_num ; 

      error_test_num = 0 ; 
      total_test_num =  pkt_src.size() ; 

      $display("[Scoreboard] Check Result ") ; 
      foreach ( pkt_src[i] ) begin 
         $write("\t [%03d] 0x%2h --> 0x%2h",i, pkt_src[i].payload, pkt_dest[i].payload ) ;
         if ( pkt_src[i].payload == pkt_dest[i].payload ) begin 
            $write(" - Matach\n") ; 
         end else begin 
            error_test_num++ ; 
            $write(" - Mismatach !!!!\n") ; 
         end
      end
      $display("[Scoreboard] Summary ") ; 
      $display("\t Total Testcase   : %3d", total_test_num ) ; 
      $display("\t    Passed Test   : %3d", total_test_num - error_test_num ) ; 
      $display("\t    failed test   : %3d", error_test_num ) ; 
   endfunction

endclass : scoreboard 
