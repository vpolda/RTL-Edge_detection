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
	    parameter integer M_AXIS_TDATA_WIDTH = 1280, //need to change this
        parameter integer DEPTH = 1280//M_AXIS_TDATA_WIDTH/S_AXIS_TDATA_WIDTH
    )
	(
        //dont care about tuser and tlast, will be redone
		// slave
		input logic s_axis_aclk, s_axis_aresetn,

		output logic s_axis_tready, //set when 
		input logic [S_AXIS_TDATA_WIDTH-1 : 0] s_axis_tdata, s_axis_tvalid, 

        // master
		input logic m_axis_tready, //trusting that the slave can capture this in one clock cycle
		output logic [(M_AXIS_TDATA_WIDTH-1) : 0] m_axis_tdata, m_axis_tvalid

	);

    
    integer count; //stricter to do this than integer
    logic [(M_AXIS_TDATA_WIDTH-1):0] data_buffer = {M_AXIS_TDATA_WIDTH{'b0}};
    logic m_axis_tvalid_w, s_axis_tready_w;
    
    typedef enum logic [2:0] {
        RESET = 3'b000,
        IDLE = 3'b001,
        RECIEVING = 3'b010,
        READY = 3'b011,
        SENDING = 3'b100 //needs to be check before IDLE
    } state_t;

    state_t current_state, next_state;

// State machine - four block always FSM

 //Clocked present state logic
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn)    current_state <= RESET;
        else   current_state <= next_state;
    end
    

 //Counter
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn) count <= 0;
        else begin
            if (current_state == RECIEVING) count <= count + 1;
            else count <= count;
        end
    end
    
 //Combo next outputs
    always_comb begin
        // default assignment
        next_state = current_state;

        case (current_state)
            RESET: begin
                if (s_tvalid) next_state = RECIEVING;
                else next_state = RESET;
            end

            RECIEVING: begin
                if (count == WIDTH) begin //if enough counts, 

                    if (m_axis_tready) next_state = SENDING; //and master is ready
                    else next_state = READY; //wait till master is ready

                end else if (!s_axis_tvalid) next_state = IDLE; //wait till slave is ready

                else next_state = RECIEVING;
            end
            
            READY: begin
                if (m_axis_tready) next_state = SENDING //wait till master is ready
                else next_state = READY;
            end

            SENDING: begin //only one clock cycle to grab!
                next_state = RESET;
            end

            IDLE: begin
                
            end
        endcase
    end

 //Registered Outputs: m_axis_tdata, m_tvalid, s_tready
    //leave this even though using logic
    assign m_axis_tdata = data_buffer; //data buffer is already regitered


endmodule
/*

// State machine - four block always FSM

    //Clocked present state logic
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn)    current_state <= RESET;
        else   current_state <= next_state;
    end
    
    integer count; //stricter to do this than integer
    logic [(M_AXIS_TDATA_WIDTH-1):0] data_buffer = {M_AXIS_TDATA_WIDTH{'b0}};

    //count always separated for readability
    always @(posedge s_axis_aclk) begin
        //reset
        if (current_state == RESET) begin
            count <= 0;
            data_buffer <= {M_AXIS_TDATA_WIDTH{1'b0}};
        end else if (current_state == RECIEVING) begin //recieving
            if (count < DEPTH)  begin            
                data_buffer <= {s_axis_tdata, data_buffer[(M_AXIS_TDATA_WIDTH)-1:S_AXIS_TDATA_WIDTH]};
                count <= count + 1;
            end
        end 

        //output
        //else if (m_axis_tready & count == DEPTH) count <= 0;
            //updates after clock cycle, handshake happens
    end
    
    //Combo Next State logic
    always_comb begin
        // default assignment
        next_state = current_state;

        case (current_state)
            RESET: begin
                if (s_axis_tvalid)  next_state = RECIEVING;
                else next_state = current_state;
            end

            RECIEVING: begin
                if (m_axis_tready & count == DEPTH) next_state = SENDING;
                else next_state = current_state;
                
                 //else just sit and look pretty
            end

            SENDING: begin
                //this might need to be !s_tvalid, whatever after handshake
                if (m_axis_tready) next_state = RESET; //wait for output reciever to be ready
                else next_state = current_state;
            end
        endcase
    end

    //Combo next outputs
    logic m_axis_tvalid_w, s_axis_tready_w;
    
    always_comb begin
        // constant assignment
        //m_axis_tvalid_w = 0;
        //s_axis_tready_w = 0;

        case (current_state)
            RESET: begin
                m_axis_tvalid_w = 0; //not ready to send out data
                s_axis_tready_w = 1;  // Ready to receive data
            end

            RECIEVING: begin
                s_axis_tready_w = 1; //keep coming baby
            end

            SENDING: begin
                s_axis_tready_w = 0; //not ready for more input data
                m_axis_tvalid_w = 1; //output data is valid
            end
        endcase
    end

    //Registered Outputs: m_axis_tdata, m_tvalid, s_tready
    assign m_axis_tdata = data_buffer; //data buffer is already regitered
    always @(posedge s_axis_aclk) begin
        if (!s_axis_aresetn) begin
            m_axis_tvalid <= 0;
            s_axis_tready <= 0;
        end else begin
            m_axis_tvalid <= m_axis_tvalid_w;
            s_axis_tready <= s_axis_tready_w;
        end
    end
*/