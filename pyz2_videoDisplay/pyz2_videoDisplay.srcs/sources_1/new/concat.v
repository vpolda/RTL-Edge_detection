`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2024 09:49:58 PM
// Design Name: 
// Module Name: concat
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


module concat # (
    parameter DATA_IN_WIDTH = 8,
    parameter DATA_OUT_BYTES = 3 //a multiple of the input
)(
    input data_in,
    output data_out
    );

    assign data_out =  {DATA_IN{DATA_OUT_BYTES}};


endmodule
