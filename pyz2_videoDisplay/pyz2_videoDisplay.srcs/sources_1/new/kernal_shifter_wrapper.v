`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 10:46:26 AM
// Design Name: 
// Module Name: kernal_shifter_wrapper
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


module kernal_shifter_wrapper(
    input clk,
    input rstn,
    
    //input data_valid,
    //input [10239:0] row,
    
    output [71:0] pixels_out,
    output pixel_data_valid,

    output FIFO_rd_en,
    input FIFO_empty,
    input [IN_BITS-1:0] serial_in
    );
    
    parameter IN_BITS = 8;
    parameter OUT_SIZE = 1280;

    wire [(IN_BITS*OUT_SIZE)-1:0] parallel_out;
    //assign row <= parallel_out;
    wire data_valid;

    deserializer # (.IN_BITS(IN_BITS), .OUT_SIZE(OUT_SIZE)) deserial (
        .clk(clk),
        .rstn(rstn),
        .FIFO_empty(FIFO_empty),
        .serial_in(serial_in),
        .FIFO_rd_en(FIFO_rd_en),
        .parallel_out(parallel_out),
        .data_valid(data_valid)
    );

    kernal_shifter # (.HEIGHT(9)) uut_inst (
        .clk(clk),
        .rstn(rstn),

        .data_valid(data_valid),
        .row(parallel_out),

        .pixels_out(pixels_out),
        .pixel_data_valid_out(pixel_data_valid)
    );
endmodule
