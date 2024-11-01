`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2024 08:49:06 AM
// Design Name: 
// Module Name: axis_vid_modifier
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 

//This module is for changing the axi stream data from a video image input
//it pulls data from the fifo

// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axis_vid_rgb2grey(
    input [31:0] data_in, //ignore first byte as it is padding of 0s
    output [7:0] data_out
    );
    
    //greyscale conversion
    wire [23:0] color_avg;
    //>>2 divides by 2^2
    // Green is shifted left to brighten
    assign data_out = (data_in[23:16] + (data_in[15:8]<<1) + data_in[7:0]) >> 2;
    //assign data_out = {color_avg[7:0], color_avg[7:0], color_avg[7:0]};
    
endmodule
