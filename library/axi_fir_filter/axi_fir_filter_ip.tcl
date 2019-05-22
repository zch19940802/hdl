source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip.tcl

adi_ip_create axi_fir_filter

set fir_decim [create_ip -name fir_compiler -vendor xilinx.com -library ip -version 7.2 -module_name fir_decim]
 set_property -dict [ list \
CONFIG.Clock_Frequency {122.88} \
CONFIG.CoefficientSource {COE_File} \
CONFIG.Coefficient_File {../../../../coefile_dec.coe} \
CONFIG.Coefficient_Fractional_Bits {0} \
CONFIG.Data_Fractional_Bits {15} \
CONFIG.Coefficient_Sets {1} \
CONFIG.Coefficient_Sign {Signed} \
CONFIG.Coefficient_Structure {Inferred} \
CONFIG.Coefficient_Width {16} \
CONFIG.ColumnConfig {5} \
CONFIG.Decimation_Rate {8} \
CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
CONFIG.Filter_Type {Decimation} \
CONFIG.Interpolation_Rate {1} \
CONFIG.Number_Channels {1} \
CONFIG.Number_Paths {4} \
CONFIG.Output_Rounding_Mode {Symmetric_Rounding_to_Zero} \
CONFIG.Output_Width {16} \
CONFIG.Quantization {Integer_Coefficients} \
CONFIG.RateSpecification {Frequency_Specification} \
CONFIG.Sample_Frequency {122.88} \
CONFIG.Zero_Pack_Factor {1} \
 ] [get_ips fir_decim]

generate_target {all} [get_files axi_fir_filter.srcs/sources_1/ip/fir_decim/fir_decim.xci]


adi_ip_files axi_fir_filter [list \
"axi_fir_filter.v" ]

adi_ip_properties_lite axi_fir_filter

set_property value_format string [ipx::get_user_parameters INTERFACE_IN -of_objects [ipx::current_core]]
set_property value_format string [ipx::get_hdl_parameters INTERFACE_IN -of_objects [ipx::current_core]]
set_property value_validation_list {native s_axis} \
  [ipx::get_user_parameters INTERFACE_IN -of_objects [ipx::current_core]]

set_property value_format string [ipx::get_user_parameters INTERFACE_OUT -of_objects [ipx::current_core]]
set_property value_format string [ipx::get_hdl_parameters INTERFACE_OUT -of_objects [ipx::current_core]]
set_property value_validation_list {native m_axis} \
  [ipx::get_user_parameters INTERFACE_OUT -of_objects [ipx::current_core]]

set_property value_format long [ipx::get_user_parameters NUM_OF_CHANNELS -of_objects [ipx::current_core]]
set_property value_format long [ipx::get_hdl_parameters NUM_OF_CHANNELS -of_objects [ipx::current_core]]
set_property value_validation_list {1 2 4 8} \
  [ipx::get_user_parameters NUM_OF_CHANNELS -of_objects [ipx::current_core]]


set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 1 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_0_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 2 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_1_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 3 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_2_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 4 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_3_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 5 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_4_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 6 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_5_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 7 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_6_out* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 8 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "native"} \
  [ipx::get_ports *channel_7_out* -of_objects [ipx::current_core]]

set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = "m_axis"} \
  [ipx::get_ports *m_axis_data_tdata* -of_objects [ipx::current_core]]

#set_property driver_value 0 [ipx::get_ports channel_0_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_1_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_2_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_3_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_4_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_5_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_6_in -of_objects [ipx::current_core]]
set_property driver_value 0 [ipx::get_ports channel_7_in -of_objects [ipx::current_core]]


adi_set_ports_dependency "channel_0_in" \
	"spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 1 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = \"native\"" 0

#set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 1 \
#  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
#  [ipx::get_ports *channel_0_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 2 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_1_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 3 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_2_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 4 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_3_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 5 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_4_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 6 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_5_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 7 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_6_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.NUM_OF_CHANNELS')) >= 8 \
  and spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "native"} \
  [ipx::get_ports *channel_7_in* -of_objects [ipx::current_core]]
set_property enablement_dependency {spirit:decode(id('MODELPARAM_VALUE.INTERFACE_IN')) = "s_axis"} \
  [ipx::get_ports *s_axis_data_tdata* -of_objects [ipx::current_core]]

#adi_add_bus "m_axis" "master" \
#         "xilinx.com:interface:axis_rtl:1.0" \
#         "xilinx.com:interface:axis:1.0" \
#         [list {"s_axis_data_tready" "TREADY"} \
#               {"m_axis_data_tvalid" "TVALID"} \
#               {"m_axis_data_tdata"  "TDATA"} ]
#
#adi_set_bus_dependency "m_axis" "m_axis" \
#	"(spirit:decode(id('MODELPARAM_VALUE.INTERFACE_OUT')) = \"m_axis\")"

ipx::infer_bus_interface aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]

