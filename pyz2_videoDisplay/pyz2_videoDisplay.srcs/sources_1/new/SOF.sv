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
    input clk,
    input rstn,
    
    //slave
    input logic [23:0] s_axis_tdata_w,
    input logic s_axis_tvalid_w,
    input logic s_axis_tlast_w, //end of line
    input logic s_axis_tuser_w,

    output logic [23:0] s_axis_tdata,
    output logic s_axis_tvalid,
    output logic s_axis_tlast,
    output logic s_axis_tuser,

    output logic blank_period_s //if high, means will send only blank pixels out, used to control output mux

    );

    //logicisters all inputs and outputs
    //waits till tuser goes high to indicate start of frame SOF
    //Does not release until reset
    always @(posedge clk) begin

        if (!rstn) begin
            blank_period_s <= 1;
        end else if (s_axis_tuser) begin
            blank_period_s <= 0;
        end
    end
    
    always @(posedge clk) begin
      //reset
        if (!rstn) begin
            s_axis_tdata <= 24'b0;
            s_axis_tvalid <= 1'b0;
            s_axis_tlast <= 1'b0;
            s_axis_tuser <= 1'b0;
            
        end else if (!blank_period_s) begin //if high, means found frame, start data
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
