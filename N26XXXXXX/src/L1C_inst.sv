//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
`include "CacheCTRL.sv"
module L1C_inst(
	input clk,
	input rst,
	// Core to CPU wrapper
	input [`DATA_BITS-1:0] core_addr,
	input core_req,
	input core_write,
	input [`DATA_BITS-1:0] core_in,
	input [`CACHE_TYPE_BITS-1:0] core_type,
	// Mem to CPU wrapper
	input [`DATA_BITS-1:0] I_out,
	input I_wait,
	// CPU wrapper to core
	output logic [`DATA_BITS-1:0] core_out,
	output core_wait,
	// CPU wrapper to Mem
	output logic I_req,
	output logic [`DATA_BITS-1:0] I_addr,
	output I_write,
	output [`DATA_BITS-1:0] I_in,
	output [`CACHE_TYPE_BITS-1:0] I_type
);

	logic [`CACHE_INDEX_BITS-1:0] index;
	logic [`CACHE_DATA_BITS-1:0] DA_out;
	logic [`CACHE_DATA_BITS-1:0] DA_in;
	logic [`CACHE_WRITE_BITS-1:0] DA_write;
	logic DA_read;
	logic [`CACHE_TAG_BITS-1:0] TA_out;
	logic [`CACHE_TAG_BITS-1:0] TA_in;
	logic TA_write;
	logic TA_read;
	logic TA_match;
	logic [`CACHE_LINES-1:0] valid;

  //--------------- complete this part by yourself -----------------//
  	`define READ 1'b1
	`define WRITE 1'b0
	`define CACHESIZE 1024
	`define WAITSTATE 2'd2
	`define ADDR 15:0
	`define ADDRWIDTH 16
	`define INDEX 9:0
	`define TAG 15:10
	`define DATA 31:0
	`define DATAWIDTH 32
	`define PRESENT 1'b1
	`define ABSENT !`PRESENT

assign index = core_addr[`INDEX]


	data_array_wrapper DA(
		.A(index),
		.DO(DA_out),
		.DI(DA_in),
		.CK(clk),
		.WEB(DA_write),
		.OE(DA_read),
		.CS(1'b1)
	);

	tag_array_wrapper  TA(
		.A(index),
		.DO(TA_out),
		.DI(TA_in),
		.CK(clk),
		.WEB(TA_write),
		.OE(TA_read),
		.CS(1'b1)
	);

	// Valid Ram

	logic VA_out;
	logic VA_write;

	always_ff @(posedge clk, posedge rst)begin
		if(rst) begin
			for (i=0;i<`CACHE_LINES;i=i+1)
				valid[i] <= 1'b0; //reset
		end else begin
			if(VA_write) begin
				valid[index] <= 1'b1;
			end else begin
				VA_out <= valid[index];
			end
		end
	end

	Comparator CMP(
		.Tag1(core_addr[31:10]),
		.Tag2(TA_out),
		.Match(TA_match)
	);

	wire Hit  = TA_match & VA_out;

	logic WE;
	assign DA_write = WE;
	assign TA_write = WE;
	assign VA_write = WE;

	logic PDataSelect;
	logic PDataOut;
	logic PDataOE;
	logic PData;
	logic SysDataOE;
	logic SysData;
	logic CacheDataSelect; 
	CacheCTRL control(
		.PStrobe(core_req), 
		.PRW(core_write),
		.PReady(core_wait),
		.Hit(Hit)
		.Write(WE), 
		.CacheDataSelect(CacheDataSelect),
		.PDataSelect(PDataSelect),
		.SysDataOE(SysDataOE), 
		.PDataOE(PDataOE),
		.SysStrobe(I_req), 
		.SysRW(I_write),

		.Reset(rst),
		.Clk(clk)
	);
	assign I_in = SysDataOE ? core_in : 32'bz ;
	assign PDataOut = PDataSelect ? DA_out : I_out ;
	assign core_out = PDataOE ? PDataOut : 32'bz ;
	assign DA_in = CacheDataSelect ? I_out : core_in ;
	// I suppose that inout PDATA -> input core_in + output core_out;
	// I suppose that inout SysData -> input I_out + output I_in;
	

 





endmodule

