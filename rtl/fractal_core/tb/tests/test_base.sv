class test_base extends uvm_test;
   `uvm_component_utils(test_base)

   fractal_env       env;
   virtual up_if     cpu_if;
   virtual reset_if  rst_if;

   
   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     env =  fractal_env::type_id::create("env",this); 
     uvm_resource_db#(virtual up_if)::read_by_type("cpu_if", cpu_if, this); 
     uvm_resource_db#(virtual reset_if)::read_by_type("rst_if", rst_if, this); 

     uvm_config_db#(virtual up_if)::set(this,"env.mst_agt","vif", cpu_if); 
     uvm_config_db#(virtual up_if)::set(this,"env.o_agt","vif", cpu_if); 
     uvm_config_db#(virtual reset_if)::set(this,"env.rst_agt","vif", rst_if); 
   endfunction: build_phase
   
   virtual function void report_phase(uvm_phase phase);
     super.report_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     `uvm_info("SB_REPORT", {"\n", env.sb.convert2string()}, UVM_MEDIUM);
   endfunction: report_phase

   virtual task shutdown_phase(uvm_phase phase);
     super.shutdown_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     phase.raise_objection(this);
     env.sb.wait_for_done();
     phase.drop_objection(this);
   endtask: shutdown_phase

   virtual function void final_phase(uvm_phase phase);
     super.final_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     if (uvm_report_enabled(UVM_HIGH, UVM_INFO, "TOPOLOGY")) begin
       uvm_top.print_topology();
     end

     if (uvm_report_enabled(UVM_MEDIUM, UVM_INFO, "FACTORY")) begin
       uvm_factory  f = uvm_factory::get() ; 
       f.print();
     end
     //uvm_resources.dump(.audit(1));
     //uvm_resources.dump_get_records();
  endfunction: final_phase

endclass: test_base
