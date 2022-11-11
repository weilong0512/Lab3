`include "def.svh"

module TagRam(
    input        [`CACHE_INDEX_BITS:0]   Address,
    input        [`CACHE_TAG_BITS:0]     TagIn,
    input                              Write,
    input                              Clk,
    output logic [`CACHE_TAG_BITS:0]     TagOut
);

logic [`CACHE_TAG_BITS:0] TagOut;
logic [`CACHE_TAG_BITS:0] TagRam [`CACHE_LINES-1:0];


always_ff @ (negedge Clk) begin
    if(Write) begin
        TagRam[Address] <= TagIn;
    end  
end

always_ff @ (posedge Clk) begin
    TagOut <= TagRam[Address];
end



endmodule