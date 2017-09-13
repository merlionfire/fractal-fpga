`ifndef RESET_DRIVER__SV
`define RESET_DRIVER__SV

class reset_driver extends uvm_driver #(reset_tr);
  virtual reset_if    vif;          // DUT virtual interface
  `uvm_component_utils(reset_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

    uvm_config_db#(virtual reset_if)::get(this, "", "vif", vif);
  endfunction: build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    if (vif == null) begin
      `uvm_fatal("CFGERR", "Interface for reset driver not set");
    end
  endfunction: end_of_elaboration_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask: run_phase

  virtual task drive(reset_tr tr);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    if (tr.kind == reset_tr::ASSERT) begin
      vif.drv.rst <= 1'b1;
      repeat(tr.cycles) @(vif.drv);
    end else begin
      vif.drv.rst <= 1'b0;
      repeat(tr.cycles) @(vif.drv);
    end
  endtask: drive

endclass
`endif

