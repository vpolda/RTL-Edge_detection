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


module sobel_9bytet(
    input [71:0] data_in,
    input clk,
    
    output reg [7:0] mag,
    output reg [7:0] dir
    );
    
    reg [10:0] Gy;
    reg [10:0] Gx;
    reg [10:0] abs_Gy;
    reg [10:0] abs_Gx;
    
    //Assign each pixel a point for readability
    wire [7:0] P1, P2, P3, P4, P5, P6, P7, P8, P9;
    assign P1 = data_in[7:0];
    assign P2 = data_in[15:8];
    assign P3 = data_in[21:16];
    
    assign P4 = data_in[29:22];
    assign P5 = data_in[37:30];
    assign P6 = data_in[45:38];
    
    assign P7 = data_in[54:46];
    assign P8 = data_in[62:55];
    assign P9 = data_in[71:63];
   
   //following computes the appoximation of the sobel magnitude
    always @(posedge clk) begin
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
        mag <= abs_Gy + abs_Gx; //overflow is okay, will be bright enough anyway
    end
    
    //direction calculations
    //parameter for directions
    parameter d1 = 1;
    parameter d2 = 2;
    parameter d3 = 3;
    parameter d4 = 4;
    parameter none = 0; //if no direction
    //temp difference value 
    reg [10:0] diff;
    always @(posedge clk) begin
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