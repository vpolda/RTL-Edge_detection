`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/02/2024 11:31:45 AM
// Design Name: 
// Module Name: axis_edge_detection
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 

//This is the crawl stage of development
//This design passes the HDMI RGB data through to the FIFO Buffers in different clock domains
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//timing
// need less than 16.67ms

module axis_edge_detection_passthrough_wSOF(
  //Clocks
  input fast_clk,
  input pix_clk,
  
  //resets
  input axis_rstn,
  
  //slave
  //All inputs are registered beside M tready
  input [23:0] s_axis_tdata_w,
  output s_axis_tready_w, //direct wire for timing
  input s_axis_tvalid_w,
  input s_axis_tlast_w, //end of line
  input s_axis_tuser_w, //start of frame
  
  //master
  //All outputs are registered beside s tready
  output reg [23:0] m_axis_tdata,
  input m_axis_tready, //direct wire for timing
  output reg m_axis_tvalid,
  output reg m_axis_tlast,
  output reg m_axis_tuser
  
    );
  //parameters
    parameter HEIGHT = 720;
    parameter WIDTH = 1280;
    
    //Stages 
    //this determines if the outputted data modifcation needs to be passed back
    //and go through addional modifcations like bluring, etc
    //0 stages if just buffer pass through
    //1 if one pixel modification stage
      //0 sobel, blur etc etc
      //1 pass out
    parameter STAGES = 0; 

  //SOF
    //registers inputs and looks for first frame, otherwise will send blank frame out
    wire blank_period_s;

    wire [23:0] s_axis_tdata;
    wire s_axis_tvalid, s_axis_tlast, s_axis_tuser;

    SOF sof_inst (
      .clk         (pix_clk),         // Connect pixel clock
      .rstn       (axis_rstn),       // Connect active-low reset

      // Slave interface
      .s_axis_tdata_w  (s_axis_tdata_w),  // Connect input data
      .s_axis_tvalid_w (s_axis_tvalid_w), // Connect input valid signal
      .s_axis_tlast_w  (s_axis_tlast_w),  // Connect end of line
      .s_axis_tuser_w  (s_axis_tuser_w),  // Connect user signal (start of frame)

      // Outputs to drive rest of processing
      .s_axis_tdata    (s_axis_tdata),    // Output data
      .s_axis_tvalid   (s_axis_tvalid),   // Output valid signal
      .s_axis_tlast    (s_axis_tlast),    // Output end of line
      .s_axis_tuser    (s_axis_tuser),    // Output user signal (start of frame)

      // Blank period control signal
      .blank_period_s  (blank_period_s)   // Indicates blanking period
    );

  //RGB2Grey
      wire [7:0] data_grey;
      //convert incoming data to rbg
      rgb2grey rgb2grey_inst1 (
          .data_in(s_axis_tdata),
          .data_out(data_grey) //not registered, purely combo
      );

  //First FIFO
    //Changes clock speed to higher frequency

    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(3),            // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
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
      .m_aclk(fast_clk),                         // 1-bit input: Master Interface Clock: All signals on master
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
      .s_axis_tdata(data_grey),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.  
      .s_axis_tlast(s_axis_tlast),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tuser(s_axis_tuser),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(s_axis_tvalid),            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .s_axis_tready(s_axis_tready)           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
    );
    //FIFO 2 FIFO
    wire [7:0] FIFO_tdata;
    wire FIFO_tready;
    wire FIFO_tvalid;
    wire FIFO_tuser;
    wire FIFO_tlast;

  //FIFO3
    
    //for clock domain change
    //Changes clock speed to pixl clock
    //a small buffer
    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(3),            // DECIMAL
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(2048),              // DECIMAL
      .FIFO_MEMORY_TYPE("auto"),      // String
      .PACKET_FIFO("false"),          // String
      .PROG_EMPTY_THRESH(10),         // DECIMAL
      .PROG_FULL_THRESH(10),          // DECIMAL
      .RD_DATA_COUNT_WIDTH(1),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(8),               // DECIMAL
      .TDEST_WIDTH(1),                // DECIMAL
      .TID_WIDTH(1),                  // DECIMAL
      .TUSER_WIDTH(1),                // DECIMAL
      .USE_ADV_FEATURES("1000"),      // String
      .WR_DATA_COUNT_WIDTH(1)         // DECIMAL
    )
    xpm_fifo_axis_inst3 (
     //empty/full 
      .almost_empty_axis(),   // 1-bit output: Almost Empty : When asserted, this signal
                                               // indicates that only one more read can be performed before the
                                               // FIFO goes to empty.

      .almost_full_axis(),     // 1-bit output: Almost Full: When asserted, this signal
                                               // indicates that only one more write can be performed before
     //master                                          // the FIFO is full.
      .m_axis_tdata(m_axis_tdata_w),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.
      
      .m_axis_tlast(m_axis_tlast_w),             // 1-bit output: TLAST: Indicates the boundary of a packet.

      .m_axis_tuser(m_axis_tuser_w),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(m_axis_tvalid_w),           // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .m_aclk(pix_clk),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(m_axis_tready),           // 1-bit input: TREADY: Indicates that the slave can accept a
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
                                               // full threshold value..

     //slave ports
      //removed for axis interface
      .s_aclk(fast_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
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

  //Register outputs
  wire [7:0] m_axis_tdata_w;
  wire m_axis_tvalid_w;
  wire m_axis_tuser_w;
  wire m_axis_tlast_w;


  //concat output of sobel with 3*
    //since only grey, convert to RGB
    //reg [23:0] m_axis_tdata_FIFO3;
   always @(posedge pix_clk) 
      if (!axis_rstn) begin
        m_axis_tdata <= 24'b0;
        m_axis_tvalid <= 0;
        m_axis_tuser <= 0;
        m_axis_tlast <= 0;

      end else if (blank_period_s) begin //if blank is high, output blank data and passthrough others
      //This needs to be at the beginning of the design
        m_axis_tdata <= {8'b0, 8'hFF, 8'b0};
        m_axis_tvalid <= s_axis_tvalid;
        m_axis_tuser <= s_axis_tuser;
        m_axis_tlast <= s_axis_tlast;

      end else begin //otherwise, get data from design
        m_axis_tdata <= {m_axis_tdata_w,m_axis_tdata_w,m_axis_tdata_w};
        m_axis_tvalid <= m_axis_tvalid_w;
        m_axis_tuser <= m_axis_tuser_w;
        m_axis_tlast <= m_axis_tlast_w;
      end
        
    //tready combinational for fast
    wire s_axis_tready; //this comes from FIFO1
    assign s_axis_tready_w =  s_axis_tready;

  
endmodule
