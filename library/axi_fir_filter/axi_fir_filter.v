// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_fir_filter # (

  parameter DEC_INT_N = 1,
  // interface s_axis/m_axis/native
  parameter INTERFACE_IN = "native",
  parameter INTERFACE_OUT = "native",
  parameter DEC_INT_RATE = 8,
  parameter NUM_OF_CHANNELS = 4,
  parameter CLK_IN_FREQ_MHZ = 122.88) (

  input             aclk,
  input             s_axis_data_tvalid,
  output            s_axis_data_tready,
  input     [15:0]  channel_0_in,
  input     [15:0]  channel_1_in,
  input     [15:0]  channel_2_in,
  input     [15:0]  channel_3_in,
  input     [15:0]  channel_4_in,
  input     [15:0]  channel_5_in,
  input     [15:0]  channel_6_in,
  input     [15:0]  channel_7_in,

  input     [NUM_OF_CHANNELS*16-1:0]  s_axis_data_tdata,

  input             filter_active,
  output            m_axis_data_tvalid,
  output    [15:0]  channel_0_out,
  output    [15:0]  channel_1_out,
  output    [15:0]  channel_2_out,
  output    [15:0]  channel_3_out,
  output    [15:0]  channel_4_out,
  output    [15:0]  channel_5_out,
  output    [15:0]  channel_6_out,
  output    [15:0]  channel_7_out,

  output    [NUM_OF_CHANNELS*16-1:0]  m_axis_data_tdata
);

  localparam CI_DW = NUM_OF_CHANNELS * 16 -1;

  wire [CI_DW:0] s_axis_data_tdata_s;
  wire           m_axis_data_tvalid_s;
  wire [CI_DW:0] m_axis_data_tdata_s;
  wire [CI_DW:0] m_axis_data_tdata_shift;
  wire [CI_DW:0] m_axis_data_tdata_o_s;

  genvar i;
  generate

    if (INTERFACE_IN == "native") begin
      if (NUM_OF_CHANNELS >= 1) begin
        assign s_axis_data_tdata_s[16*1-1: 16*0] = channel_0_in;
      end
      if (NUM_OF_CHANNELS >= 2) begin
        assign s_axis_data_tdata_s[16*2-1: 16*1] = channel_1_in;
      end
      if (NUM_OF_CHANNELS >= 3) begin
        assign s_axis_data_tdata_s[16*3-1: 16*2] = channel_2_in;
      end
      if (NUM_OF_CHANNELS >= 4) begin
        assign s_axis_data_tdata_s[16*4-1: 16*3] = channel_3_in;
      end
      if (NUM_OF_CHANNELS >= 5) begin
        assign s_axis_data_tdata_s[16*5-1: 16*4] = channel_4_in;
      end
      if (NUM_OF_CHANNELS >= 6) begin
        assign s_axis_data_tdata_s[16*6-1: 16*5] = channel_5_in;
      end
      if (NUM_OF_CHANNELS >= 7) begin
        assign s_axis_data_tdata_s[16*7-1: 16*6] = channel_6_in;
      end
      if (NUM_OF_CHANNELS >= 8) begin
        assign s_axis_data_tdata_s[16*8-1: 16*7] = channel_7_in;
      end
    end else begin
      assign s_axis_data_tdata_s = s_axis_data_tdata;
    end

    if (INTERFACE_OUT == "native") begin
      assign channel_0_out = (NUM_OF_CHANNELS >= 1) ? {m_axis_data_tdata_o_s[16*1-2: 16*0], 1'b0} : 'd0;
      assign channel_1_out = (NUM_OF_CHANNELS >= 2) ? {m_axis_data_tdata_o_s[16*2-2: 16*1], 1'b0} : 'd0;
      assign channel_2_out = (NUM_OF_CHANNELS >= 3) ? {m_axis_data_tdata_o_s[16*3-2: 16*2], 1'b0} : 'd0;
      assign channel_3_out = (NUM_OF_CHANNELS >= 4) ? {m_axis_data_tdata_o_s[16*4-2: 16*3], 1'b0} : 'd0;
      assign channel_4_out = (NUM_OF_CHANNELS >= 5) ? {m_axis_data_tdata_o_s[16*5-2: 16*4], 1'b0} : 'd0;
      assign channel_5_out = (NUM_OF_CHANNELS >= 6) ? {m_axis_data_tdata_o_s[16*6-2: 16*5], 1'b0} : 'd0;
      assign channel_6_out = (NUM_OF_CHANNELS >= 7) ? {m_axis_data_tdata_o_s[16*7-2: 16*6], 1'b0} : 'd0;
      assign channel_7_out = (NUM_OF_CHANNELS >= 8) ? {m_axis_data_tdata_o_s[16*8-2: 16*7], 1'b0} : 'd0;
    end

    assign m_axis_data_tdata = m_axis_data_tdata_o_s;

    assign m_axis_data_tvalid = (filter_active == 1'b1) ? m_axis_data_tvalid_s : s_axis_data_tvalid;
    assign m_axis_data_tdata_o_s = (filter_active == 1'b1) ? m_axis_data_tdata_shift : s_axis_data_tdata_s;

    for (i=1; i <= NUM_OF_CHANNELS; i=i+1) begin: shift_data
      assign m_axis_data_tdata_shift[16*i-1:16*(i-1)] = {m_axis_data_tdata_s[16*i-2:16*(i-1)], 1'b0};
    end

    fir_decim decimator (
      .aclk(aclk),
      .s_axis_data_tvalid(s_axis_data_tvalid),
      .s_axis_data_tready(s_axis_data_tready),
      .s_axis_data_tdata(s_axis_data_tdata_s),
      .m_axis_data_tvalid(m_axis_data_tvalid_s),
      .m_axis_data_tdata(m_axis_data_tdata_s)
    );

  endgenerate

endmodule

