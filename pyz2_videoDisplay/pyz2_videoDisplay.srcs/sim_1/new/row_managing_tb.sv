`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2024 10:44:18 AM
// Design Name: 
// Module Name: row_managing_tb
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

module row_managing_tb();
    `timescale 1ns/1ps

    // Parameters
    parameter HEIGHT = 2;
    parameter WIDTH = 2;
    parameter S_AXIS_TDATA_WIDTH = 8;
    parameter STAGES = 1;
    parameter METADATA_WIDTH = 1;
    localparam FRAME = HEIGHT * WIDTH;

    // Testbench signals
    logic rstn;
    logic clk;

    logic s_FIFO_axis_tready;
    logic [S_AXIS_TDATA_WIDTH-1:0] s_FIFO_axis_tdata;
    logic s_FIFO_axis_tvalid;
    
    logic m_axis_tready;
    logic [S_AXIS_TDATA_WIDTH-1:0] m_axis_tdata;
    logic m_axis_tvalid;

    // Instantiate the DUT (Device Under Test)
    AXIS_row_manager #(
    .HEIGHT(5),               // Set height parameter as needed
        .WIDTH(5),               // Set width parameter as needed
        .S_AXIS_TDATA_WIDTH(8),     // Data width from FIFO
        .M_AXIS_TDATA_WIDTH(8),    // Data width to BRAM
        .STAGES(1)                  // Set number of stages if applicable
    ) u_AXIS_row_manager (
    // Clock and Reset
    .clk(clk),                  // Connect clock signal
    .rstn(rstn),            // Connect active-low reset signal

    // FIFO interface
    .s_FIFO_axis_tready(s_FIFO_axis_tready),   // Connect ready signal for FIFO
    .s_FIFO_axis_tdata(s_FIFO_axis_tdata),     // Connect data input from FIFO
    .s_FIFO_axis_tvalid(s_FIFO_axis_tvalid),   // Connect valid signal from FIFO

    // AXI Stream output to Process Module
    .m_axis_tready(m_axis_tready),             // Connect ready signal from process module
    .m_axis_tdata(m_axis_tdata),               // Connect data output to process module
    .m_axis_tvalid(m_axis_tvalid)              // Connect valid signal to process module
);

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Stimulus block
    // Test stimulus
    initial begin
        // Initialize signals
        clk = 1;
        rstn = 1;
        s_FIFO_axis_tdata = 8'b0;
        m_axis_tready = 0;
        s_FIFO_axis_tvalid = 0;

        // Reset the DUT
        $display("Releasing reset...");
        #10 rstn = 0;
        #10 rstn = 1;

        // Apply some stimulus to the inputs
        $display("Writing into BRAM...");
        #10;
        s_FIFO_axis_tdata = 100;
        #10;
        s_FIFO_axis_tvalid = 1;
        #10;

        // Send some data to the prepper
        for (int i = 0; i < 6; i++) begin
            s_FIFO_axis_tdata = s_FIFO_axis_tdata + i*2;  // Send incrementing data
            #10; // Wait 10ns for the next clock edge
        end

        // Finish sending data
        s_FIFO_axis_tvalid = 0;
        #10; // Give time for the last data to propagate

        $display("Reading from BRAM...");
        m_axis_tready = 1;

        // Monitor the outputs
        $display("Simulation finished.");
        $finish;
    end

endmodule

module prepper_bram();
    `timescale 1ns/1ps

    // Parameters
    parameter HEIGHT = 2;
    parameter WIDTH = 2;
    parameter S_AXIS_TDATA_WIDTH = 8;
    parameter STAGES = 1;
    parameter METADATA_WIDTH = 1;
    localparam FRAME = HEIGHT * WIDTH;

    // Testbench signals
    logic rstn;
    logic clk;
    logic [S_AXIS_TDATA_WIDTH-1 : 0] dina;
    logic [$clog2(FRAME)-1 : 0] addra;
    logic ena;

    logic s_axis_tready;
    logic [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata;
    logic s_axis_tvalid;
    
    logic frame_done;
    logic overwrite;
    logic row_done;

    // Instantiate the DUT (Device Under Test)
    // Instantiate the Prepper module
    Prepper #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),
        .STAGES(STAGES),
        .METADATA_WIDTH(METADATA_WIDTH)
    ) prepper_inst (
        .s_axis_aclk(clk),
        .s_axis_aresetn(rstn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .dina(dina),
        .addra(addra),
        .ena(ena),
        .frame_done(frame_done),
        .en(overwrite),
        .row_done(row_done)
    );

    BRAM #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),
        .STAGES(STAGES),
        .METADATA_WIDTH(METADATA_WIDTH)
    ) u_BRAM (
        .rstn(rstn),
        .clk(clk),
        .dina(dina),
        .addra(addra),
        .ena(ena),
        .doutb(doutb),
        .addrb(addrb),
        .enb(enb)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Stimulus block
    // Test stimulus
    initial begin
        // Initialize signals
        clk = 1;
        rstn = 1;
        s_axis_tdata = 8'b0;
        s_axis_tvalid = 0;
        overwrite = 0;

        // Reset the DUT
        $display("Releasing reset...");
        #10 rstn = 0;
        #10 rstn = 1;

        // Apply some stimulus to the inputs
        $display("Starting stimulus...");
        #10;
        s_axis_tdata = 100;
        #10;
        overwrite = 1;
        #10;

        // Send some data to the prepper
        for (int i = 0; i < 6; i++) begin
            s_axis_tdata = i;  // Send incrementing data
            s_axis_tvalid = 1;
            #10; // Wait 10ns for the next clock edge
        end

        // Finish sending data
        s_axis_tvalid = 0;
        #20; // Give time for the last data to propagate

        

        // Monitor the outputs
        $display("Simulation finished.");
        $finish;
    end

endmodule

module prepper_tb();

    // Parameters for the testbench
    parameter integer HEIGHT = 2;
    parameter integer WIDTH = 2;
    parameter integer S_AXIS_TDATA_WIDTH = 8; // FIFO to BRAM
    parameter integer STAGES = 1;
    parameter integer METADATA_WIDTH = 1;

    // Testbench signals
    logic s_axis_aclk;
    logic s_axis_aresetn;

    logic s_axis_tready;
    logic [S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata;
    logic s_axis_tvalid;

    logic [S_AXIS_TDATA_WIDTH-1:0] dina;
    logic [$clog2(HEIGHT*WIDTH+METADATA_WIDTH)-1:0] addra;
    logic wea;

    logic frame_done;
    logic overwrite;
    logic row_done;

    // Clock generation
    always #5 s_axis_aclk = ~s_axis_aclk; // Clock period of 10ns

    // Instantiate the Prepper module
    Prepper #(
        .HEIGHT(HEIGHT),
        .WIDTH(WIDTH),
        .S_AXIS_TDATA_WIDTH(S_AXIS_TDATA_WIDTH),
        .STAGES(STAGES),
        .METADATA_WIDTH(METADATA_WIDTH)
    ) prepper_inst (
        .s_axis_aclk(s_axis_aclk),
        .s_axis_aresetn(s_axis_aresetn),
        .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .dina(dina),
        .addra(addra),
        .wea(wea),
        .frame_done(frame_done),
        .en(overwrite),
        .row_done(row_done)
    );

    // Test stimulus
    initial begin
        // Initialize signals
        s_axis_aclk = 1;
        s_axis_aresetn = 1;
        s_axis_tdata = 8'b0;
        s_axis_tvalid = 0;
        overwrite = 0;

        // Reset the DUT
        $display("Releasing reset...");
        #10 s_axis_aresetn = 0;
        #10 s_axis_aresetn = 1;

        // Apply some stimulus to the inputs
        $display("Starting stimulus...");
        #10;
        s_axis_tdata = 100;
        #10;
        overwrite = 1;
        #10;

        // Send some data to the prepper
        for (int i = 0; i < 2; i++) begin
            s_axis_tdata = i;  // Send incrementing data
            s_axis_tvalid = 1;
            #10; // Wait 10ns for the next clock edge
        end
        
        // Test overwrite control signal
        overwrite = 0;
        #20;
        overwrite = 1;
        for (int i = 0; i < 3; i++) begin
            s_axis_tdata = i;  // Send incrementing data
            #10; // Wait 10ns for the next clock edge
        end

        // Finish sending data
        s_axis_tvalid = 0;
        #20; // Give time for the last data to propagate

        

        // Monitor the outputs
        $display("Simulation finished.");
        $finish;
    end

    // Optional: Monitor the signals
    initial begin
        $monitor("Time: %0t, s_axis_tready: %b, s_axis_tdata: %h, dina: %h, addra: %h, wea: %b, frame_done: %b, overwrite: %b", 
                 $time, s_axis_tready, s_axis_tdata, dina, addra, wea, frame_done, overwrite);
    end

endmodule
