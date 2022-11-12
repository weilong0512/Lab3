`include "WaitStateCtr.sv"
`include "def.svh"

module CacheCTRL (
    input PStrobe, PRW,
    output PReady,

    input Hit,
    output Write,
    output CacheDataSelect,
    output PDataSelect,
    output SysDataOE, PDataOE,
    output SysStrobe, SysRW,

    input Reset, Clk
);

wire [1:0] WaitStateCtrInput = `WAITSTATES - 1;
reg LoadWaitStateCtr;
WaitStateCtr WaitStateCtr(
    .Load (LoadWaitStateCtr), // should be modified
    .LoadValue (WaitStateCtrCarry),
    .Carry (WaitStateCtrCarry),
    .Clk (Clk)
    );
reg PReadyEnable;
reg SysStrobe,SysRW;
reg SysDataOE;
reg Write, Ready;
reg CacheDataSelect;
reg PDataSelect, PDataOE;
reg [3:0] State, NextState;

enum [3:0] {
    STATE_IDLE = 0,
    STATE_READ,
    STATE_READMISS,
    STATE_READSYS,
    STATE_READDATA,
    STATE_WRITE,
    STATE_WRITEHIT,
    STATE_WRITEMISS,
    STATE_WRITESYS,
    STATE_WRITEDATA
}State, NextState;


always_ff @ (posedge Clk) begin
    if(Reset) begin
        State <= STATE_IDLE;
    end else begin
        State <= NextState;
    end
end

always_comb begin : CTRL_STATE
    
    unique case(State)
        STATE_IDLE:begin // 要define `READ、`WRITE
            if(PStrobe && & PRW == `READ) begin
                NextState = STATE_READ;
            end else if (PStrobe && PRW ==` WRITE) begin
                NextState = STATE_WRITE;
            end else NextState = STATE_IDLE;

        end

        STATE_READ:begin
            if(Hit) begin
                NextState = STATE_IDLE;
            end else begin
                NextState = STATE_READMISS;
            end 
        end

        STATE_READMISS : begin
            NextState = STATE_READSYS;
        end

        STATE_READSYS : begin
            if(WaitStateCtrCarry) begin
                NextState = STATE_READDATA;
            end else begin
                NextState = STATE_READSYS;
            end 
        end

        STATE_READDATA : begin
            NextState = STATE_IDEL;
        end

        STATE_WRITE : begin
            if (Hit) begin
                NextState = STATE_WRITEHIT;
            end else begin
                NextState = STATE_READMISS;
            end
        end

        STATE_WRITEHIT : begin
            NextState = STATE_WRITESYS;
        end

        STATE_WRITEMISS : begin
            NextState = STATE_WRITESYS;
        end

        STATE_WRITESYS : begin
            if (WaitStateCtrCarry) begin
                NextState = STATE_WRITEDATA;
            end else begin
                NextState = STATE_WRITESYS;
            end
        end

        STATE_WRITEDATA : begin
            NextState = STATE_IDLE;
        end

        default:NextState = STATE_IDLE;

    endcase

end

task OutputVec;
    input [9:0] vector;
    begin
        LoadWaitStateCtr=vector[9];
        PReadyEnable=vector[8];
        Ready=vector[7];
        Write=vector[6];
        SysStrobe=vector[5];
        SysRW=vector[4];
        CacheDataSelect=vector[3]
        PDataSelect=vector[2]
        PDataOE=vector[1]
        SysDataOE=vector[0];
    end
endtask

always_comb begin
    case (State)
        STATE_IDLE: OutputVec(10'b0000000000);
        STATE_READ: OutputVec(10'b0100000010);
        STATE_READMISS: OutputVec(10'b1000110010);
        STATE_READSYS: OutputVec(10'b0000010010);
        STATE_READDATA: OutputVec(10'b0011011110);
        STATE_WRITEHIT: OutputVec(10'b1001101100);
        STATE_WRITE: OutputVec(10'b0100000000);
        STATE_WRITEMISS: OutputVec(10'b1000100001);
        STATE_WRITESYS: OutputVec(10'b0000000001);
        STATE_WRITEDATA: OutputVec(10'b0011001101);
    endcase

    wire PReady = (PReadyEnable && Hit) || Ready;
end


endmodule

