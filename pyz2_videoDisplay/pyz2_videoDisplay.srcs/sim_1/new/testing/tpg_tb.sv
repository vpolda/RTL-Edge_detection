//-----------------------------------------------------------------------------
//  Copyright (c) 2020, Xilinx
//  All rights reserved.
// 
// This program is free software; distributed under the terms of BSD 3-clause 
// license ("Revised BSD License", "New BSD License", or "Modified BSD License")
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// * Neither the name of the copyright holder nor the names of its
//   contributors may be used to endorse or promote products derived from
//   this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//-----------------------------------------------------------------------------
// Filename:        tb_tpg.sv
// Author:			Florent Werbrouck
// Version:         v1.0
// Description:     Simulation test bench for the Video Series 4
//                  
//-----------------------------------------------------------------------------
`timescale 1ns / 1ps

import axi_vip_pkg::*;
import testing_axi_vip_0_0_pkg::*;
//import testing_axi_vip_0_1_pkg::*;

module tpg_tb(

    );

//////////////////////////////////////////////////////////////////////////////////
// Test Bench Signals
    //////////////////////////////////////////////////////////////////////////////////
    // Clock and Reset
    bit pix_clk = 0, fast_clk = 0, aresetn = 1;
    // 
    xil_axi_resp_t 	resp;


//////////////////////////////////////////////////////////////////////////////////
// TPG Register Space (check PG103 p15 for information)
    //////////////////////////////////////////////////////////////////////////////////
    //
    // TPG register base address - Check the Address Editor Tab in the BD
    parameter integer tpg_base_address = 12'h000;
    //
    // Address of some TPG registers - refer to PG103 for info
        //Control
        parameter integer TPG_CONTROL_REG       = tpg_base_address;
        // active_height
        parameter integer TPG_ACTIVE_H_REG      = tpg_base_address + 8'h10;
        // active_width
        parameter integer TPG_ACTIVE_W_REG      = tpg_base_address + 8'h18;
        // background_pattern_id
        parameter integer TPG_BG_PATTERN_ID_REG = tpg_base_address + 8'h20;
//////////////////////////////////////////////////////////////////////////////////
    // TPG Configuration
    integer height=720, width=1280;
//////////////////////////////////////////////////////////////////////////////////



// VTC Register Space (check PG016 test bench for information)
    //
    // VTC register base address - Check the Address Editor Tab in the BD
    parameter integer vtc_base_address = 12'h000;
    //
    // Address of some VTC registers - refer to PG103 for info
        //Control
        parameter integer VTC_CONTROL_REG       = vtc_base_address;
        //enable generation
        parameter integer VTC_GEN_ENABLE_REG       = vtc_base_address + 8'h02;
//////////////////////////////////////////////////////////////////////////////////
//VTC configuration

// Generate the clock : 50 MHz    
always #10ns pix_clk = ~pix_clk;
always #10ns fast_clk = ~fast_clk;

logic vid_io_out_0_active_video, vid_io_out_0_field, vid_io_out_0_hblank, vid_io_out_0_hsync, vid_io_out_0_vblank, vid_io_out_0_vsync;
logic [23:0] vid_io_out_0_data;

logic gen_en;

// Instanciation of the Unit Under Test (UUT)
testing_wrapper UUT
    (
    .fast_clk_0(fast_clk),                              // Connect to fast clock signal
    .pix_clk_0(pix_clk),                                // Connect to pixel clock signal
    .rstn(aresetn),                                          // Connect to active-low reset signal
    .vid_io_out_0_active_video(vid_io_out_0_active_video), // Connect to active video signal
    .vid_io_out_0_data(vid_io_out_0_data),                // Connect to video data signal
    .vid_io_out_0_field(vid_io_out_0_field),              // Connect to video field signal
    .vid_io_out_0_hblank(vid_io_out_0_hblank),            // Connect to horizontal blanking signal
    .vid_io_out_0_hsync(vid_io_out_0_hsync),              // Connect to horizontal sync signal
    .vid_io_out_0_vblank(vid_io_out_0_vblank),            // Connect to vertical blanking signal
    .vid_io_out_0_vsync(vid_io_out_0_vsync),               // Connect to vertical sync signal 
    .gen_clken_0(gen_en)
);

//////////////////////////////////////////////////////////////////////////////////
// Main Process. Wait to the first frame to be written and stop the simulation
// The simulation succeed if the size of the output frame is the same as configured
// in the TPG
//////////////////////////////////////////////////////////////////////////////////
//
initial begin
    //Assert the reset
    aresetn = 0;
    gen_en = 0;
    #340ns
    // Release the reset
    aresetn = 1;
    
    #10000
    $finish;
    
end
//
//////////////////////////////////////////////////////////////////////////////////
// The following part controls the AXI VIP. 
    //It follows the "Usefull Coding Guidelines and Examples" section from PG267
    //////////////////////////////////////////////////////////////////////////////////
    //
    // Declare agent
    testing_axi_vip_0_0_mst_t      master_agent_0;
    //
    initial begin    

        //Create an agent
        master_agent_0 = new("master vip agent",UUT.testing_i.axi_vip_0.inst.IF);
        
        //Start the agent
        master_agent_0.start_master();
        
        //Wait for the reset to be released
        wait (aresetn == 1'b1);
        
        #200ns
        //Set TPG output size
        master_agent_0.AXI4LITE_WRITE_BURST(TPG_ACTIVE_H_REG,0,height,resp);
        master_agent_0.AXI4LITE_WRITE_BURST(TPG_ACTIVE_W_REG,0,width,resp);
        //Set TPG output background ID
        master_agent_0.AXI4LITE_WRITE_BURST(TPG_BG_PATTERN_ID_REG,0,9,resp);
        
        #200ns
        // Start the TPG in free-running mode    
        master_agent_0.AXI4LITE_WRITE_BURST(TPG_CONTROL_REG,0,8'h81,resp); 
        
        #519ns
        gen_en = 1;
        
    end
    

/*
// VTC user added

//declare agent
testing_axi_vip_0_1_mst_t      master_agent_1;
//
initial begin    

    //Create an agent
    master_agent_1 = new("master vip_1 agent",UUT.testing_i.axi_vip_1.inst.IF);
    
    //Start the agent
    master_agent_1.start_master();
    
    //Wait for the reset to be released
    wait (aresetn == 1'b1);
    
    #200ns
    // Start GEN_ENABLE
    master_agent_1.AXI4LITE_WRITE_BURST(VTC_GEN_ENABLE_REG,0,1'b1,resp); 
      
end
*/
endmodule
