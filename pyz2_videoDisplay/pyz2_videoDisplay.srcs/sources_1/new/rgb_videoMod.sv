`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/24/2024 11:22:56 AM
// Design Name: 
// Module Name: rgb_videoMod
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


module rgb_videoMod(
    input [23:0] rgb_data_in,
    //input pixel_clk,
    input en,
    
    output reg [23:0] rgb_data_out,
    output [7:0] r_in,
    output [7:0] g_in,
    output[7:0] b_in
    );
    
    //internal
    assign r_in = rgb_data_in[23:16];
    assign g_in = rgb_data_in[15:8];
    assign b_in = rgb_data_in[7:0];
    
    //combinational block, use blocking assignment
    //make sure outputs have a default/else statement and are assigned
    always @(*) begin
        if (en) begin
            rgb_data_out = ~rgb_data_in;
        end else
            rgb_data_out = rgb_data_in;
    end
    
endmodule
