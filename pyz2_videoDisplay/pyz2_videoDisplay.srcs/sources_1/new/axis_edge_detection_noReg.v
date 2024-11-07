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

module axis_edge_detection(
  //Clocks
  input MHz400_clk,
  input pix_clk,
  
  //resets
  input axis_rstn,
  
  //slave
  input [23:0] s_axis_tdata,
  output s_axis_tready,
  input s_axis_tvalid,
  input s_axis_tlast, //end of line
  input s_axis_tuser, //start of frame
  
  //master
  output [23:0] m_axis_tdata,
  input m_axis_tready,
  output m_axis_tvalid,
  output m_axis_tlast,
  output m_axis_tuser
  
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


  //RGB2Grey
    wire [7:0] data_grey;
    //convert incoming data to rbg
    rgb2grey rgb2grey_inst1 (
        .data_in(s_axis_tdata),
        .data_out(data_grey)
    );
    
  //Wait till start of frame
    //if needed could drop frames here!
    //Pipeline
    reg [7:0] FIFO1_in_tdata;
    reg FIFO1_in_tlast; //end of line
    reg FIFO1_in_tuser;
    
    //reg FIFO1_in_tready;
    //assign s_axis_tready = FIFO1_in_tready;

    wire FIFO1_in_tvalid; //wire since because waiting on wait_frame_state_n in always

   //non-tvalid
    always @(posedge pix_clk) begin
      FIFO1_in_tdata <= data_grey;
      FIFO1_in_tlast <= s_axis_tlast; //end of line
      FIFO1_in_tuser <= s_axis_tuser;

    end

    //active low state
    reg wait_frame_state_n;

   //tvalid
    //tell fifo not ready
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

  //First FIFO
    //Changes clock speed to higher frequency 

    wire [7:0] FIFO1_out_tdata;
    wire FIFO1_out_tvalid;
    wire FIFO1_out_tready;

    wire FIFO1_out_tlast;
    wire FIFO1_out_tuser;

    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
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
      .m_axis_tdata(FIFO1_out_tdata),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.
      .m_axis_tlast(FIFO1_out_tlast),             // 1-bit output: TLAST: Indicates the boundary of a packet.

      .m_axis_tuser(FIFO1_out_tuser),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(FIFO1_out_tvalid),           // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .m_aclk(MHz400_clk),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(FIFO1_out_tready),           // 1-bit input: TREADY: Indicates that the slave can accept a
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
      .s_axis_tdata(FIFO1_in_tdata),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.  
      .s_axis_tlast(FIFO1_in_tlast),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tuser(FIFO1_in_tuser),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(FIFO1_in_tvalid),            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .s_axis_tready(s_axis_tready)           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
    );
/* ignore for CRAWL
  //Deserializing  

    //first deserializer that outputs 320*8 bits from FIFO 8 bit output
      wire deser_1_to_2_tready;
      wire [71:0] deser_1_to_2_tdata;
      wire deser_1_to_2_tvalid;

      wire deser_1_to_2_tlast;
      wire deser_1_to_2_tuser;

      AXIS_S2M_deserializer #(
            .S_AXIS_TDATA_WIDTH(8),
            .M_AXIS_TDATA_WIDTH(72)
      ) deserializer_inst1 (
            // S_AXIS Ports
            .s_axis_aclk(MHz400_clk),
            .s_axis_aresetn(axis_rstn),
            .s_axis_tready(FIFO1_out_tready),
            .s_axis_tdata(FIFO1_out_tdata),
            .s_axis_tvalid(FIFO1_out_tvalid),

            // M_AXIS Ports
            .m_axis_tready(deser_1_to_2_tready),
            .m_axis_tdata(deser_1_to_2_tdata),
            .m_axis_tvalid(deser_1_to_2_tvalid)
        );  

    //second deserializer that outputs 320*8 bits from FIFO 8 bit output
      wire deser2_m_tready;
      wire [359:0] deser2_m_tdata;
      wire deser2_m_tvalid;
      
      AXIS_S2M_deserializer #(
            .S_AXIS_TDATA_WIDTH(72),
            .M_AXIS_TDATA_WIDTH(360)
      ) deserializer_inst2 (
            // S_AXIS Ports
            .s_axis_aclk(MHz400_clk),
            .s_axis_aresetn(axis_rstn),
            .s_axis_tready(deser_1_to_2_tready),
            .s_axis_tdata(deser_1_to_2_tdata),
            .s_axis_tvalid(deser_1_to_2S_tvalid),

            // M_AXIS Ports
            .m_axis_tready(deser2_m_tready),
            .m_axis_tdata(deser2_m_tdata),
            .m_axis_tvalid(deser2_m_tvalid)
        );


  //Row manager
    //Row buffer and storage for kernal_shifter
    AXIS_row_manger #(
      .stages(STAGES)
    ) row_manger(

    );

  //kernel shifter 0
    //stage > 0
    kernal_shifter kernal_shifter (
          .clk(MHz400_clk),
          .rstn(rstn),
          .s_axis_tready(s_axis_tready),
          .data_valid(data_valid),
          .row(row),
          .pixels_out(pixels_out),
          .pixel_data_valid_out(pixel_data_valid_out)
      );

  //Sobel edge detection
    sobel sobel_inst (
      .s_axis_aclk(),
      .s_axis_aresetn(),
      .s_axis_tready(),
      .s_axis_tdata(),
      .s_axis_tstrb(),
      .s_axis_tlast(),
      .s_axis_tvalid(),

      // Ports of Axi Master Bus Interface S_AXIS
      // .m_axis_aclk(),
      // .m_axis_aresetn(), 
      .m_axis_tready(),
      .m_axis_tdata(),
      // .m_axis_tstrb(),
      .m_axis_tlast(),
      .m_axis_tvalid()
    );

  //FIFO2
      //
      wire [7:0] FIFO2_out;
      //Changes clock speed to higher frequency 

      // xpm_fifo_axis: AXI Stream FIFO
      // Xilinx Parameterized Macro, version 2023.1

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
        .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .TDATA_WIDTH(1),               // DECIMAL
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
        .m_axis_tdata(FIFO2_out),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                                // used to provide the data that is passing across the
                                                // interface. The width of the data payload is an integer number
                                                // of bytes.
        
        .m_axis_tlast(),             // 1-bit output: TLAST: Indicates the boundary of a packet.

        .m_axis_tuser(),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                                // information that can be transmitted alongside the data
                                                // stream.

        .m_axis_tvalid(),           // 1-bit output: TVALID: Indicates that the master is driving a
                                                // valid transfer. A transfer takes place when both TVALID and
                                                // TREADY are asserted
        .m_aclk(MHz400_clk),                         // 1-bit input: Master Interface Clock: All signals on master
                                                // interface are sampled on the rising edge of this clock.

        .m_axis_tready(),           // 1-bit input: TREADY: Indicates that the slave can accept a
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
        .s_aclk(MHz400_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                                // interface are sampled on the rising edge of this clock.

        .s_aresetn(),                   // 1-bit input: Active low asynchronous reset.
        .s_axis_tdata(),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                                // used to provide the data that is passing across the
                                                // interface. The width of the data payload is an integer number
                                                // of bytes.  
        .s_axis_tlast(),             // 1-bit input: TLAST: Indicates the boundary of a packet.
        .s_axis_tuser(),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                                // information that can be transmitted alongside the data
                                                // stream.

        .s_axis_tvalid(),            // 1-bit input: TVALID: Indicates that the master is driving a
                                                // valid transfer. A transfer takes place when both TVALID and
                                                // TREADY are asserted
        .s_axis_tready()           // 1-bit output: TREADY: Indicates that the slave can accept a
                                                // transfer in the current cycle.
      );

  //FIFO2 arbiter
    //this controls if the pixel data is routed back to continue processing or routed out to display
    //connects to FIFO3 and row manager
    FIFO2_arbiter #(
    
    ) arbiter_inst1 (
    
    );
*/
  //FIFO3
    
    //for clock domain change
    wire [7:0] FIFO3_out;
    //Changes clock speed to pixl clock
    //a small buffer

    // for crawl, connects from serializer


    xpm_fifo_axis #(
      .CASCADE_HEIGHT(0),             // DECIMAL
      .CDC_SYNC_STAGES(2),            // DECIMAL
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
      .m_axis_tdata(FIFO3_out),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.
      
      .m_axis_tlast(m_axis_tlast),             // 1-bit output: TLAST: Indicates the boundary of a packet.

      .m_axis_tuser(m_axis_tuser),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(m_axis_tvalid),           // 1-bit output: TVALID: Indicates that the master is driving a
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
      .s_aclk(MHz400_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                               // interface are sampled on the rising edge of this clock.

      .s_aresetn(axis_rstn),                   // 1-bit input: Active low asynchronous reset.
      .s_axis_tdata(FIFO1_out_tdata),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.  
      .s_axis_tlast(FIFO1_out_tlast),             // 1-bit input: TLAST: Indicates the boundary of a packet.
      .s_axis_tuser(FIFO1_out_tuser),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(FIFO1_out_tvalid),            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted
      .s_axis_tready(FIFO1_out_tready)           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.
    );


  //concat output of sobel with 3*
    //since only grey, convert to RGB
    assign m_axis_tdata = {FIFO3_out,FIFO3_out,FIFO3_out};

  
endmodule
