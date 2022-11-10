`include "def.svh"

module TagRam(
    input        [`CACHE_INDEX_BITS]   Address,
    input        [`CACHE_TAG_BITS]     TagIn,
    input                              Write,
    input                              clk,
    input                              rst,
    output logic [`CACHE_TAG_BITS]     TagOut
);

logic [`CACHE_TAG_BITS] TagOut;
logic [`CACHE_TAG_BITS] TagRam [0:`CACHE_LINES-1];


always_ff @ (negedge clk, posedge rst) begin
    if(rst) begin
        foreach(TagRam[i]) begin
            TagRam[i] <= `CACHE_TAG_BITS'b0;
        end
    end else begin
        if(Write) begin
            TagRam[Address] <= TagIn;
        end
    end    
end

always_ff @ (posedge clk, posedge rst) begin
    if(rst) begin
        TagOut <= `CACHE_TAG_BITS'b0;
    end else begin
        if(Write) begin
            TagOut <= TagRam[Address];
        end
    end    
end



endmodule