
  `uvm_analysis_imp_decl(_before)
  `uvm_analysis_imp_decl(_after)

class scoreboard #(type T_SRC = packet, type T_DST = packet ) extends uvm_scoreboard;
   uvm_analysis_imp_before  #(T_SRC, scoreboard)    before_export ; 
   uvm_analysis_imp_after   #(T_DST, scoreboard)    after_export;

   typedef uvm_algorithmic_comparator #(T_SRC, T_DST, transformer ) packet_cmp ; 

   packet_cmp     comparator ; 
   transformer    trans ; 
   int            pkt_cnt = 0 ;
   realtime timeout  =  10us;

   `uvm_component_param_utils_begin(scoreboard #(T_SRC, T_DST) );  
      `uvm_field_object(comparator, UVM_PRINT | UVM_COPY)  
   `uvm_component_utils_end

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     trans           =  transformer::type_id::create("trans",this); 
     comparator      =  new("comparator",this, trans);   
     before_export   =  new("before_export",this);
     after_export    =  new("after_export",this);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: connect_phase

   virtual function void write_before( T_SRC pkt ) ; 
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     comparator.before_export.write(pkt) ;  
     pkt_cnt++; 
   endfunction: write_before

   virtual function void write_after( T_DST pkt ) ; 
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     comparator.after_export.write(pkt) ;  
     pkt_cnt--; 
   endfunction: write_after

   virtual function string convert2string();
     return $sformatf("Comparator Matches = %0d, Mismatches = %0d", comparator.comp.m_matches, comparator.comp.m_mismatches);
   endfunction: convert2string
   // The following are supplemental methods for detecting end of test and reporting results.
   // They will be implemented in the derived classes.
   virtual task wait_for_done();
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     fork
       wait(pkt_cnt == 0 ) ; 
       begin 
         #timeout;
         `uvm_warning("TIMEOUT", $sformatf("Scoreboard has %0d unprocessed expected objects", pkt_cnt));
       end
     join_any
     disable fork; 
   endtask

   virtual function void set_timeout(realtime timeout);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    this.timeout=timeout;
   endfunction: set_timeout

   virtual function realtime get_timeout();
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    return (timeout);
   endfunction: get_timeout

endclass: scoreboard
