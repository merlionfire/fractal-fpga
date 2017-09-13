program automatic test;
import uvm_pkg::*; 
import test_pkg::*; 

   initial begin 
      uvm_resource_db#(virtual up_if )::set("cpu_if", "", tb_top.cpu_if) ; 
      uvm_resource_db#(virtual reset_if)::set("rst_if", "", tb_top.rst_if) ; 

      $timeformat(-9,1,"ns", 10 ) ; 
      run_test() ; 
   end 

endprogram 
