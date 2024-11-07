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


module AXIS_FIFO_tb(
    );

    
    logic pix_clk = 1;
    logic fast_clk = 1;
    logic axis_rstn = 1;
    
   // Master
    logic [7:0] m_axis_TDATA;
    logic m_axis_TLAST;
    logic m_axis_TREADY = 0; //input to DUT
    logic m_axis_TUSER;
    
    logic m_axis_TVALID;

   //Slave
    logic [7:0] s_axis_TDATA = 8'b0;
    logic s_axis_TLAST = 0;

    logic s_axis_TREADY; //output from DUT
        
    logic s_axis_TUSER;
    logic s_axis_TVALID = 0;

    //DUT

   //First FIFO
    //Changes clock speed to higher frequency 

    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(2048),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(10),         // DECIMAL
      .PROG_FULL_THRESH(10),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(1),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(8),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("1000"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
    )
    xpm_fifo_axis_inst1 (
     //empty/full 
      .almost_empty_axis(),   // 1-bit output: Almost Empty : When asserted, this signal
                                               // indicates that only one more read can be performed before the
                                               // FIFO goes to empty.

      .almost_full_axis(),     // 1-bit output: Almost Full: When asserted, this signal
                                               // indicates that only one more write can be performed before
     //master                                          // the FIFO is full.
      .m_axis_tdata(FIFO_tdata),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.
      .m_axis_tlast(FIFO_tlast),             // 1-bit output: TLAST: Indicates the boundary of a packet.

      .m_axis_tuser(FIFO_tuser),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(FIFO_tvalid),           // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .m_aclk(pix_clk),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(FIFO_tready),           // 1-bit input: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
                                            
     //programmable empty/full
      //.prog_empty_axis(),       // 1-bit output: Programmable Empty- This signal is asserted
                                               // when the number of words in the FIFO is less than or equal to
                                               // the programmable empty threshold value. It is de-asserted
                                               // when the number of words in the FIFO exceeds the programmable
                                               // empty threshold value.

      //.prog_full_axis(),         // 1-bit output: Programmable Full: This signal is asserted when
                                               // the number of words in the FIFO is greater than or equal to
                                               // the programmable full threshold value. It is de-asserted when
                                               // the number of words in the FIFO is less than the programmable
                                               // full threshold value.
                                        
      //.wr_data_count_axis(wr_data_count_axis), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
                                               // indicates the number of words written into the FIFO.

     //slave ports
      .s_aclk(pix_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                               // interface are sampled on the rising edge of this clock.

      .s_aresetn(axis_rstn),                   // 1-bit input: Active low asynchronous reset.
      .s_axis_tdata(s_axis_TDATA),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.  
      .s_axis_tlast(s_axis_TLAST),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tuser(s_axis_TUSER),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(s_axis_TVALID),            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .s_axis_tready(s_axis_TREADY)           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
    );

logic [7:0] FIFO_tdata;
logic FIFO_tready;
logic FIFO_tvalid;
logic FIFO_tuser;
logic FIFO_tlast;

//second FIFO
    //Changes clock speed to higher frequency 

    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(2048),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(10),         // DECIMAL
      .PROG_FULL_THRESH(10),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(1),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(8),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("1000"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
    )
    xpm_fifo_axis_inst2 (
     //empty/full 
      .almost_empty_axis(),   // 1-bit output: Almost Empty : When asserted, this signal
                                               // indicates that only one more read can be performed before the
                                               // FIFO goes to empty.

      .almost_full_axis(),     // 1-bit output: Almost Full: When asserted, this signal
                                               // indicates that only one more write can be performed before
     //master                                          // the FIFO is full.
      .m_axis_tdata(m_axis_TDATA),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.
      .m_axis_tlast(m_axis_TLAST),             // 1-bit output: TLAST: Indicates the boundary of a packet.

      .m_axis_tuser(m_axis_TUSER),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(m_axis_TVALID),           // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .m_aclk(pix_clk),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(m_axis_TREADY),           // 1-bit input: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
                                            
     //programmable empty/full
      //.prog_empty_axis(),       // 1-bit output: Programmable Empty- This signal is asserted
                                               // when the number of words in the FIFO is less than or equal to
                                               // the programmable empty threshold value. It is de-asserted
                                               // when the number of words in the FIFO exceeds the programmable
                                               // empty threshold value.

      //.prog_full_axis(),         // 1-bit output: Programmable Full: This signal is asserted when
                                               // the number of words in the FIFO is greater than or equal to
                                               // the programmable full threshold value. It is de-asserted when
                                               // the number of words in the FIFO is less than the programmable
                                               // full threshold value.
                                        
      //.wr_data_count_axis(wr_data_count_axis), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
                                               // indicates the number of words written into the FIFO.

     //slave ports
      .s_aclk(pix_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                               // interface are sampled on the rising edge of this clock.

      .s_aresetn(axis_rstn),                   // 1-bit input: Active low asynchronous reset.
      .s_axis_tdata(FIFO_tdata),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.  
      .s_axis_tlast(FIFO_tlast),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tuser(FIFO_tuser),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(FIFO_tvalid),            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .s_axis_tready(FIFO_tready)           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
    );

initial begin

        // Release reset
        s_axis_TUSER = 0;
        s_axis_TLAST = 0;
        axis_rstn = 0;
        
        #80 axis_rstn = 1;

        // Input data
        s_axis_TDATA = {8{1'b0}};
        s_axis_TVALID = 1'b1; //set high, ready to send data
        

        #20 for (integer i =0; i<5 ; i = i+1) begin
            #20 s_axis_TDATA = s_axis_TDATA + 2'b11;
        end
        #20
        s_axis_TVALID = 1'b0; //data too UUT isn't valid anymore, s_tready should go low
        
        //output data
        m_axis_TREADY = 1'b1;
        
        #100
        
        #50
        
        m_axis_TREADY = 1'b0;

        // Clean up
        #10 $finish;
    end

    //clock gen
    always #10 pix_clk = ~pix_clk;
    always #5 fast_clk = ~fast_clk;
endmodule