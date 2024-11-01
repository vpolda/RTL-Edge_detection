`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 06:40:05 AM
// Design Name: 
// Module Name: deserializer_tb
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


module kernal_shifter_wrapper_tb();
    
    // Initialize inputs
    logic clk = 1;
    logic rstn = 0;
    logic [7:0 ]serial_in = 8'b00000000;
      
    //outputs
    logic [71:0] pixels_out;
    logic pixel_data_valid;
    
    logic FIFO_rd_en;
    logic FIFO_empty = 0;

kernal_shifter_wrapper # (.IN_BITS(8), .OUT_SIZE(4)) uut (
    .clk(clk),
    .rstn(rstn), //hold in reset
    .serial_in(serial_in),
    .pixels_out(pixels_out),
    .pixel_data_valid(pixel_data_valid),
    .FIFO_empty(FIFO_empty),
    .FIFO_rd_en(FIFO_rd_en)
);

initial begin
        
        //hold in reset then release
        #20 rstn = 1;

        // Apply stimulus
        #10 for (integer i =0; i<14 ; i = i+1) begin
            serial_in = serial_in + 1'h1;
        end
        
        // Clean up
        #10 $finish;
    end

    //clock gen
    always #5 clk = ~clk;

endmodule
