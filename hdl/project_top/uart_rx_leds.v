`timescale 1ns / 1ps

// топ уровень проекта

module uart_rx_leds(
    input clk, reset, rx,
    output reg [7:0] leds
    );

// синхронизаторы на входных пинах
reg [1:0] reset_reg, rx_reg; 

// выходной регистр для светодиодов
wire [7:0] rx_data;
wire rx_valid; 

always @(posedge clk) begin
    reset_reg <= {reset_reg[0], reset};
    rx_reg    <= {rx_reg[0], rx};
end

always @(posedge clk)
    if (rx_valid)
        leds <= rx_data;

UART_to_AXIS_0 Uart_RX (
  .aclk(clk),              
  .aresetn(~reset_reg[1]),        
  .out_tdata(rx_data),    
  .out_tvalid(rx_valid),  
  .RX(rx_reg[1])
);

endmodule
