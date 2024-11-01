`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2024 01:44:37 PM
// Design Name: 
// Module Name: deserailizer
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


module deserializer (
    input logic clk,
    input logic rstn, //hold in reset
    
    input logic FIFO_empty,
    
    input logic [IN_BITS-1:0] serial_in,
    
    output logic FIFO_rd_en,
    
    output logic [(IN_BITS*OUT_SIZE)-1:0] parallel_out,
    output logic data_valid //HIGH for one cycle. this can also act as an output to the sender to stop if flag is implemented
);
    parameter IN_BITS = 8;
    parameter OUT_SIZE = 1280; //setting default to what i need cause im lazy

    integer cnt; 
    logic [(IN_BITS*OUT_SIZE)-1:0] shift_reg;

    assign parallel_out = shift_reg;

    always @(posedge clk) begin
        
        if (!rstn) begin
            shift_reg <= {IN_BITS*OUT_SIZE{1'b0}};
            cnt <= 0;
            data_valid <= 0;
            FIFO_rd_en <= 0;
            //parallel_out <= {IN_BITS*OUT_SIZE{1'b0}};
        end else if (FIFO_empty) begin
            data_valid <= 0;
            shift_reg <= shift_reg;
            FIFO_rd_en <= 0;
        end else begin
            //shifts in new on the left, old on the right
            FIFO_rd_en <= 0;
            shift_reg <= {serial_in, shift_reg[ (IN_BITS*OUT_SIZE)-1: IN_BITS]};  // Shift in the new bit
            cnt <= cnt + 1;
            if (cnt == OUT_SIZE) begin
                //parallel_out <= shift_reg;
                data_valid <= 1;
                cnt <= 0;
            end else begin
                data_valid <= 0;
            end
        end
    end
endmodule
