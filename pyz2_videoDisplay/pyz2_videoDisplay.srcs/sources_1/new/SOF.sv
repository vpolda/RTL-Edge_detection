`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2024 09:00:17 AM
// Design Name: 
// Module Name: SOF
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


module SOF(
    input pix_clk,
    input axis_rstn,
    
    //slave
    input [23:0] s_axis_tdata_w,
    input s_axis_tvalid_w,
    input s_axis_tlast_w, //end of line
    input s_axis_tuser_w,

    output reg [23:0] s_axis_tdata,
    output reg s_axis_tvalid,
    output reg s_axis_tlast,
    output reg s_axis_tuser,

    output logic blank_period_s //if high, means will send only blank pixels out, used to control output mux

    );

    //registers all inputs and outputs
    //waits till tuser goes high to indicate start of frame SOF
    
    reg wait_frame_state_n; //active low state
    assign blank_period_s = wait_frame_state_n;

    //watch for tuser going high, means start of frame
    always @(posedge s_axis_tuser) begin
        if (axis_rstn) begin
            wait_frame_state_n = 1;
        end else if (s_axis_tuser) begin
            wait_frame_state_n = 0;
        end
    end
    
    always @(posedge pix_clk) begin
      //reset
        if (!axis_rstn) begin
            s_axis_tdata <= 24'b0;
            s_axis_tvalid <= 1'b0;
            s_axis_tlast <= 1'b0;
            s_axis_tuser <= 1'b0;
            
        end else if (wait_frame_state_n) begin //if high, means found frame, start data
            s_axis_tdata <= s_axis_tdata_w;
            s_axis_tvalid <= s_axis_tvalid_w;
            s_axis_tlast <= s_axis_tlast_w;
            s_axis_tuser <= s_axis_tuser_w;
        end else begin //if low, means waiting still. Tell FIFO not ready but keep output s_ready_w untouched
            //since we want data to continue to come in until frame found. Output will be blanks
            s_axis_tdata <= s_axis_tdata_w;
            s_axis_tvalid <= 1'b0;
            s_axis_tlast <= s_axis_tlast_w;
            s_axis_tuser <= s_axis_tuser_w;
        end
    end

endmodule

/*
//register all inputs
    reg [23:0] s_axis_tdata;
    reg s_axis_tvalid;
    reg s_axis_tlast;
    reg s_axis_tuser;
    //reg m_axis_tready;
    
    
    always @(posedge pix_clk) begin
      //reset
        if (!axis_rstn) begin
            s_axis_tdata <= 24'b0;
            s_axis_tvalid <= 1'b0;
            s_axis_tlast <= 1'b0;
            s_axis_tuser <= 1'b0;
            
            //m_axis_tready <= 1'b0;
        end else begin
            s_axis_tdata <= s_axis_tdata_w;
            s_axis_tvalid <= s_axis_tvalid_w;
            s_axis_tlast <= s_axis_tlast_w;
            s_axis_tuser <= s_axis_tuser_w;
            
            //m_axis_tready <= m_axis_tready_w;
        end
    end
 
  //Wait till start of frame
    //if needed could drop frames here!

    //active low state
    reg wait_frame_state_n;
    wire FIFO1_in_tvalid; //wire since because waiting on wait_frame_state_n in always

    //tell fifo not ready until SOF
    //tbh i think i need to get rid of this because of VTC
   //OUTPUT 0s instead!!!
    assign FIFO1_in_tvalid = s_axis_tvalid & wait_frame_state_n;

    //wait till start of frame (TUSR) to do ANYTHING, or on reset
    always @(posedge pix_clk) begin
      //if reset, wait for frame again
      if (!axis_rstn)
        wait_frame_state_n <= 0;
      //if start of frame, exit wait state
      else if (s_axis_tuser) 
        wait_frame_state_n <= 1;
    end
    */