
source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl

ad_ip_instance axi_sysid axi_sysid_0

#generating memory init file
sysid_gen_init_file

# adding file path to ip
ad_ip_parameter axi_sysid_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init.txt"

ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 6
ad_cpu_interconnect 0x45000000 axi_sysid_0
