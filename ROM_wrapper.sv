`include "/home/weilong/VSD/Lab3/include/AXI_define.svh"

module ROM_wrapper (
    input  logic                      ACLK,
    input  logic                      ARESETn,

    // // AW channel
    // input  logic [`AXI_IDS_BITS-1:0]  AWID,
    // input  logic [`AXI_ADDR_BITS-1:0] AWADDR,
    // input  logic [`AXI_LEN_BITS-1:0]  AWLEN,
    // input  logic [`AXI_SIZE_BITS-1:0] AWSIZE,
    // input  logic [1:0]                AWBURST,
    // input  logic                      AWVALID,
    // output logic                      AWREADY,

    // // Write channel
    // input  logic [`AXI_DATA_BITS-1:0] WDATA,
    // input  logic [`AXI_STRB_BITS-1:0] WSTRB,
    // input  logic                      WLAST,
    // input  logic                      WVALID,
    // output logic                      WREADY,

    // // Write RESP
    // output logic [`AXI_IDS_BITS-1:0]  BID,
    // output logic [1:0]                BRESP,
    // output logic                      BVALID,
    // input  logic                      BREADY,

    // AR channel
    input  logic [`AXI_IDS_BITS-1:0]  ARID,
    input  logic [`AXI_ADDR_BITS-1:0] ARADDR,
    input  logic [`AXI_LEN_BITS-1:0]  ARLEN,
    input  logic [`AXI_SIZE_BITS-1:0] ARSIZE,
    input  logic [1:0]                ARBURST,
    input  logic                      ARVALID,
    output logic                      ARREADY,
    // Read channel
    output logic [`AXI_IDS_BITS-1:0]  RID,
    output logic [`AXI_DATA_BITS-1:0] RDATA,
    output logic [1:0]                RRESP,
    output logic                      RLAST,
    output logic                      RVALID,
    input  logic                      RREADY,

    output logic                      OE,
    output logic                      CS,
    output logic [11:0]               A,
    input logic [`AXI_DATA_BITS-1:0]  DO
);

    assign CS = 1'b1;
    assign OE = 1'b1;

    // ROM   0x0000_0000 ~ 0x0000_1FFF
    // IM    0x0001_0000 ~ 0x0001_FFFF
    // DM    0x0002_0000 ~ 0x0002_FFFF
    // Sctrl 0x1000_0000 ~ 0x1000_03FF
    // DRAM  0x2000_0000 ~ 0x201F_FFFF
    /*
     * FSM for -  Write Address Channel Slave
     */
    enum logic [2:0] {
        INIT = 3'd0,
        WAIT= 3'd1,
        READ_WAIT= 3'd2,
        READ_VALID= 3'd3,
        READ_ERROR= 3'd4,
        READ_LAST= 3'd5,
        READ_VALID_WAIT= 3'd6,
        READ_ERROR_WAIT= 3'd7
    } STATE, NXSTATE;

    assign ARREADY = (STATE == WAIT);
    assign RVALID = (STATE == READ_VALID | STATE == READ_ERROR);

  
    logic [`AXI_IDS_BITS-1:0]  ARID_reg_q, ARID_reg_d;
    logic [`AXI_ADDR_BITS-1:0] ARADDR_reg_q, ARADDR_reg_d;
    logic [`AXI_LEN_BITS-1:0]  ARLEN_reg_q, ARLEN_reg_d;
    logic [`AXI_SIZE_BITS-1:0] ARSIZE_reg_q, ARSIZE_reg_d;
    logic [1:0]                ARBURST_reg_q, ARBURST_reg_d;
    logic [1:0]                RRESP_reg_q, RRESP_reg_d;
    logic                      RLAST_reg_q, RLAST_reg_d;


    always_ff @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            STATE         <= INIT;
            ARID_reg_q    <= `AXI_IDS_BITS'd0;
            ARADDR_reg_q  <= `AXI_ADDR_BITS'd0;
            ARLEN_reg_q   <= `AXI_LEN_BITS'd0;
            ARSIZE_reg_q  <= `AXI_SIZE_BITS'd0;
            ARBURST_reg_q <= 2'd0;
            RRESP_reg_q   <= `AXI_RESP_OKAY;
            RLAST_reg_q   <= 1'b0;

        end else begin
            STATE         <= NXSTATE;
            ARID_reg_q    <= ARID_reg_d;
            ARADDR_reg_q  <= ARADDR_reg_d;
            ARLEN_reg_q   <= ARLEN_reg_d;
            ARSIZE_reg_q  <= ARSIZE_reg_d;
            ARBURST_reg_q <= ARBURST_reg_d;
            RRESP_reg_q   <= RRESP_reg_d;
            RLAST_reg_q   <= RLAST_reg_d;

        end
    end

    always_comb begin   
        NXSTATE       = STATE;
        ARID_reg_d    = ARID_reg_q;
        ARADDR_reg_d  = ARADDR_reg_q;
        ARLEN_reg_d   = ARLEN_reg_q;
        ARSIZE_reg_d  = ARSIZE_reg_q;
        ARBURST_reg_d = ARBURST_reg_q;
        RRESP_reg_d   = RRESP_reg_q;
        RLAST_reg_d   = RLAST_reg_q;
        RRESP         = `AXI_RESP_OKAY;
        RLAST         = 1'd0;
        A             = 12'd0;
        RDATA         = 32'd0;

        unique case (STATE)
        INIT: begin
            NXSTATE       = WAIT;
            RRESP         = `AXI_RESP_OKAY;
            RLAST         = 1'd0;
            ARID_reg_d    = `AXI_IDS_BITS'd0;
            ARSIZE_reg_d  = `AXI_SIZE_BITS'd0;
            ARBURST_reg_d = 2'b00;
            RDATA         = 32'd0;
        end

        WAIT: begin
            unique if (ARVALID) begin
                ARID_reg_d    = ARID;
                ARADDR_reg_d  = ARADDR;
                ARLEN_reg_d   = ARLEN + `AXI_LEN_BITS'd1;
                ARSIZE_reg_d  = ARSIZE;
                ARBURST_reg_d = ARBURST;
                NXSTATE       = READ_WAIT;
            end else begin
                NXSTATE = WAIT;
            end
        end

        READ_WAIT: begin
            ARLEN_reg_d = ARLEN_reg_q - `AXI_LEN_BITS'd1;
            if (ARLEN_reg_d == `AXI_LEN_BITS'd0) begin
                RLAST_reg_d = 1'b1;
            end else begin
                RLAST_reg_d = 1'b0;
            end


            if (ARADDR_reg_q < 32'h2000 && ARSIZE_reg_q < 3'b011) begin
                unique case (ARBURST_reg_q) // Update BO based on OP and assert OE
                2'b00: begin // SINGLE
                    A = ARADDR_reg_q[13:2];
                end

                `AXI_BURST_INC: begin // INCR
                    unique case (ARSIZE_reg_q)
                    `AXI_SIZE_BYTE: begin // LB 
                        A = ARADDR_reg_q[13:2];
                        ARADDR_reg_d = ARADDR_reg_q + (32'd1 << ARSIZE_reg_q);
                    end
                            
                    `AXI_SIZE_HWORD: begin // LH
                        A = ARADDR_reg_q[13:2];
                        ARADDR_reg_d = ARADDR_reg_q + (32'd1 << ARSIZE_reg_q);
                    end
                            
                    `AXI_SIZE_WORD: begin // LW
                        A = ARADDR_reg_q[13:2];
                        ARADDR_reg_d = ARADDR_reg_q + (32'd1 << ARSIZE_reg_q);
                    end

                    default: begin
                        A = 12'd0;
                    end
                    endcase
                end

                default: begin
                    A = 12'd0;
                end
                endcase

                NXSTATE = READ_VALID;

            end else begin

                if ((/*ARADDR_reg_q < 32'h2000*/
                ARADDR_reg_q >= 32'h1_0000 && ARADDR_reg_q < 32'h2_0000
                /* && ARADDR_reg_q >= 32'h1000_0000 && ARADDR_reg_q < 32'h1000_0400 */
                && ARADDR_reg_q >= 32'h2_0000 && ARADDR_reg_q < 32'h3_0000
                && ARADDR_reg_q >= 32'h2000_0000 && ARADDR_reg_q < 32'h2020_0000) || ARSIZE_reg_q >= 3'b011) begin
                    RRESP_reg_d = `AXI_RESP_SLVERR;
                end else begin
                    RRESP_reg_d = `AXI_RESP_DECERR;
                end

                NXSTATE = READ_ERROR;

            end
        end

        READ_VALID: begin
            RLAST  = RLAST_reg_q;
            RRESP  = `AXI_RESP_OKAY;
            RID    = ARID_reg_q;
            RDATA  = DO;
            if (RREADY && RLAST_reg_q) begin
                NXSTATE = READ_LAST;
            end else if (RREADY && !RLAST_reg_q) begin
                NXSTATE = READ_WAIT;
            end else begin
                NXSTATE = READ_VALID_WAIT;
            end
        end
            
        READ_VALID_WAIT: begin
            if (RREADY && RLAST_reg_q) begin
                NXSTATE = READ_LAST;
            end else if (RREADY && !RLAST_reg_q) begin
                NXSTATE = READ_WAIT;
            end else begin
              NXSTATE = READ_VALID_WAIT;
            end
        end

        READ_ERROR: begin
            RRESP  = RRESP_reg_q;
            RID    = ARID_reg_q;
            RLAST  = RLAST_reg_q;
            RDATA  = DO;
            
            if (RREADY && RLAST_reg_q) begin
                NXSTATE = READ_LAST;
            end else if (RREADY && !RLAST_reg_q) begin
                NXSTATE = READ_WAIT;
            end else begin
                NXSTATE = READ_ERROR_WAIT;
            end
        end
            
        READ_ERROR_WAIT: begin
            if (RREADY && RLAST_reg_q) begin
                NXSTATE = READ_LAST;
            end else if(RREADY && !RLAST_reg_q) begin
                NXSTATE = READ_WAIT;
            end else begin
                NXSTATE = READ_ERROR_WAIT;
            end
        end
            
        READ_LAST: begin
            RDATA   = DO;
            RLAST   = 1'b1;
            NXSTATE = INIT;
        end
            
        default: begin
            NXSTATE = INIT;
        end
        endcase
    end

endmodule
