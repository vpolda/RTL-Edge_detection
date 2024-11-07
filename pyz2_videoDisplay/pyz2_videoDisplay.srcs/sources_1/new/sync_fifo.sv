`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2024 05:12:07 PM
// Design Name: 
// Module Name: sync_fifo
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

//from: https://www.chipverify.com/verilog/synchronous-fifo
module sync_fifo #(parameter DEPTH=8, DWIDTH=32)
(
    input               	rstn,               // Active low reset
                            clk,                // Clock
                            wr_en, 				// Write enable
                            rd_en, 				// Read enable
    input      [DWIDTH-1:0] din, 				// Data written into FIFO
    output reg [DWIDTH-1:0] dout, 				// Data read from FIFO
    output              	empty, 				// FIFO is empty when high
                            full 				// FIFO is full when high
);


  reg [$clog2(DEPTH)-1:0]   wptr;
  reg [$clog2(DEPTH)-1:0]   rptr;

  reg [DWIDTH-1 : 0]    fifo[DEPTH];

  always @ (posedge clk) begin
    if (!rstn) begin
      wptr <= 0;
    end else begin
      if (wr_en & !full) begin
        fifo[wptr] <= din;
        wptr <= wptr + 1;
      end
    end
  end

  always @ (posedge clk) begin
    if (!rstn) begin
      rptr <= 0;
    end else begin
      if (rd_en & !empty) begin
        dout <= fifo[rptr];
        rptr <= rptr + 1;
      end
    end
  end

  assign full  = (wptr + 1) == rptr;
  assign empty = wptr == rptr;
endmodule
