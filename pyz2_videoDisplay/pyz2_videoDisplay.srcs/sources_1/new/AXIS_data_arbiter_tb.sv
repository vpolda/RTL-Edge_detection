`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 08:21:38 PM
// Design Name: 
// Module Name: AXIS_data_arbiter_tb
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


module AXIS_data_arbiter_tb();

    parameter STAGES = 3'b000;
    parameter S_AXIS_TDATA_WIDTH = 8;
    parameter S_AXIS_TID_WIDTH = 3; //for max of 8 stages 

    // AXI Slave Interface (S_AXIS)
     logic clk = 0;
	 logic  s_axis_aresetn;
     logic [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata;        // Slave Data In
     logic s_axis_tvalid = 0;                                  // Slave Data Valid
     logic s_axis_tready;                                 // Slave Ready
     logic s_axis_tlast;                                   // Slave Last Flag
     logic [S_AXIS_TID_WIDTH-1:0] s_axis_tid = 0;            // Slave User Data (Optional)

    // AXI Master 1 (M_AXIS_1) - FIFO3; output
    //route to here if done processing
     logic [S_AXIS_TDATA_WIDTH-1:0] m_axis_1_tdata;      // Master 1 Data Out
     logic m_axis_1_tvalid;                               // Master 1 Data Valid
     logic m_axis_1_tready = 0;                                // Master 1 Ready
     logic m_axis_1_tlast;                                // Master 1 Last Flag
     logic [S_AXIS_TID_WIDTH-1:0] m_axis_1_tid;         // Master 1 User Data (Optional)

    // AXI Master 2 (M_AXIS_2) - Row manager
     logic [S_AXIS_TDATA_WIDTH-1:0] m_axis_2_tdata;      // Master 2 Data Out
     logic m_axis_2_tvalid;                               // Master 2 Data Valid
     logic m_axis_2_tready = 0;                                // Master 2 Ready
     logic m_axis_2_tlast;                                // Master 2 Last Flag
     logic [S_AXIS_TID_WIDTH-1:0] m_axis_2_tid;


// Instantiate the AXIS_data_arbiter
    AXIS_data_arbiter # (
        .STAGES(STAGES),                     // Set number of stages (example)
        .S_AXIS_TDATA_WIDTH(8),          // Set the data width (example)
        .S_AXIS_TID_WIDTH(3)            // Set the TID width (example)
    ) arbiter_inst (
        // AXI Slave Interface (S_AXIS)
        .s_axis_aclk(clk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tid(s_axis_tid),

        // AXI Master 1 (M_AXIS_1)
        .m_axis_1_tdata(m_axis_1_tdata),
        .m_axis_1_tvalid(m_axis_1_tvalid),
        .m_axis_1_tready(m_axis_1_tready),
        .m_axis_1_tlast(m_axis_1_tlast),
        .m_axis_1_tid(m_axis_1_tid),

        // AXI Master 2 (M_AXIS_2)
        .m_axis_2_tdata(m_axis_2_tdata),
        .m_axis_2_tvalid(m_axis_2_tvalid),
        .m_axis_2_tready(m_axis_2_tready),
        .m_axis_2_tlast(m_axis_2_tlast),
        .m_axis_2_tid(m_axis_2_tid)
    );

initial begin
        
        // Initialize inputs

        #200
        
        // Clean up
        #10 $finish;
    end

    //clock gen
    always #5 clk = ~clk;

    always #20 s_axis_tvalid = ~s_axis_tvalid;
    always #60 s_axis_tid[0] = ~s_axis_tid[0];

endmodule
