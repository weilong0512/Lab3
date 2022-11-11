`include "def.svh"

module DataRam(Address, DataIn, DataOut, Write, Clk);
input  [`CACHE_INDEX_BITS:0]  Address;
input  [`DATA_BITS:0]         DataIn;
input                         Write;
input                         Clk;
output [`DATA_BITS:0]         DataOut;

reg    [`DATA_BITS:0]         DataOut;
reg    [`DATA_BITS:0]         DataRam [`CACHE_LINES-1:0];
always @ (negedge Clk)
    if (Write)
        DataRam[Address]=DataIn; // write
always @ (posedge Clk)
    DataOut = DataRam [Address]; // read
endmodule