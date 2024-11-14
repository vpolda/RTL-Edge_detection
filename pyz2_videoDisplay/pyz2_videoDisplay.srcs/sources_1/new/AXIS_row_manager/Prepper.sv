`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2024 05:19:01 AM
// Design Name: 
// Module Name: AXIS_row_manager
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

module prepper # (
    parameter integer HEIGHT = 720,
    parameter integer WIDTH	= 1280,

    parameter integer S_AXIS_TDATA_WIDTH = 8, //From FIFO to BRAM
    parameter integer STAGES = 1

    //parameter integer METADATA_WIDTH = 1 //extra room for whatever

 ) (

    //slave - FIFO
    input logic  s_axis_aclk,
    input logic  s_axis_aresetn,
    
    output logic  s_axis_tready, //need to go low when whole frame is full
    input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
    input logic  s_axis_tvalid,

    //master - BRAM
    output logic [S_AXIS_TDATA_WIDTH-1 : 0] dina,
    output logic [$clog2(FRAME)-1 : 0] addra,
    output logic ena,

    //oversight_manager
    //controls if prepper starts to over write BRAM with new frame
    output logic frame_done,
    output logic row_done,
    input logic en //if high, means can overwrite data
    );

    localparam FRAME = HEIGHT*WIDTH + METADATA_WIDTH;
    localparam METADATA_WIDTH = $clog2(STAGES+1);

    //NEED TO ADD
    //padding
    //frame_started
    //stage = 0

    //while FIFO is ready
    always @(posedge s_axis_aclk) begin
        //but first, reset
        if (!s_axis_aresetn) begin
            addra <= METADATA_WIDTH;
            dina <= 0;
            ena <= 0;

            frame_done <= 0;
            row_done <= 0;

            s_axis_tready <= 0;

        //if slave serial is valid and not full frame
        end else if (s_axis_tvalid & (addra < FRAME - 1) & en) begin
            //write into BRAM
            dina <= s_axis_tdata; //read in in same clock cycle
            addra <= addra + 1'b1; //shift one bit
            ena <= 1;

            //oversight stuff
            frame_done <= 0;
            if ((addra - METADATA_WIDTH) % WIDTH == 0) row_done <= 1;
            else row_done <= 0;
            
            s_axis_tready <= 1; //ready to accept data

        //if frame is done
        end else if (addra == FRAME - 1) begin //let it reach last frame
            s_axis_tready <= 0; //not ready for more data

            //alert frame is done
            frame_done <= 1;
            row_done <= 0;

            ena <= 0;
            addra <= METADATA_WIDTH; //reset

        //otherwise chill daddy chill
        end else begin
            addra <= addra;
            dina <= dina;
            ena <= 0;

            s_axis_tready <= 0; //asume not ready

            frame_done <= frame_done;
            row_done <= row_done;
        end

    end
    //get data
    //write in
    //alert Oversight rows done
    //accept en permission from oversight

endmodule