`include "def.svh"

module DataRam(Address, DataIn, DataOut, Write, Clk);
input  [`CACHE_INDEX_BITS]  Address;
input  [`DATA_BITS]         DataIn;
input                       Write;
input                       Clk;
output [`DATA_BITS]         DataOut;

reg    [`DATA_BITS]         DataOut;
reg    [`DATA_BITS]         DataRam [`CACHE_LINES-1:0];
always @ (negedge Clk)
    if (Write)
        DataRam[Address]=DataIn; // write
always @ (posedge Clk)
    DataOut = DataRam [Address]; // read
endmodule