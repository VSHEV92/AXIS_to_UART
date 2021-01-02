`timescale 1ns / 1ps
// модуль реализует прием uart сигнала и выдачу полученных данных по
// axi-stream интерфейсу 

module UART_RX_to_AXIS
#(
    parameter int CLK_FREQ = 100,       // тактовая частота в MHz
    parameter int BIT_RATE = 115200,    // скорость данных в бит/с
    parameter int BIT_PER_WORD = 8,     // число бит в одном слове данных
    parameter int PARITY_BIT = 0,       // бит четсности: 0 - none, 1 - odd, 2 - even
    parameter int STOP_BITS_NUM = 1     // число стоп-бит: 1 или 2
)
(
    //  axi-stream интерфейс
    input  logic aclk, aresetn,
    output logic [7:0] tdata,
	output logic tuser, tvalid,
    //  uart интерфейс    
    input logic RX    
);

// -----------------------------------------------------------------------------    
enum logic[2:0] {IDLE, START, DATA, PARITY, STOP1, STOP2, OUT_RDY} State, Next_State;

localparam int Cycle_per_Period = CLK_FREQ * (10**6) / BIT_RATE;
localparam int Cycle_per_Period_Half = Cycle_per_Period/2;

logic RX_Falling;
logic [1:0] RX_Falling_Reg;

logic [17:0] Clk_Count, Clk_Count_Max;
logic Clk_Count_En, Clk_Count_Done;

logic [3:0] Bit_Count;
logic Bit_Count_Done;

logic [BIT_PER_WORD-1:0] Data_Shift_Reg;

logic Parity_Err;

// -----------------------------------------------------------------------------    
// обнаружения спада сигнала RX
always_ff @(posedge aclk) begin
    if(!aresetn)
        RX_Falling_Reg <= 'b1;
    else
        RX_Falling_Reg <= {RX_Falling_Reg[0], RX};  
end        
assign RX_Falling = RX_Falling_Reg[1] & ~RX_Falling_Reg[0];      

// -----------------------------------------------------------------------------    
// счетчик числа циклов
always_ff @(posedge aclk) begin
    if(!aresetn)
        Clk_Count <= 'b0;
    else if(Clk_Count_En) begin
        Clk_Count <= Clk_Count + 1;
        if (Clk_Count == Clk_Count_Max)
            Clk_Count <= 'b0;
    end    
end        
assign Clk_Count_Done = (Clk_Count == Clk_Count_Max) ? 1'b1 : 1'b0; 

// -----------------------------------------------------------------------------    
// счетчик числа принятых бит
always_ff @(posedge aclk) begin
    if(!aresetn)
        Bit_Count <= 'b0;
    else if(Clk_Count_Done && State == DATA) begin
        Bit_Count <= Bit_Count + 1;
        if (Bit_Count == BIT_PER_WORD-1)
            Bit_Count <= 'b0;
    end    
end        
assign Bit_Count_Done = (Bit_Count == BIT_PER_WORD-1 && Clk_Count_Done) ? 1'b1 : 1'b0; 

// -----------------------------------------------------------------------------    
// блок выдачи данных
always_ff @(posedge aclk) begin
    if(!aresetn)
        Data_Shift_Reg <= 'b0;
    else if(Clk_Count_Done && State == DATA) 
        Data_Shift_Reg <= {RX, Data_Shift_Reg[BIT_PER_WORD-1:1]};        
end        

assign tdata = Data_Shift_Reg;
assign tuser = Parity_Err;
assign tvalid = (State == OUT_RDY) ? 1'b1 : 1'b0;

// -----------------------------------------------------------------------------    
// вычисление бита четности
always_ff @(posedge aclk) begin
    if(!aresetn)
        Parity_Err <= 'b0;
    else if(Clk_Count_Done && State == PARITY)
        unique case(PARITY_BIT) 
            0: Parity_Err <= 'b0;
            1: Parity_Err <= ~(^{Data_Shift_Reg[BIT_PER_WORD-1:0], RX});  // xor бит данных и бита четности  
            2: Parity_Err <= ^{Data_Shift_Reg[BIT_PER_WORD-1:0], RX}; 
        endcase       
end        

// -----------------------------------------------------------------------------    
// автомат уравления

// смена состояния
always_ff @(posedge aclk) 
    if(!aresetn)
        State <= IDLE;
    else
        State <= Next_State;

// вычисление выходных сигналов
always_comb
    unique case(State)
        IDLE, OUT_RDY: begin
            Clk_Count_En = 1'b0;
            Clk_Count_Max = Cycle_per_Period;
        end
    
        START: begin
            Clk_Count_En = 1'b1;
            Clk_Count_Max = Cycle_per_Period_Half;
        end
    
        DATA, PARITY, STOP1, STOP2: begin
            Clk_Count_En = 1'b1;
            Clk_Count_Max = Cycle_per_Period;
        end
    endcase

// вычисление следующего состояния
always_comb
    unique case(State)
        IDLE: // ожидание начала передачи
            Next_State = (RX_Falling) ? START : IDLE;
            
        START: // прием старт-бита
            Next_State = (Clk_Count_Done) ? DATA : START; 
             
        DATA: // прием бит данных 
            if (Bit_Count_Done)
                if (PARITY_BIT)
                    Next_State = PARITY;
                else
                    Next_State = STOP1;  
            else
                Next_State = DATA; 
                             
        PARITY: // прием бита четности
            Next_State = (Clk_Count_Done) ? STOP1 : PARITY; 
            
        STOP1: // прием первого стоп-бита
            if (Clk_Count_Done)
                if (PARITY_BIT == 1)
                    Next_State = OUT_RDY;
                else
                    Next_State = STOP2;  
            else
                Next_State = STOP1; 
            
        STOP2: // прием второго стоп-бита
            Next_State = (Clk_Count_Done) ? OUT_RDY : STOP2;
            
        OUT_RDY: // выдача данных на выход
            Next_State = IDLE;
    endcase

endmodule
