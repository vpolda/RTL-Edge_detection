`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2024 03:22:59 PM
// Design Name: 
// Module Name: axis_vid_mod_tb
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


module axis_vid_mod_tb( );
    //inputs
    logic clk;
    //logic clkw;
    //assign clkw = clk;
    
    logic rstn;
    //logic rstnw = rstn;
    //assign rstnw = rstn;
    
    logic s_axis_tvalid;
    //logic s_axis_tvalidw;
    //assign s_axis_tvalidw = s_axis_tvalid;
    
    logic [23:0] s_axis_tdata;
    //logic [23:0] s_axis_tdataw;
    //assign s_axis_tdataw = s_axis_tdata;
    
    //outputs
    logic FIFO_wr_en;
    logic FIFO_wr_ack;
    logic s_axis_tready;
    logic full;
    //wire s_axis_treadyw;
    
    axis_vid_mod axis_vid_mod_i
       (
        .clk_0(clk),
        .rstn(rstn),
        .s00_axis_tdata_0(s_axis_tdata),
        .s00_axis_tready_0(s_axis_tready),
        .s00_axis_tvalid_0(s_axis_tvalid),
        .wr_en(FIFO_wr_en),
        .full_0(full)
        );

    initial begin
        //connect wires to registers
        //s_axis_tready = s_axis_treadyw;
        //s_axis_tdata = s_axis_tdataw;
        //s_axis_tvalid = s_axis_tvalidw;
        
        //rstn = rstnw;
        //clk = clkw;
        
        // Initialize inputs
        clk = 1;
        rstn = 0;
        s_axis_tdata = 0;
        s_axis_tvalid = 0;

        // Monitors
       
        
        // Apply reset
        #20 rstn = 1;

        // Apply stimulus
        #10 s_axis_tdata = 32'h00000008;
        s_axis_tvalid = 1;
        #60 
        

        #10 for (integer i =0; i<10 ; i = i+1) begin
            
            #10 s_axis_tdata = s_axis_tdata + 1'h1;
        end
        
        s_axis_tvalid = 0;
        // Clean up
        #10 $finish;
    end

    always #5 clk = ~clk;
    
endmodule
