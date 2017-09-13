`ifndef TRANSFORMER__SV
`define TRANSFORMER__SV

class transformer extends  uvm_object;
    `uvm_object_utils(transformer) 

    function new(string name = "transformer" ) ; 
      super.new(name);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    endfunction 

    virtual function packet transform( input packet pkt ) ; 
       real x0, y0; 
       real x, y; 
       real xx, yy, xy ; 
       int  max_cnt ; 
       int i ; 
       x0   =  pkt.cx ; 
       y0   =  pkt.cy ; 
       max_cnt  =  pkt.iter;
       x    =  x0;
       y    =  y0;
       
       for ( i=0; i< max_cnt; i++ ) begin 
         xx =  x * x ; 
         yy =  y * y ; 
         xy =  x * y ; 
         if ( (xx + yy) > 4.0 ) break ; 
         x  =  xx - yy  + x0 ; 
         y  =  xy * 2.0 + y0 ; 
       end
       if ( i <  max_cnt ) begin 
         pkt.result  =  packet::FALSE ; 
       end else begin 
         pkt.result  =  packet::TRUE ; 
       end

       `uvm_info("Transformer", {"\n", pkt.sprint()}, UVM_MEDIUM);
       return pkt ; 

    endfunction
endclass: transformer
`endif
