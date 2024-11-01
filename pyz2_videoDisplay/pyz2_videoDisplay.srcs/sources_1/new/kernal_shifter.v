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


module kernal_shifter(
    input clk,
    input rstn,
    
    input data_valid,
    input [10239:0] row, //LSB is pixel 0 8 bits
    
    output logic [71:0] pixels_out,
    output logic pixel_data_valid_out
    );
    
    parameter HEIGHT = 720;
    
    logic [10239:0] row0;
    logic [10239:0] row1;
    logic [10239:0] row2;
    
    logic shifting_pixels;
    logic pixel_data_valid;

    integer height_cnt;
    
    assign pixel_data_valid_out = pixel_data_valid;
    
    //reset and output and shifting pixel state
    always @(posedge clk) begin
        if (!rstn) begin
            pixels_out <= 72'b0;
            height_cnt <= 0;
        //let first two rows load, then start shifting
        //Stop at row 719
        end else if ((height_cnt > 2) & (height_cnt < HEIGHT) & !shifting_pixels)
            shifting_pixels <= 1;
        else
            pixels_out <= PS_pixels_out;
    end

    always @(negedge pixel_data_valid)
        //if causes multiple driving, merge to above with
        shifting_pixels <= 0;
    
    //Row handling
    //If data from serializer is ready and its not currently shifting pixels, shift rows
    always @(posedge clk) begin
        if (!rstn) begin
            row0 <= 10239'b0;
            row1 <= 10239'b0;
            row2 <= 10239'b0;
            height_cnt <= 0;
        //let first two rows load, then start shifting
        //Stop at row 719
        end else if (data_valid & !shifting_pixels) begin //might not want to rely on shifting pixels state
            //Think it just needs to be one cycle, could be more, LOOK AT SCHEMATIC
            row0 <= row;
            row1 <= row0;
            row2 <= row1;

            height_cnt <= height_cnt + 1;
        end else begin
            //otherwise remain constant for pixel shifting
            row0 <= row0;
            row1 <= row1;
            row2 <= row2;
            
        end
    end
    
    //pixel shift module inst
    logic [71:0] PS_pixels_out;
    
    
    pixel_shift # (.WIDTH(12)) pixel_shift_inst(
        .clk(clk),
        .rstn_in(rstn),
    
        .shifting_pixels(shifting_pixels), //state
        .row0(row0), //rows
        .row1(row1),
        .row2(row2),
    
     .pixel_data_valid(pixel_data_valid),
     .pixels_out(PS_pixels_out)
    );
    
endmodule


module pixel_shift (
    input clk,
    input rstn_in,
    
    input shifting_pixels, //state
    input logic [10239:0] row0, //rows
    input logic [10239:0] row1,
    input logic [10239:0] row2,
    
    output logic pixel_data_valid,
    output logic [71:0] pixels_out
    //might need signal for reached end of line
); 

parameter WIDTH = 1280;

integer width_cnt = 0;
//first set reset high
logic rstn = 0;

logic [7:0] 
    p1, p2, p3,
    p4, p5, p6,
    p7, p8, p9;

//reset and OUTPUT
always @(posedge clk) begin
        //if either reset is active
        if ((!rstn | !rstn_in)) begin
            pixels_out <= 72'b0;
            //pixel_data_valid <= 0;
        //else if pixel data is not valid, output 0's
        end else
            pixels_out <= {p1, p2, p3, p4, p5, p6, p7, p8, p9};
end
    
always @(posedge clk) begin
    //if in reset, don't load
    if (!rstn | !rstn_in) begin
        {p1, p2, p3, p4, p5, p6, p7, p8, p9} <= '{default: '0};
        width_cnt <= 0;
    end else if (!shifting_pixels) begin
        {p1, p2, p3, p4, p5, p6, p7, p8, p9} <= {p1, p2, p3, p4, p5, p6, p7, p8, p9};
    //other wise shift
    end else begin
        p1 <= row0[(width_cnt)*8 +: 8];
        p2 <= p1;
        p3 <= p2;
        
        p4 <= row1[(width_cnt)*8 +: 8];
        p5 <= p4;
        p6 <= p5;
        
        p7 <= row2[(width_cnt)*8 +: 8];
        p8 <= p7;
        p9 <= p8;
        
        width_cnt <= width_cnt + 1;
    end
end


    always @(posedge clk) begin 
        //let first two rows load, then start shifting
        //Stop at row 1279
        if (shifting_pixels & (width_cnt < WIDTH)) begin
            //output pixel data ready, pull out of reset and move cnt 
            rstn <= 1;
            
            if (width_cnt < 3) 
                pixel_data_valid <= 0;
            else
                pixel_data_valid <= 1;
        end else if (shifting_pixels & (width_cnt == WIDTH)) begin
            //at end, watch for neg edge of shifting pixel?
            //put into reset, since at end of rows. need to wait for more rows to load.
            //shifting pixels should go low.
            rstn <= 0;
            pixel_data_valid <= 0;
        end else begin
            //in case that shifting_pixels is low. means data is loading into rows.
            //pixel data is not valid, don't reset just pause
            //rstn <= 0;
            pixel_data_valid <= 0;
        end
    end

endmodule