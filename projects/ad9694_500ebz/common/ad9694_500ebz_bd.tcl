
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

# Lane 0 and 1 are in a different quad than lane 2 and 3. To get two quads
# instantiate 6 physical lanes and leave lane 2 and 3 of the PHY unconnected.
if {$NUM_OF_LANES == 4} {
  set NUM_OF_XCVR_LANES 6
} else {
  set NUM_OF_XCVR_LANES 2
}

# adc peripherals

ad_ip_instance axi_adxcvr axi_ad9694_xcvr [list \
  NUM_OF_LANES $NUM_OF_XCVR_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 0 \
]

adi_axi_jesd204_rx_create ad9694_jesd $NUM_OF_LANES

ad_ip_instance ad_ip_jesd204_tpl_adc ad9694_tpl_core [list \
  NUM_CHANNELS $NUM_OF_CHANNELS \
  CONVERTER_RESOLUTION $ADC_RESOLUTION \
  BITS_PER_SAMPLE $SAMPLE_WIDTH \
  NUM_LANES $NUM_OF_LANES \
  TWOS_COMPLEMENT 0 \
]

ad_ip_instance util_cpack2 util_ad9694_cpack [list \
  NUM_OF_CHANNELS $NUM_OF_CHANNELS \
  SAMPLES_PER_CHANNEL [expr $CHANNEL_DATA_WIDTH / $SAMPLE_WIDTH] \
  SAMPLE_DATA_WIDTH $SAMPLE_WIDTH \
]

ad_ip_instance axi_dmac ad9694_dma [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  DMA_DATA_WIDTH_SRC $DMA_DATA_WIDTH \
  DMA_DATA_WIDTH_DEST 64 \
]

# shared transceiver core

ad_ip_instance util_adxcvr util_ad9694_xcvr [list \
  RX_NUM_OF_LANES $NUM_OF_XCVR_LANES \
  TX_NUM_OF_LANES 0 \
]

ad_connect sys_cpu_resetn util_ad9694_xcvr/up_rstn
ad_connect sys_cpu_clk util_ad9694_xcvr/up_clk

# reference clocks & resets

create_bd_port -dir I -type clk rx_ref_clk
create_bd_port -dir I -type clk rx_device_clk

ad_xcvrpll  rx_ref_clk util_ad9694_xcvr/qpll_ref_clk_*
ad_xcvrpll  rx_ref_clk util_ad9694_xcvr/cpll_ref_clk_*
ad_xcvrpll  axi_ad9694_xcvr/up_pll_rst util_ad9694_xcvr/up_qpll_rst_*
ad_xcvrpll  axi_ad9694_xcvr/up_pll_rst util_ad9694_xcvr/up_cpll_rst_*

# connections (adc)

ad_xcvrcon util_ad9694_xcvr axi_ad9694_xcvr ad9694_jesd {0 1 4 5} rx_device_clk
ad_connect rx_device_clk ad9694_tpl_core/link_clk
ad_connect ad9694_jesd/rx_sof ad9694_tpl_core/link_sof
ad_connect ad9694_jesd/rx_data_tvalid ad9694_tpl_core/link_valid
ad_connect ad9694_jesd/rx_data_tdata ad9694_tpl_core/link_data

ad_connect rx_device_clk util_ad9694_cpack/clk
ad_connect rx_device_clk_rstgen/peripheral_reset util_ad9694_cpack/reset

for {set i 0} {$i < $NUM_OF_CHANNELS} {incr i} {
  ad_ip_instance xlslice ad9694_enable_slice_$i [list \
    DIN_WIDTH $NUM_OF_CHANNELS \
    DIN_FROM $i \
    DIN_TO $i \
  ]

  ad_ip_instance xlslice ad9694_valid_slice_$i [list \
    DIN_WIDTH $NUM_OF_CHANNELS \
    DIN_FROM $i \
    DIN_TO $i \
  ]

  ad_ip_instance xlslice ad9694_data_slice_$i [list \
    DIN_WIDTH $ADC_DATA_WIDTH \
    DIN_FROM [expr ($i + 1) * $CHANNEL_DATA_WIDTH - 1] \
    DIN_TO [expr $i * $CHANNEL_DATA_WIDTH] \
  ]

  ad_connect ad9694_tpl_core/enable ad9694_enable_slice_$i/Din
  ad_connect ad9694_tpl_core/adc_valid ad9694_valid_slice_$i/Din
  ad_connect ad9694_tpl_core/adc_data ad9694_data_slice_$i/Din

  ad_connect ad9694_enable_slice_$i/Dout util_ad9694_cpack/enable_$i
  ad_connect ad9694_data_slice_$i/Dout util_ad9694_cpack/fifo_wr_data_$i
}
ad_connect ad9694_valid_slice_0/Dout util_ad9694_cpack/fifo_wr_en

ad_connect rx_device_clk axi_ad9694_fifo/adc_clk
ad_connect rx_device_clk_rstgen/peripheral_reset axi_ad9694_fifo/adc_rst
ad_connect util_ad9694_cpack/packed_fifo_wr_en axi_ad9694_fifo/adc_wr
ad_connect util_ad9694_cpack/packed_fifo_wr_data axi_ad9694_fifo/adc_wdata
ad_connect sys_cpu_clk axi_ad9694_fifo/dma_clk
ad_connect sys_cpu_clk ad9694_dma/s_axis_aclk
ad_connect sys_cpu_resetn ad9694_dma/m_dest_axi_aresetn
ad_connect axi_ad9694_fifo/dma_wr ad9694_dma/s_axis_valid
ad_connect axi_ad9694_fifo/dma_wdata ad9694_dma/s_axis_data
ad_connect axi_ad9694_fifo/dma_wready ad9694_dma/s_axis_ready
ad_connect axi_ad9694_fifo/dma_xfer_req ad9694_dma/s_axis_xfer_req
ad_connect ad9694_tpl_core/adc_dovf axi_ad9694_fifo/adc_wovf

# interconnect (cpu)

ad_cpu_interconnect 0x44A50000 axi_ad9694_xcvr
ad_cpu_interconnect 0x44A10000 ad9694_tpl_core
ad_cpu_interconnect 0x44AA0000 ad9694_jesd
ad_cpu_interconnect 0x7c400000 ad9694_dma

# gt uses hp3, and 100MHz clock for both DRP and AXI4

ad_mem_hp3_interconnect sys_cpu_clk sys_ps7/S_AXI_HP3
ad_mem_hp3_interconnect sys_cpu_clk axi_ad9694_xcvr/m_axi

# interconnect (mem/dac)

ad_mem_hp2_interconnect sys_cpu_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect sys_cpu_clk ad9694_dma/m_dest_axi

# interrupts

ad_cpu_interrupt ps-11 mb-14 ad9694_jesd/irq
ad_cpu_interrupt ps-13 mb-12 ad9694_dma/irq
