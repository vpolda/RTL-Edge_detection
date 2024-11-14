`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2024 02:12:41 PM
// Design Name: 
// Module Name: kernal_shifter
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
//NEED TO ADD PADDING!! Should add 2 pixels to each row

module kernal_shifter #
	(
		parameter integer S_AXIS_TDATA_WIDTH	= 10242, //adding padding
		parameter integer M_AXIS_TDATA_WIDTH	= 72,

        parameter integer HEIGHT = 720,
        parameter integer WIDTH	= 1280,

        parameter integer STAGES = 1
	)(
    input logic clk,
    input logic rstn,
    
    //Slave - BRAM 
    output logic doutb,
    output logic addrb,
    output logic enb,

    //Master - AXIS Process module
    input logic  m_axis_tready,
    output logic [M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
    output logic  m_axis_tvalid,

    output logic  m_axis_tlast, //indicates last packet
    output logic m_axis_tuser
    );


endmodule