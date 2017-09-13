`ifndef RESET_MONITOR__SV
`define RESET_MONITOR__SV

class reset_monitor extends uvm_monitor;
  virtual reset_if vif;          // DUT virtual interface
  uvm_analysis_port #(reset_tr) analysis_port;
  uvm_event reset_event = uvm_event_pool::get_global("reset");
  `uvm_component_utils(reset_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

    uvm_config_db#(virtual reset_if)::get(this, "", "vif", vif);
    analysis_port = new("analysis_port", this);
  endfunction: build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    if (vif == null) begin
      `uvm_fatal("CFGERR", "Interface for reset monitor not set");
    end
  endfunction: end_of_elaboration_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

    forever begin
      reset_tr tr = reset_tr::type_id::create("tr", this);
      detect(tr);
      analysis_port.write(tr);
    end
  endtask: run_phase

  virtual task detect(reset_tr tr);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    @(vif.mon.rst);
    assert(!$isunknown(vif.rst) );
    if (vif.mon.rst == 1'b1) begin
      tr.kind = reset_tr::ASSERT;
      reset_event.trigger();
    end else begin
      tr.kind = reset_tr::DEASSERT;
      reset_event.reset(.wakeup(1));
    end
  endtask: detect

endclass

`endif

