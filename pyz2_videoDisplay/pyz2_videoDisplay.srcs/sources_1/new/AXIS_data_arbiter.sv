`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 08:51:49 AM
// Design Name: 
// Module Name: FIFO2_arbiter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//"Now go spartan, I shall remain here." -Arbiter

//needs to set tuser and tlast for FIFO3

module AXIS_data_arbiter # (
        parameter STAGES = 3'b000,
        parameter S_AXIS_TDATA_WIDTH = 8,
        parameter S_AXIS_TID_WIDTH = 3 //for max of 8 stages 
    ) (
   // AXI Slave Interface (S_AXIS)
    input wire  s_axis_aclk,
	input wire  s_axis_aresetn,
    input logic [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,        // Slave Data In
    input logic s_axis_tvalid,                                  // Slave Data Valid
    output logic s_axis_tready,                                 // Slave Ready
    input logic s_axis_tlast,                                   // Slave Last Flag
    input logic [S_AXIS_TID_WIDTH-1:0] s_axis_tid,            // Slave User Data (Optional)

   // AXI Master 1 (M_AXIS_1) - FIFO3, output
    //route to here if done processing
    output logic [S_AXIS_TDATA_WIDTH-1:0] m_axis_1_tdata,      // Master 1 Data Out
    output logic m_axis_1_tvalid,                               // Master 1 Data Valid
    input logic m_axis_1_tready,                                // Master 1 Ready
    output logic m_axis_1_tlast,                                // Master 1 Last Flag
    output logic [S_AXIS_TID_WIDTH-1:0] m_axis_1_tid,         // Master 1 User Data (Optional)

   // AXI Master 2 (M_AXIS_2) - Row manager
    output logic [S_AXIS_TDATA_WIDTH-1:0] m_axis_2_tdata,      // Master 2 Data Out
    output logic m_axis_2_tvalid,                               // Master 2 Data Valid
    input logic m_axis_2_tready,                                // Master 2 Ready
    output logic m_axis_2_tlast,                                // Master 2 Last Flag
    output logic [S_AXIS_TID_WIDTH-1:0] m_axis_2_tid          // Master 2 User Data (Optional)
);

    //Check if ID is the last stage, if so set tvalid
    logic last_stage_state;
    assign last_stage_state = (s_axis_tid == STAGES);

    //tvalid
    assign m_axis_1_tvalid = last_stage_state ? s_axis_tvalid : 1'b0;
    assign m_axis_2_tvalid = last_stage_state ? 1'b0 : s_axis_tvalid;

    //tready
    assign s_axis_tready = last_stage_state ? m_axis_1_tready : m_axis_2_tready;

    //passthrough
    assign m_axis_1_tdata = s_axis_tdata;
    //assign m_axis_1_tready = s_axis_tready;
    assign m_axis_1_tlast = s_axis_tlast;
    assign m_axis_1_tid = s_axis_tid;
    
    assign m_axis_2_tdata = s_axis_tdata;
    //assign m_axis_2_tready = s_axis_tready;
    assign m_axis_2_tlast = s_axis_tlast;
    assign m_axis_2_tid = s_axis_tid;


endmodule
