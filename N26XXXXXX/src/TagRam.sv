`include "def.svh"

module TagRam(
    input        [`CACHE_INDEX_BITS]   Address,
    input        [`CACHE_TAG_BITS]     TagIn,
    input                              Write,
    input                              clk,
    output logic [`CACHE_TAG_BITS]     TagOut
);

logic [`CACHE_TAG_BITS] TagOut;
logic [`CACHE_TAG_BITS] TagRam [0:`CACHE_LINES-1];


always_ff @ (negedge clk) begin
    if(Write) begin
        TagRam[Address] <= TagIn;
    end  
end

always_ff @ (posedge clk) begin
    TagOut <= TagRam[Address];
end



endmodule