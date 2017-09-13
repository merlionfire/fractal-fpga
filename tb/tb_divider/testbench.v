`timescale 1ns / 100ps  
`default_nettype none 

module testbench () ; 

   logic clk, rst ; 
   logic ce;
   logic start;
   logic valid;


   parameter M =  32;
   parameter N =  32 ; 
   parameter RND_TEST_NUM  =  10 ; 

   logic [ M-1 : 0 ] a  ; 
   logic [ N-1 : 0 ] b  ;

   logic [M-1:0]     q;       // Quotient
   logic [N-1:0]     r;        // Rmd 

   //*******************************************************************//
   //     Class Declaration                                             // 
   //*******************************************************************//

   class  test_packet  ; 

      static   int   test_num  = 0 ; 
      static   int   err_num   = 0 ; 

      rand  bit [M-1:0]    dividend ; 
      rand  bit [N-1:0]    divisor;
      bit [M-1:0]  q_exp ; 
      bit [N-1:0]  r_exp ; 

      constraint divisor_c  { divisor > 0 ;  }  
      constraint divisor_great  { dividend > divisor ;  }  

      function void post_randomize(); 
         q_exp =  dividend / divisor ; 
         r_exp =  dividend % divisor ; 
      endfunction 

      function void compare( input logic [M-1:0] q, logic [N-1:0] r ) ; 
         bit error ; 
         error = 1'b0 ; 
         $write(" quotient = 0x%h, ", q ) ;  
         $write(" rmf = 0x%h : ", r ) ;  
         if ( q != q_exp ) begin 
            $write( "[ERROR] Expected quotient is 0x%4h, ", q_exp ) ; 
            error = 1'b1 ; 
         end 
         if ( r != r_exp ) begin 
            $display( "[ERROR] expected rmd is 0x%4h", r_exp ) ; 
            error = 1'b1 ; 
         end
         if ( error == 1'b0 ) begin 
            $display("Result is OK");
         end else begin 
            err_num++ ; 
            $display("") ; 
         end
         test_num++ ; 
      endfunction 

      task report () ; 
         $display( "*************  Divivder test report ***********") ; 
         $display("\tTotal test cases is\t:%d", test_num ) ; 
         $display("\t  Random test cases\t:%d", RND_TEST_NUM ) ; 
         $display("\t  Directed test cases\t:%d", ( test_num - RND_TEST_NUM ) )  ; 
         $display("\t\t Error occurs\t:%d", err_num ) ; 
         $display( "***********************************************") ; 

      endtask 

   endclass

   test_packet    test_pkt ; 

   //*******************************************************************//
   //     DUT Instatiation                                                  // 
   //*******************************************************************//

   divider  #( 
         .M(M),
         .N(N)
   ) divider_inst (
      .clk   ( clk   ), //i
      .rst   ( rst   ), //i
      .ce    ( ce    ), //i
      .start ( start ), //i
      .a     ( a     ), //i
      .b     ( b     ), //i
      .valid ( valid ), //o
      .q     ( q     ), //o
      .r     ( r     )  //o
   );



   //*******************************************************************//
   //     Clock                                                         // 
   //*******************************************************************//
 
   always #5ns clk = ~ clk ;  
 
 
   //*******************************************************************//
   //     Main test                                                     // 
   //*******************************************************************//
 
 
   initial begin 
      test_pkt = new() ; 
      clk      =  1'b0 ; 
      ce       =  1'b0 ; 
      start    =  1'b0 ; 
      rst      =  1'b1 ; 
      repeat (5) @( posedge clk )  ; 
      #2 rst      =  1'b0 ; 
      repeat (10) @( posedge clk )  ; 
      #2 ce       =  1'b1 ; 
      repeat (2) @( posedge clk )  ; 

      $display("Executing %d random testcases .........", RND_TEST_NUM ) ; 
      //execute_div( 16'h8000, 4'h4 ) ; 
      for ( int i = 0 ; i < RND_TEST_NUM ; i++ ) begin 
         $write("[%4d] ", i); 
         test_pkt.randomize() ; 
         execute_div( test_pkt ) ; 
      end 

      $display("Executing directed testcases ........." ) ; 
      test_pkt.randomize() with { dividend == '1 ;  } ; 
      execute_div( test_pkt ) ; 

      test_pkt.randomize() with { divisor == '1 ;  } ; 
      execute_div( test_pkt ) ; 
      repeat (2) @( posedge clk )  ; 
      test_pkt.report(); 
      $finish ;  
   end 



   //*******************************************************************//
   //     FSDB dumper                                                   // 
   //*******************************************************************//

   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
      repeat(250) @(posedge clk ) ; 
   end


   //*******************************************************************//
   //     Functions and tasks                                           // 
   //*******************************************************************//

   task execute_div( test_packet pkt ) ;  
      
      @( posedge clk )  ; 
      a  =  pkt.dividend ; 
      b  =  pkt.divisor ; 
      #2 start    =  1'b1;
      $write("a = 0x%4h, ", a ) ; 
      $write("b = 0x%h ==> ", b ) ; 
      @( posedge clk ) ; 
      #2 start    =  1'b0;
      while ( ~valid ) begin 
         //$display("  Calculating ......") ;  
         @( posedge clk ) ;  
      end

      pkt.compare( q, r )  ; 

   endtask 




endmodule 
