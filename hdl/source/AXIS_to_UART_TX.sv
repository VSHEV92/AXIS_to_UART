`timescale 1ns / 1ps

// модуль реализует прием axi-stream сигнала и выдачу полученных данных по
// uart интерфейсу 

module AXIS_to_UART_TX
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
    input  logic [7:0] tdata,
    input  logic tvalid,
    output logic tready,
    //  uart интерфейс     
    output logic TX     
);

// -----------------------------------------------------------------------------    
enum logic[2:0] {IDLE, START, DATA, PARITY, STOP1, STOP2} State, Next_State;

localparam int Cycle_per_Period = CLK_FREQ * (10**6) / BIT_RATE;

logic [17:0] Clk_Count;
logic Clk_Count_En, Clk_Count_Done;

logic [3:0] Bit_Count;
logic Bit_Count_Done;

logic [BIT_PER_WORD-1:0] Data;

logic Parity_Value, Uart_Out;

// -----------------------------------------------------------------------------    
// входной регистр
always_ff @(posedge aclk)
    if(!aresetn)
        Data <= 'b0;
    else if (tvalid && tready)
        Data <= tdata;

// -----------------------------------------------------------------------------    
// вычисление бита четности
always_comb 
    unique case(PARITY_BIT) 
        0: Parity_Value = 'b0;
        1: Parity_Value = ~(^Data[BIT_PER_WORD-1:0]);  // xor бит данных 
        2: Parity_Value = ^Data[BIT_PER_WORD-1:0]; 
    endcase       
       
// -----------------------------------------------------------------------------    
// счетчик числа циклов
always_ff @(posedge aclk) begin
    if(!aresetn)
        Clk_Count <= 'b0;
    else if(Clk_Count_En) begin
        Clk_Count <= Clk_Count + 1;
        if (Clk_Count == Cycle_per_Period)
            Clk_Count <= 'b0;
    end    
end        
assign Clk_Count_Done = (Clk_Count == Cycle_per_Period) ? 1'b1 : 1'b0; 

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
        TX <= 'b1;
    else 
        TX <= Uart_Out;        
end        
assign tready = (State == IDLE) ? 1'b1 : 1'b0;

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
        IDLE: begin
            Clk_Count_En = 1'b0;
            Uart_Out = 1'b1;
        end
    
        START: begin
            Clk_Count_En = 1'b1;
            Uart_Out = 1'b0;
        end
    
        DATA: begin
            Clk_Count_En = 1'b1;
            Uart_Out = Data[Bit_Count];
        end
        
        PARITY: begin
            Clk_Count_En = 1'b1;
            Uart_Out = Parity_Value;
        end
        
        STOP1, STOP2: begin
            Clk_Count_En = 1'b1;
            Uart_Out = 1'b1;
        end
    endcase

// вычисление следующего состояния
always_comb
    unique case(State)
        IDLE: // ожидание начала передачи
            Next_State = (tvalid) ? START : IDLE;
            
        START: // выдача старт-бита
            Next_State = (Clk_Count_Done) ? DATA : START; 
             
        DATA: // выдача бит данных 
            if (Bit_Count_Done)
                if (PARITY_BIT)
                    Next_State = PARITY;
                else
                    Next_State = STOP1;  
            else
                Next_State = DATA; 
                             
        PARITY: // выдача бита четности
            Next_State = (Clk_Count_Done) ? STOP1 : PARITY; 
            
        STOP1: // выдача первого стоп-бита
            if (Clk_Count_Done)
                if (STOP_BITS_NUM == 1)
                    Next_State = IDLE;
                else
                    Next_State = STOP2;  
            else
                Next_State = STOP1; 
            
        STOP2: // выдача второго стоп-бита
            Next_State = (Clk_Count_Done) ? IDLE : STOP2;        
    endcase
    
endmodule
