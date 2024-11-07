`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/28/2024 08:30:14 AM
// Design Name: 
// Module Name: sobel_9bit
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

//timing clock cycles needed: 3, pipelined though

module sobel #
	(
		parameter integer S_AXIS_TDATA_WIDTH	= 72,
		parameter integer M_AXIS_TDATA_WIDTH	= 8
	)
	(
		// Ports of Axi Slave Bus Interface S_AXIS
		input logic  s_axis_aclk,
		input logic  s_axis_aresetn,
		output logic  s_axis_tready,
		input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input logic [(S_AXIS_TDATA_WIDTH/8)-1 : 0] s_axis_tstrb,
		input logic  s_axis_tlast, //indicates last packet
		input logic  s_axis_tvalid,


        // Ports of Axi Master Bus Interface S_AXIS
		//output logic  m_axis_aclk, //comment out if doing procedural or sequentail work
		//output logic  m_axis_aresetn, //comment out if doing procedural or sequentail work
		input logic  m_axis_tready,
		output logic [M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
		//output logic [(M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
		output logic  m_axis_tlast, //indicates last packet
		output logic  m_axis_tvalid
	);
	//AXIS signals
	assign m_axis_tdata = mag;
	assign s_axis_tready = m_axis_tready;
	assign m_axis_tvalid = s_axis_tvalid;
	
	
	
    logic [7:0] mag;
    logic [7:0] dir;
    
    logic [10:0] Gy;
    logic [10:0] Gx;
    logic [10:0] abs_Gy;
    logic [10:0] abs_Gx;
    
    
    //Assign each pixel a point for readability
    logic [7:0] P1, P2, P3, P4, P5, P6, P7, P8, P9;
    assign P1 = s_axis_tdata[7:0];
    assign P2 = s_axis_tdata[15:8];
    assign P3 = s_axis_tdata[21:16];
    
    assign P4 = s_axis_tdata[29:22];
    assign P5 = s_axis_tdata[37:30];
    assign P6 = s_axis_tdata[45:38];
    
    assign P7 = s_axis_tdata[54:46];
    assign P8 = s_axis_tdata[62:55];
    assign P9 = s_axis_tdata[71:63];
    
   
   //following computes the appoximation of the sobel magnitude
    always @(posedge s_axis_aclk) begin
        //first half, gets ready for absolute values
        //data_abs1 <= ((P7 + (P8<<1)) + P9) + (~((P1 + (P2<<1)) + P3) + 1);
        //data_abs2 <= ((P1 + (P4<<1)) + P7) + (~((P3 + (P2<<6)) + P9) + 1);
        
        Gy <= (((P1 + (P2<<1)) + P3)) - ((P7 + (P8<<1)) + P9);
        Gx <= (((P3 + (P6<<1)) + P9)) - ((P1 + (P4<<1)) + P7);
        
        //if MSB is 0, dw
        //if MSB is 1, means it is a negative and then invert it, else do nothing
        if (Gy[10] == 1'b1)
            abs_Gy <= -Gy;
        else 
            abs_Gy <= Gy;
            
        if (Gx[10] == 1'b1)
            abs_Gx <= -Gx;
        else 
            abs_Gx <= Gx;
            
        //solve for magnitude of sobel algorithm
        //if not in reset and slave/master are ready
        if (s_axis_aresetn & m_axis_tready & s_axis_tvalid) //reset is low
            mag <= abs_Gy + abs_Gx; //overflow is okay, will be bright enough anyway
        else
            mag <= 8'b0;
    end
    
    //direction calculations
    //parameter for directions
    parameter d1 = 1;
    parameter d2 = 2;
    parameter d3 = 3;
    parameter d4 = 4;
    parameter none = 0; //if no direction
    //temp difference value 
    logic [10:0] diff;
    always @(posedge s_axis_aclk) begin
        case ({Gy[10],Gx[10]})
            2'b00: begin // Q1
                //if (Gy[10:6] > (Gx[10:6]<<1))
            end
            2'b01: begin //Q2
            end
            2'b10: begin //Q4
            end
            2'b11: begin //Q3
            end
            default: begin
                dir <= none;
            end
        endcase;

    end
endmodule

module arctan_LUT (
    
);

endmodule