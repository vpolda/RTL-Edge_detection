`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2024 07:45:34 AM
// Design Name: 
// Module Name: tb_top
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


module tb_top(
    );
    parameter TDATA_WDITH = 24;

    logic clk = 1;
    logic fast_clk = 0;
    logic axis_rstn = 1;

    // outputs
    logic [TDATA_WDITH-1:0] m_axis_TDATA;
    logic m_axis_TLAST;
    logic m_axis_TREADY = 0;
    logic m_axis_TUSER;
    
    logic m_axis_TVALID;

    //inputs
    logic [TDATA_WDITH-1:0] s_axis_TDATA = 24'b0;
    logic s_axis_TLAST = 0;

    logic s_axis_TREADY;
        
    logic s_axis_TUSER;
    logic s_axis_TVALID = 0;


    axis_edge_detection_passthrough axis_edge_detection_passthrough_inst1
       (.pix_clk(clk),
        .fast_clk(fast_clk),
        .axis_rstn(axis_rstn),

        .m_axis_tdata(m_axis_TDATA),
        .m_axis_tlast(m_axis_TLAST),
        .m_axis_tready(m_axis_TREADY), //input
        .m_axis_tuser(m_axis_TUSER),
        .m_axis_tvalid(m_axis_TVALID),
        
        .s_axis_tdata_w(s_axis_TDATA),
        .s_axis_tlast_w(s_axis_TLAST),
        .s_axis_tready(s_axis_TREADY), //output
        .s_axis_tuser_w(s_axis_TUSER),
        .s_axis_tvalid_w(s_axis_TVALID));

    initial begin

        // Release reset
        m_axis_TUSER = 0;
        s_axis_TLAST = 0;
        axis_rstn = 0;
        
        #60 axis_rstn = 1;

        // Input data
        s_axis_TDATA = {20'b0, 1111};
        s_axis_TVALID = 1'b1; //set high, ready to send data
        
        #460
        
        #20 for (integer i =0; i<5 ; i = i+1) begin
            #20 s_axis_TDATA = s_axis_TDATA + 4'b1111;
        end
        #20
        s_axis_TVALID = 1'b0; //data too UUT isn't valid anymore, s_tready should go low
        
        //output data        
        m_axis_TREADY = 1'b1;
        
        
        //wait
        #100        
        #50
        
        m_axis_TREADY = 1'b0;

        // Clean up
        #10 $finish;
    end

    //clock gen
    always #10 clk = ~clk;
    always #5 fast_clk = ~fast_clk;
endmodule