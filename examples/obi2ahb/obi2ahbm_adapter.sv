// Copyright 2023 Intrinsix Corp.
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

// ============================================================================
//
// Description    : OBI to AHB-Lite Master Adaptor
// 

module obi2ahbm_adapter (
   // Clock and reset
   input             hclk,                // (I) AHB clock
   input             hreset_n,            // (I) AHB reset, active LOW
   
   // AHB master interface
   output logic  [31:0]   haddr_m,        // (O) 32-bit AHB system address bus
   output logic   [2:0]   hburst_m,       // (O) Burst type 
   output logic           hmastlock_m,    // (O) Sequence lock
   output logic   [3:0]   hprot_m,        // (O) Protection control
   output logic   [2:0]   hsize_m,        // (O) Transfer size
   output logic   [1:0]   htrans_m,       // (O) Transfer type
   output logic  [31:0]   hwdata_m,       // (O) 32-bit AHB write data bus
   output logic           hwrite_m,       // (O) Transfer direction
   input  logic  [31:0]   hrdata_m,       // (I) 32-bit AHB read data bus
   input  logic           hready_m,       // (I) Status of transfer
   input  logic           hresp_m,        // (I) Transfer response
   
   // Data interface from core
   input  logic           data_req_o,     // (I) Request ready
   output logic           data_gnt_i,     // (O) The other side accepted the request
   output logic           data_rvalid_i,  // (O) Read data valid when high
   input  logic           data_we_o,      // (I) Write enable (active HIGH)
   input  logic   [3:0]   data_be_o,      // (I) Byte enable
   input  logic  [31:0]   data_addr_o,    // (I) Address
   input  logic  [31:0]   data_wdata_o,   // (I) Write data
   output logic  [31:0]   data_rdata_i,   // (O) Read data
   output logic           data_err_i,     // (O) Error
   input  logic           pending_dbus_xfer, // (I) Asserted if data bus is busy from other transactions

   // Miscellaneous
   input  logic           priv_mode       // (I) Privilege mode (from core. 1=machine mode, 0=user mode)
);

   // ********** //
   // Parameters //
   // ********** //
   parameter HPROT_NONCACHEABLE  =  1'b0;
   parameter HPROT_NONBUFFERABLE =  1'b0;
   parameter HPROT_DATAACCESS    =  1'b1;
   
   parameter MACHINE_MODE        =  1'b1;
   
   parameter HBURST_SINGLE       =  3'b000;
   
   parameter TIE_LO              =  1'b0;
   
   parameter AHB_FSM_WAIT        =  2'b00;
   parameter AHB_FSM_DATA        =  2'b10;

   // ********** //
   // Wires/Regs //
   // ********** //
   
   logic   [1:0]     ahb_fsm_reg;
   logic   [1:0]     ahb_fsm_reg_nxt;   
     
   logic  [31:0]     haddr_m_reg;
   logic   [3:0]     hprot_m_reg;
   logic   [2:0]     hsize_m_reg;
   logic             hwrite_m_reg;

   
   logic             data_err_i_nxt;

   logic    [31:0]   data_rdata_i_reg;

   logic    [31:0]   hwdata_m_nxt;
   
   logic             prev_data_gnt_i;
   // ********************** //
   // Continuous assignments //
   // ********************** //
     
   // These signals are unused, so OK that they are tied to a constant
   // lint_checking TIELOG off
   // Only single bursts are supported
   assign hburst_m      =  HBURST_SINGLE;
   
   // hmastlock_m is not used, so it is tied low
   assign hmastlock_m   =  TIE_LO;
   // lint_checking TIELOG on
       
   // A grant should only happen on a request, and if the AHB side is ready
   // to respond. Don't initiate an AHB xfer if the data bus is busy from
   // other pending xfers
   assign data_gnt_i    =  hready_m && data_req_o && !pending_dbus_xfer;
   
   // The valid signal should only assert when transitioning to the DATA state
   assign data_rvalid_i =  ahb_fsm_reg == AHB_FSM_DATA ? hready_m : 1'b0;
      
   // ************* //
   // Clocked Logic //
   // ************* //
   always @ (posedge hclk or negedge hreset_n) begin
      if (!hreset_n) begin
         data_err_i        <= 1'b0;
         data_rdata_i_reg  <= 32'h00000000;
         
         haddr_m_reg           <= 32'h00000000;
         hprot_m_reg           <= {HPROT_NONCACHEABLE, HPROT_NONBUFFERABLE, MACHINE_MODE, HPROT_DATAACCESS};
         hsize_m_reg           <= 3'b000;
         
         // Write data needs to come one cycle after per AHB protocol
         hwdata_m          <= 32'h00000000;
         
         hwrite_m_reg          <= 1'b0;
         
         ahb_fsm_reg       <= AHB_FSM_WAIT;

         prev_data_gnt_i   <= 1'b0;
      end
      else begin
         data_err_i        <= data_err_i_nxt;
         data_rdata_i_reg  <= data_rdata_i;    
         
         haddr_m_reg           <= haddr_m;
         hprot_m_reg           <= hprot_m;
         hsize_m_reg           <= hsize_m;
         
         hwdata_m          <= hwdata_m_nxt;         
         
         hwrite_m_reg          <= hwrite_m;
                 
         ahb_fsm_reg       <= ahb_fsm_reg_nxt;
         if (!data_rvalid_i) begin
           prev_data_gnt_i   <= data_gnt_i | prev_data_gnt_i;
         end else begin
           prev_data_gnt_i   <= data_gnt_i;
         end
      end
   end


   // ******************* //
   // Combinational Logic //
   // ******************* //
   always @ (*) begin
  
      // Signal that the current request errored out and the read is invalid if
      // an AHB error response is received 
      data_err_i_nxt    =  hresp_m;
         
   end

   //AHB Logic
   always @ (*) begin
      hprot_m = hprot_m_reg;
      haddr_m = haddr_m_reg;
      hwrite_m = hwrite_m_reg;
      // lint_checking TIELOG off
      // If htrans_m is not driven to non-seq while data_gnt_i is set
      // then it should be idle and set to (2'b00)
      htrans_m = 2'b00;
      // lint_checking TIELOG on
      hwdata_m_nxt = hwdata_m;
      hsize_m = hsize_m_reg;

      unique case (ahb_fsm_reg)
        AHB_FSM_WAIT: begin
          // Idles until data_gnt_i is received
          // Once data_gnt_i is received, this is the address phase of AHB
          // and all ahb signals are fed through from the core
          if (data_gnt_i) begin
            // lint_checking TIELOG off
            // Non-bufferable, non-cacheable data accesses are supported. The 
            // privilege bit, hprot_m[1], is driven by the privilege mode
            // that the core is currently in (1 for machine, 0 for user)
            hprot_m = {HPROT_NONCACHEABLE, HPROT_NONBUFFERABLE, priv_mode, HPROT_DATAACCESS};
            // lint_checking TIELOG on

             // The address, transfer request, and write enable can be fed
            // through from the core to the corresponding AHB signals. For 
            // htrans_m, if data_gnt_i is given, the ahb is in address phase,
            // and the transaction is non-sequential (1'b10).
            haddr_m = data_addr_o;
            hwrite_m = data_we_o;

            // lint_checking TIELOG off
            htrans_m = 2'b10;
            // lint_checking TIELOG on

            // Write data needs to be in data phase (After data_gnt_i is de-asserted)
            // So the data fromthe core is registered to save it for completing the transaction
            hwdata_m_nxt = data_wdata_o;

            // lint_checking TIELOG off
            // Only word (32-bit), half-word (16-bit), or byte (8-bit)
            // aligned transfers are supported. Invalid responses default to
            hsize_m[2] = TIE_LO;
            // lint_checking TIELOG on
            hsize_m[1] = &data_be_o;
            hsize_m[0] = (data_be_o[3] & data_be_o[2]) ^ (data_be_o[1] & data_be_o[0]);
          end
        end
        AHB_FSM_DATA: begin
          // DATA phase
          // read data is fed through from the core
          data_rdata_i = hrdata_m;

          // If data_gnt_i is also given during the data phase, then it is also
          // the subsequent address phase, so the necessary signals get 
          // passed through from the core
          if (data_gnt_i) begin
            // lint_checking TIELOG off
            // Non-bufferable, non-cacheable data accesses are supported. The 
            // privilege bit, hprot_m[1], is driven by the privilege mode
            // that the core is currently in (1 for machine, 0 for user)
            hprot_m = {HPROT_NONCACHEABLE, HPROT_NONBUFFERABLE, priv_mode, HPROT_DATAACCESS};
            // lint_checking TIELOG on
            // The address, transfer request, and write enable can be fed
            // through from the core to the corresponding AHB signals. For 
            // htrans_m, if data_gnt_i is given, the ahb is in address phase,
            // and the transaction is non-sequential (1'b10).
            haddr_m = data_addr_o;
            hwrite_m = data_we_o;

            // lint_checking TIELOG off
            htrans_m = 2'b10;
            // lint_checking TIELOG on

            // Write data needs to be in data phase (After data_gnt_i is de-asserted)
            // So the data fromthe core is registered to save it for completing the transaction
            hwdata_m_nxt = data_wdata_o;

            // lint_checking TIELOG off
            // Only word (32-bit), half-word (16-bit), or byte (8-bit)
            // aligned transfers are supported. Invalid responses default to
            hsize_m[2] = TIE_LO;
            // lint_checking TIELOG on
            hsize_m[1] = &data_be_o;
            hsize_m[0] = (data_be_o[3] & data_be_o[2]) ^ (data_be_o[1] & data_be_o[0]);
          end
        end
      endcase
   end

   //FSM
   always @ (*) begin
    ahb_fsm_reg_nxt = ahb_fsm_reg;

    unique case (ahb_fsm_reg)
      // IDLE/ADDRESS phase 
      // Waits until "ADDRESS Phase" occurs during data_gnt_i
      AHB_FSM_WAIT: begin
        if (data_gnt_i) begin
          ahb_fsm_reg_nxt = AHB_FSM_DATA;
        end
      end
      // DATA/ADDRESS phase
      // DATA phase for alread started transaction.
      // If data_gnt_i it is also the ADDRESS phase for the next set of data so it stays
      // in the data phase on the next cycle
      AHB_FSM_DATA: begin
        if (data_rvalid_i) begin
          if (data_gnt_i) begin
            ahb_fsm_reg_nxt = AHB_FSM_DATA;
          end else begin
            ahb_fsm_reg_nxt = AHB_FSM_WAIT;
          end
        end
      end
    endcase
   end
   // lint_checking TRNMBT on   
   // lint_checking HASUPC on
endmodule : obi2ahbm_adapter
