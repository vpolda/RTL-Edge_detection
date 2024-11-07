`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2024 08:25:14 AM
// Design Name: 
// Module Name: AXIS_S2M_deserializer
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


module AXIS_S2M_deserializer # (
        parameter integer S_AXIS_TDATA_WIDTH = 8,
	    parameter integer M_AXIS_TDATA_WIDTH = 1280*8,
        localparam integer DEPTH = M_AXIS_TDATA_WIDTH/S_AXIS_TDATA_WIDTH
    )
	(
        //dont care about tuser and tlast, will be redone
		// slave
		input logic s_axis_aclk,
		input logic s_axis_aresetn,

		output logic s_axis_tready, //set when 
		input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata,
		input logic s_axis_tvalid, 


        // master
		input logic m_axis_tready,
		output logic [M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
		output logic m_axis_tvalid

	);

    //need to count up to DEPTH

    //need to stop serial in when done (master)

    //need to let slave know it is ready
    
    typedef enum logic [1:0] {
        RESET,
        RECEIVING,
        OUTPUT
    } state_t;

    state_t current_state, next_state;

// State machine - four block always FSM

    //Clocked present state logic
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn)    current_state <= RESET;
        else   current_state <= next_state;
    end
    
    logic [$clog2(DEPTH):0] count = 0; //stricter to do this than integer
    logic [(M_AXIS_TDATA_WIDTH)-1:0] data_buffer = {M_AXIS_TDATA_WIDTH{'b0}};

    //count always separated for readability
    always @(posedge s_axis_aclk) begin
        //reset
        if (!s_axis_aresetn) begin
            count <= 0;
            data_buffer <= {M_AXIS_TDATA_WIDTH{1'b0}};
        end
        
        //recieving
        else if (s_axis_tvalid & count < DEPTH - 1) begin                 
            data_buffer = {s_axis_tdata,data_buffer[(M_AXIS_TDATA_WIDTH)-1:S_AXIS_TDATA_WIDTH]};
            count <= count + 1;
        end 

        //output
        else if (m_axis_tready & count == DEPTH - 1) count <= 0;
            //updates after clock cycle, handshake happens
    end
    
    //Combo Next State logic
    always @(*) begin
        // default assignment
        next_state = current_state;

        case (current_state)
            RESET: begin
                if (s_axis_tvalid)  next_state = RECEIVING;
                else next_state = RESET;
            end

            RECEIVING: begin
                if (m_axis_tready & count == DEPTH - 1) next_state = OUTPUT;
                else next_state = RECEIVING;
                
                 //else just sit and look pretty
            end

            OUTPUT: begin
                //this might need to be !s_tvalid, whatever after handshake
                if (!m_axis_tready) next_state = RESET; //wait for output reciever to be ready
                else next_state = OUTPUT;
            end
        endcase
    end

    //Combo next outputs
    logic m_axis_tvalid_w, s_axis_tready_w;
    
    always @(*) begin
        // constant assignment
        m_axis_tvalid_w = 0;
        s_axis_tready_w = 0;

        case (current_state)
            RESET: begin
                m_axis_tvalid_w = 0; //not ready to send out data
                s_axis_tready_w = 1;  // Ready to receive data
            end

            RECEIVING: begin
                s_axis_tready_w = 1; //keep coming baby
            end

            OUTPUT: begin
                s_axis_tready_w = 0; //not ready for more input data
                m_axis_tvalid_w = 1; //output data is valid
            end
        endcase
    end

    //Registered Outputs: m_axis_tdata, m_tvalid, s_tready
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn) begin
            m_axis_tdata <= {M_AXIS_TDATA_WIDTH{1'b0}};
            m_axis_tvalid <= 0;
            s_axis_tready <= 0;
        end else begin
            m_axis_tdata <= data_buffer;
            m_axis_tvalid <= m_axis_tvalid_w;
            s_axis_tready <= s_axis_tready_w;
        end
    end

endmodule
