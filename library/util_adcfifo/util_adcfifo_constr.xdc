
set_property ASYNC_REG TRUE \
  [get_cells -hier -filter {name =~ *adc_xfer_req_m*}] \
  [get_cells -hier -filter {name =~ *dma_waddr_rel_t*}] \
  [get_cells -hier -filter {name =~ *dma_capture_start_in_reg*}] \
  [get_cells -hier {*cdc_sync_stage1_reg*}] \
  [get_cells -hier {*cdc_sync_stage2_reg*}]

set_false_path \
  -from [get_cells -hier -filter {name =~ *adc_waddr_rel_t_reg* && IS_SEQUENTIAL}] \
  -to [get_cells -hier -filter {name =~ *dma_waddr_rel_t_m_reg[0]* && IS_SEQUENTIAL}]

set_false_path \
  -from [get_cells -hier -filter {name =~ *adc_waddr_rel_reg* && IS_SEQUENTIAL}] \
  -to [get_cells -hier -filter {name =~ *dma_waddr_rel_reg* && IS_SEQUENTIAL}]

set_false_path \
  -to [get_cells -hier -filter {name =~ *dma_capture_start_in_reg[0]* && IS_SEQUENTIAL}]

set_false_path \
  -to [get_cells -hier -filter {name =~ *adc_xfer_req_m_reg[0]* && IS_SEQUENTIAL}]

set_false_path \
  -to [get_pins -hierarchical * -filter {NAME=~*i_adc_capture_start_sync/cdc_sync_stage1_reg[0]/D}]

