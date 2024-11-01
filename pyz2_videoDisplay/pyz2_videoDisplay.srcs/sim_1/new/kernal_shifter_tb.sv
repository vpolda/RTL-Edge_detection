`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2024 08:01:33 AM
// Design Name: 
// Module Name: kernal_shifter_tb
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

module kernal_shifter_tb();
    // Initialize inputs
    logic clk = 1;
    logic rstn = 0;
    
    //in
    logic data_valid;
    logic [10239:0] row; //LSB is pixel 0 8 bits
    //out
    logic [71:0] pixels_out;
    logic pixel_data_valid;
    

    kernal_shifter # (.HEIGHT(9),.WIDTH(9)) uut_inst (
        .clk(clk),
        .rstn(rstn),

        .data_valid(data_valid),
        .row(row),

        .pixels_out(pixels_out),
        .pixel_data_valid_out(pixel_data_valid)
    );

    initial begin
        
        // Initialize inputs
        clk = 1;
        rstn = 0;
        
        // release reset
        #20 rstn = 1;

        data_valid = 1;
        row [10239:0] = '{default: '1};

        
        // Clean up
        #10 $finish;
    end

    //clock gen
    always #5 clk = ~clk;

endmodule


/*module kernal_shifter_tb();

 // Initialize inputs
    logic clk = 1;
    logic rstn = 0;
    logic shifting_pixels = 0; //state
    logic [10239:0] row0 = '{default: '1}; //rows
    logic [10239:0] row1 = '{default: '1};
    logic [10239:0] row2 = '{default: '1};
    
    logic pixel_data_valid; //output ready for one clock cycle
    logic [71:0] pixels_out;

pixel_shift #(.WIDTH(32)) uut_inst (
    .clk (clk),
    .rstn_in (rstn),
    .shifting_pixels (shifting_pixels),
    .row0 (row0),
    .row1 (row1),
    .row2 (row2),

    .pixel_data_valid (pixel_data_valid),
    .pixels_out(pixels_out)
);

initial begin
        
        // Initialize inputs
        clk = 1;
        rstn = 0;

        // Monitors
       
        
        // Apply reset
        #20 rstn = 1;


        #10
        shifting_pixels = 1;

        #100
        shifting_pixels = 0;
        #10
        shifting_pixels = 1;
        
        // Clean up
        #10 $finish;
    end

    //clock gen
    always #5 clk = ~clk;

endmodule*/