`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2024 09:17:57 AM
// Design Name: 
// Module Name: first_in_array_out
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


module first_in_array_out_tb();

    logic clk;
    logic arstn;
    logic en;

    logic [7:0] data_in;
    logic [71:0] data_out;
    logic ready;

    first_in_array_out uut (
        .clk (clk),
        .rstn(arstn),
        .en(en),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    initial begin
        // Initialize inputs
        clk = 1;
        arstn = 1; //hold in reset
        data_in = 0;
        en = 0;

        // Monitors
       
        
        // Apply reset
        #20 arstn = 0;

        // Apply stimulus
        #10 en = 1;
        #10 data_in = 8'b10000000;
        

        for (integer i =0; i<5 ; i = i+1) begin
            #10 data_in = data_in + 8'h40;
        end
        
        #60
        
        en = 0;
        #10 arstn = 1;
        #20
        // Clean up
        #10 $finish;
    end

    always #5 clk = ~clk;

endmodule
