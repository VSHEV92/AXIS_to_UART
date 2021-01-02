`timescale 1ns / 1ps

// топ уровень модуля, реализующего преобразование axi-stream в uart и обратно 

module AXIS_to_UART
#(
    parameter CLK_FREQ = 100,       // тактовая частота в MHz
    parameter BIT_RATE = 115200,    // скорость данных в бит/с
    parameter BIT_PER_WORD = 8,     // число бит в одном слове данных
    parameter PARITY_BIT = 0,       // бит четсности: 0 - none, 1 - odd, 2 - even
    parameter STOP_BITS_NUM = 1     // число стоп-бит: 1 или 2
)
(
    input  aclk, aresetn,
    // input axi-stream интерфейс
    input  [7:0] in_tdata,
    input  in_tvalid,
    output in_tready,
    // output axi-stream интерфейс
    output  [7:0] out_tdata,
    output  out_tuser,
    output  out_tvalid,
    //  uart интерфейс     
    input RX,
    output TX   
    );
    
    AXIS_to_UART_TX
    #(
        .CLK_FREQ(CLK_FREQ),       
        .BIT_RATE(BIT_RATE),    
        .BIT_PER_WORD(BIT_PER_WORD),     
        .PARITY_BIT(PARITY_BIT),       
        .STOP_BITS_NUM(STOP_BITS_NUM)    
    )
    TX_Block
    (
        //  axi-stream интерфейс
        .aclk(aclk), 
        .aresetn(aresetn),
        .tdata(in_tdata), 
        .tvalid(in_tvalid),
        .tready(in_tready),
        //  uart интерфейс    
        .TX(TX)  
    );
     
    UART_RX_to_AXIS
    #(
        .CLK_FREQ(CLK_FREQ),       
        .BIT_RATE(BIT_RATE),    
        .BIT_PER_WORD(BIT_PER_WORD),     
        .PARITY_BIT(PARITY_BIT),       
        .STOP_BITS_NUM(STOP_BITS_NUM)    
    )
    RX_Block
    (
        //  axi-stream интерфейс
        .aclk(aclk), 
        .aresetn(aresetn),
        .tdata(out_tdata), 
        .tuser(out_tuser),
        .tvalid(out_tvalid),
        //  uart интерфейс    
        .RX(RX)    
    );    
endmodule
