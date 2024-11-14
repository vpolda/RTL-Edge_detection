`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2024 03:27:40 PM
// Design Name: 
// Module Name: AXIS_FIFO_tb
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


module axis_deser_tb(
    );
    // Parameters
    parameter integer S_AXIS_TDATA_WIDTH = 8;
    parameter integer M_AXIS_TDATA_WIDTH = 24;
    parameter integer DEPTH = 3;
    
    logic clk = 1;
    logic axis_rstn = 0;

   // Master
    logic [M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata; //o
    logic m_axis_tready = 0; //input to DUT
    logic s_axis_tvalid; //o

   //Slave
    logic [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata =  {S_AXIS_TDATA_WIDTH{1'b0}}; //i
    logic s_axis_tready; //output from DUT
    logic s_axis_tvalid = 0; //i

    //DUT
    // Instantiate the AXIS_S2M_deserializer module
    AXIS_S2M_deserializer #(
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),
        .M_AXIS_TDATA_WIDTH(M_AXIS_TDATA_WIDTH),
        .DEPTH(DEPTH)
    ) deserializer_inst (
        .s_axis_aclk(clk),
        .s_axis_aresetn(axis_rstn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid)
    );
   

initial begin

        // Release reset
        axis_rstn = 0;
        #10
        axis_rstn = 1;
        #10
        //start data input
        s_axis_tdata = s_axis_tdata + 1'b1;
        #10
        s_axis_tvalid = 1;
        #10
        s_axis_tdata = s_axis_tdata + 1'b1;
        #10
        s_axis_tdata = s_axis_tdata + 1'b1;
        #10
        s_axis_tdata = s_axis_tdata + 1'b1;
        #10
        s_axis_tvalid = 0;
        s_axis_tdata = s_axis_tdata + 1'b1;
        #10
        s_axis_tdata = s_axis_tdata + 1'b1;
        #20
        
        s_axis_tvalid = 1;
        m_axis_tready = 1;
              
        // Clean up
        #10 $finish;
    end

    //clock gen
    always #5 clk = ~clk;
endmodule