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

module kernel_shifter # (
    parameter integer HEIGHT = 720,
    parameter integer WIDTH	= 1280,

    parameter integer M_AXIS_TDATA_WIDTH = 8, //From FIFO to BRAM

    parameter integer STAGES = 1

 ) (
    //basic
    input rstn,
    input clk,

    //input BRAM
    input logic [M_AXIS_TDATA_WIDTH-1 : 0] doutb,
    output logic [$clog2(FRAME)-1 : 0] addrb,
    output logic enb,

    // output - to process modules
    input logic  m_axis_tready, //slave is ready
    output logic [M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
    output logic  m_axis_tvalid,
    output logic [METADATA_WIDTH-1 : 0] m_axis_tid,

    //oversight
    output logic row_done,
    output logic frame_started

 );

    localparam FRAME = HEIGHT*WIDTH + METADATA_WIDTH;
    localparam METADATA_WIDTH = $clog2(STAGES+1);

    //as soon as slave is ready, read and output
    //conintue until row is done, alert oversight manager
    //do entire frame, alert new frame, start over

    always @(posedge clk) begin
        //but first, reset
        if (!rstn) begin
            addrb <= METADATA_WIDTH - 1;
            enb <= 0;
            
            m_axis_tdata <= {M_AXIS_TDATA_WIDTH{1'b0}};
            m_axis_tvalid <= 0;
            m_axis_tid <= {METADATA_WIDTH{1'b0}};

            frame_started <= 0;
            row_done <= 0;

        //if slave is ready
        end else if (m_axis_tready) begin
            //read from BRAM
            addrb <= addrb + 1;
            enb <= 1;

            //output to slave and tell slave ready
            m_axis_tvalid <= 1;
            m_axis_tdata <= doutb;

            //increment addrb
        end

    end

endmodule