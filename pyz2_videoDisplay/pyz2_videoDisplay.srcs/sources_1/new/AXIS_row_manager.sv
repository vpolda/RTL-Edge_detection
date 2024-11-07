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

    parameter integer STAGES = 0,
    //need as many slave AXI interfaces as stages + 1

    parameter integer WIDTH = 1280,
    parameter integer HEIGHT = 720,

    parameter integer S_AXIS_TDATA_WIDTH = 10240,
    parameter integer M_AXIS_TDATA_WIDTH = 72,

    )(
    //input from FIFO 1, deserialized
    input logic  clk,
    input logic  aresetn,

    output logic  s_axis_tready,
    input logic  s_axis_tvalid, 
    input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,

    input logic  s_axis_tlast, //end of line
    input logic  s_axis_tuser, //start of frame

    //Slaves

    //output to kernel shifter
    input logic  m_axis_tready,
    output logic [M_AXIS_TDATA_WIDTH+1 : 0] m_axis_tdata, ////with padding
    output logic  m_axis_tvalid,

    output logic  m_axis_tlast, //indicates last packet
    output logic  m_axis_tuser, //start of frame
    output logic [2:0] m_axis_tid

    
    

    );

   //pointers
    integer fifo2_load_row_ptr = 0; //this shows which row is currently being loaded or done from FIFO2

    //create one of these for each stages, set initial to 0
    //stage 0 = sobel
    integer stg0_row_ptr = 0; //this contains which row the stage0 is/did load

   //Stage manager
    integer stage = 0; //need to pass through to TID

   //Memory manager
    //720 rows of 10240 bits
    reg [(WIDTH*8)-1:0] rows [0:(HEIGHT-1)]; //adding two for padding row0 and row1280, and first and last pixel padding

    //shift in data from stages, only enable them if rows > 3 so no overwriting
    //enables kernal shifters when rows are ready on clock

   
endmodule
