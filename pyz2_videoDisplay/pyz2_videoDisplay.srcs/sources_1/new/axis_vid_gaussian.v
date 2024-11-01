`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/25/2024 10:04:45 AM
// Design Name: 
// Module Name: axis_vid_gaussian
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 

//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//unsure how to handle resets and enables

module gaussian_blur_9bit(
    input [71:0] pixel_in, //a 3x3 matrix of byte pixels, this only needs one value of rgb since it is greyscale
    input pixel_in_ready,
    input clk,
    
    output reg [7:0] pixel_blur,
    output pixel_blur_ready
    );
    
    reg [15:0] mult_data [8:0]; //9 counts of 16 bits, storage for multiplied data
    
    always @(posedge clk) begin
        mult_data[0] <= pixel_in[0*8+:8]; //1
        mult_data[1] <= pixel_in[1*8+:8] << 1; //2
        mult_data[2] <= pixel_in[2*8+:8]; //1
        
        mult_data[3] <= pixel_in[3*8+:8] << 1; //2
        mult_data[4] <= pixel_in[4*8+:8] << 2; //4
        mult_data[5] <= pixel_in[5*8+:8] << 1; //2
        
        mult_data[6] <= pixel_in[6*8+:8]; //1
        mult_data[7] <= pixel_in[7*8+:8] << 1; //2
        mult_data[8] <= pixel_in[8*8+:8]; //1
    end

    reg [15:0] sum_data_1;
    reg [15:0] sum_data_2;

    //summation
    //Separation of procedural and combo done most likely for explict differentation in the PL

    integer i;
    always @(*) begin
        sum_data_1 = 0;
        for (i = 0; i<9; i=i+1)
            sum_data_1 = sum_data_1 + mult_data[i];
    end

    always @(posedge clk) begin
        sum_data_2 <= sum_data_1;
    end
    
    always @(posedge clk) begin
        pixel_blur <= sum_data_2 >> 4; //divide by 16, part of gaussian convolution, divide by total
    end
    
endmodule
