`include "def.svh"


module Comparator (Tag1,Tag2, Match);
input [`CACHE_TAG_BITS] Tag1;
input [`CACHE_TAG_BITS] Tag2;
output                  Match;

wire Match = (Tag1 == Tag2);

endmodule