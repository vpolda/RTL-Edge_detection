`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 05:19:01 AM
// Design Name: 
// Module Name: AXIS_row_manager
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


module AXIS_row_manager # (
    parameter integer HEIGHT = 720,
    parameter integer WIDTH	= 1280,

    parameter integer S_AXIS_TDATA_WIDTH	= 8, //From FIFO
	parameter integer M_AXIS_TDATA_WIDTH	= 72, //To BRAM
    parameter integer STAGES = 1
 ) (
    
    input logic  clk,
    input logic  rstn,
    
    //From FIFO to Prepper
    output logic  s_FIFO_axis_tready, 
    input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_FIFO_axis_tdata,
    input logic  s_FIFO_axis_tvalid,

    // from Kernel to Process Module
    input logic m_axis_tready,
    output logic [M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
    output logic m_axis_tvalid

 );
   //internal wires
    //Prepper - BRAM
    logic addra, ena, dina;
    
    //BRAM - kernel shifter
    logic addrb, enb, dinb;
    
    
   //Prepper 
    // Instantiate the Prepper module
    prepper #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),
        .STAGES(STAGES)
        //.METADATA_WIDTH(METADATA_WIDTH)
    ) prepper_inst (
        .s_axis_aclk(clk),
        .s_axis_aresetn(rstn),
        .s_axis_tready(s_FIFO_axis_tready),
        .s_axis_tdata(s_FIFO_axis_tdata),
        .s_axis_tvalid(s_FIFO_axis_tvalid),
        
        .dina(dina),
        .addra(addra),
        .ena(ena),
        
        .frame_done(frame_done),
        .en(1'b1), //nEED TO REMOVE
        .row_done(row_done)
    );

   //BRAM
    BRAM #(
        .HEIGHT(HEIGHT),               // Configure according to design requirements
        .WIDTH(WIDTH),
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),     // Data width from FIFO to BRAM
        .STAGES(STAGES),                 // Number of stages (as needed)
        .METADATA_WIDTH(1)          // Extra metadata width if required
    ) u_BRAM (
        // Reset & Clock
        .rstn(rstn),                // Active low reset signal
        .clk(clk),                  // Clock signal

        // Write interface from FIFO1 - Prepper
        .dina(dina),                // Data input for writing
        .addra(addra),              // Address input for writing
        .ena(ena),                  // Enable signal for writing

        // Read interface from Kernel Shifter
        .doutb(doutb),              // Data output for reading
        .addrb(addrb),              // Address input for reading
        .enb(enb)                   // Enable signal for reading
    );

   //Kernel Shifter
    kernel_shifter # (
        .HEIGHT(HEIGHT),              // Configure according to design requirements
        .WIDTH(WIDTH),              // Set the width of the image/frame
        .M_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),    // Data width for the AXI stream interface
        .STAGES(STAGES)                 // Number of pipeline stages as needed
    ) u_kernel_shifter (
        // Basic signals
        .rstn(rstn),               // Active-low reset signal
        .clk(clk),                 // Clock signal

        // Input BRAM interface
        .doutb(doutb),             // Data output from BRAM
        .addrb(addrb),             // Address for reading from BRAM
        .enb(enb),                 // Enable signal for reading from BRAM

        // Output to processing modules
        .m_axis_tready(m_axis_tready),  // Ready signal from the downstream module
        .m_axis_tdata(m_axis_tdata),    // Data output to the downstream module
        .m_axis_tvalid(m_axis_tvalid),  // Valid signal for output data
        .m_axis_tid(m_axis_tid),        // Metadata output (e.g., ID or tag)

        // Oversight signals
        .row_done(),       // Signal indicating that a row has been processed
        .frame_started()  // Signal indicating the start of frame processing
    );

endmodule