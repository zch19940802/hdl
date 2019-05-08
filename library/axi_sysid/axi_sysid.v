`timescale 1ns / 1ps

module sys_id #(
  parameter ID = 0,
  parameter PATH_TO_FILE = "path_to_mem_init_file",
  parameter ROM_WIDTH = 32,
  parameter ROM_ADDR_BITS = 6)(

   //axi interface
  input           s_axi_aclk,
  input           s_axi_aresetn,
  input           s_axi_awvalid,
  input   [15:0]  s_axi_awaddr,
  input   [ 2:0]  s_axi_awprot,
  output          s_axi_awready,
  input           s_axi_wvalid,
  input   [31:0]  s_axi_wdata,
  input   [ 3:0]  s_axi_wstrb,
  output          s_axi_wready,
  output          s_axi_bvalid,
  output  [ 1:0]  s_axi_bresp,
  input           s_axi_bready,
  input           s_axi_arvalid,
  input   [15:0]  s_axi_araddr,
  input   [ 2:0]  s_axi_arprot,
  output          s_axi_arready,
  output          s_axi_rvalid,
  output  [ 1:0]  s_axi_rresp,
  output  [31:0]  s_axi_rdata,
  input           s_axi_rready);

localparam          AXI_ADDRESS_WIDTH    = 8;
localparam  [31:0]  CORE_VERSION         = {16'h0000,     /* MAJOR */
                                              8'h01,      /* MINOR */
                                              8'h00};     /* PATCH */
localparam  [31:0]  CORE_MAGIC           = 32'h53594944;  // SYID

(* rom_style = "distributed" *) reg [ROM_WIDTH-1:0] SYS_ID_ROM [(2**ROM_ADDR_BITS)-1:0];

reg                             up_wack = 'd0;
reg   [31:0]                    up_rdata_s = 'd0;
reg                             up_rack_s = 'd0;
reg   [31:0]                    up_scratch = 'd0;
reg   [ROM_WIDTH-1:0]           sys_id_rom_out = 'h0;
reg   [ROM_ADDR_BITS-1:0]       sys_id_rom_addr = 'h0;
reg   [ROM_ADDR_BITS-1:0]       up_sys_id_rom_addr = 'h0;
reg                             rom_read_done = 'h0;

wire                            up_clk;
wire                            up_rreq_s;
wire  [AXI_ADDRESS_WIDTH-1:0]   up_raddr_s;
wire                            up_wreq_s;
wire  [AXI_ADDRESS_WIDTH-1:0]   up_waddr_s;
wire  [31:0]                    up_wdata_s;

assign up_clk = s_axi_aclk;

initial
  $readmemh(PATH_TO_FILE, SYS_ID_ROM, 0, (2**ROM_ADDR_BITS)-1);

up_axi #(
  .ADDRESS_WIDTH(AXI_ADDRESS_WIDTH))
i_up_axi (
  .up_rstn (s_axi_aresetn),
  .up_clk (up_clk),
  .up_axi_awvalid (s_axi_awvalid),
  .up_axi_awaddr (s_axi_awaddr),
  .up_axi_awready (s_axi_awready),
  .up_axi_wvalid (s_axi_wvalid),
  .up_axi_wdata (s_axi_wdata),
  .up_axi_wstrb (s_axi_wstrb),
  .up_axi_wready (s_axi_wready),
  .up_axi_bvalid (s_axi_bvalid),
  .up_axi_bresp (s_axi_bresp),
  .up_axi_bready (s_axi_bready),
  .up_axi_arvalid (s_axi_arvalid),
  .up_axi_araddr (s_axi_araddr),
  .up_axi_arready (s_axi_arready),
  .up_axi_rvalid (s_axi_rvalid),
  .up_axi_rresp (s_axi_rresp),
  .up_axi_rdata (s_axi_rdata),
  .up_axi_rready (s_axi_rready),
  .up_wreq (up_wreq_s),
  .up_waddr (up_waddr_s),
  .up_wdata (up_wdata_s),
  .up_wack (up_wack),
  .up_rreq (up_rreq_s),
  .up_raddr (up_raddr_s),
  .up_rdata (up_rdata_s),
  .up_rack (up_rack_s));

//axi registers read
always @(posedge up_clk) begin
  if (s_axi_aresetn == 1'b0) begin
    up_rack_s <= 'd0;
    up_rdata_s <= 'd0;
  end else begin
    up_rack_s <= up_rreq_s;
    if (up_rreq_s == 1'b1) begin
      case (up_raddr_s)
        8'h00: up_rdata_s <= CORE_VERSION;
        8'h01: up_rdata_s <= ID;
        8'h02: up_rdata_s <= up_scratch;
        8'h03: up_rdata_s <= CORE_MAGIC;
        8'h21: up_rdata_s <= SYS_ID_ROM [sys_id_rom_addr];
        default: begin
          up_rdata_s <= 'h0;
        end
      endcase
    end else begin
      up_rdata_s <= 32'd0;
    end
  end
end

//axi registers write
always @(posedge up_clk) begin
  if (s_axi_aresetn == 1'b0) begin
    up_wack <= 'd0;
    sys_id_rom_addr <= 'h0;
    up_scratch <= 'd0;
  end else begin
    up_wack <= up_wreq_s;
    if ((up_wreq_s == 1'b1) && (up_waddr_s == 8'h02)) begin
      up_scratch <= up_wdata_s;
    end
    if ((up_wreq_s == 1'b1) && (up_waddr_s == 8'h22)) begin
      sys_id_rom_addr <= up_wdata_s;
    end else if ((up_rreq_s == 1'b1) && (up_raddr_s == 8'h21)) begin
      sys_id_rom_addr <= sys_id_rom_addr + 'h1;
    end
  end
end

endmodule
