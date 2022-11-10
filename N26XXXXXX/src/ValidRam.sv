`include "def.svh"


module ValidRam (
    input [`CACHE_INDEX_BITS] Address,
    input                     ValidIn,
    input                     Write,
    input                     Reset,
    input                     clk,
    output                    validOut
);

reg ValidOut;
reg [`CACHE_LINES-1:0] ValidBits;
integer i;
always_ff @ (negedge Clk) // Write
    if (Reset) begin
        for (i=0;i<`CACHE_LINES;i=i+1)
            ValidBits[i]= 1'b0; //reset
    end else begin
        if (Write)
            ValidBits[Address]=ValidIn; // write
    end

always_ff @ (posedge Clk)
    ValidOut = ValidBits[Address]; // read