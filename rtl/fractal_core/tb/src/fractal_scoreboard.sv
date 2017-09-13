`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

class fractal_scoreboard extends scoreboard #(packet,packet); 

   uvm_analysis_imp_decl_before #(packet, fractal_scoreboard) before_export ; 
   uvm_analysis_imp_decl_after  #(packet, fractal_scoreboard) after_export ; 
   int   pkt_cnt = 0 ; 
   realtime timeout  =  10us;

   `uvm_component_utils(fractal_scoreboard) 


   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new
   
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     before_export   =  new("before_export", this);
     after_export    =  new("after_export",  this);
    
     
