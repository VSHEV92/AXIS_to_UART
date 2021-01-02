`timescale 1ns / 1ps

// топ уровень проекта

module uart_loop(
    input clk, reset, rx,
    output tx
    );

// синхронизаторы на входных пинах
reg [1:0] reset_reg, rx_reg; 

// выходной регистр для светодиодов
wire [7:0] rx_data, tx_data;
wire rx_valid, tx_valid, tx_ready; 

always @(posedge clk) begin
    reset_reg <= {reset_reg[0], reset};
    rx_reg    <= {rx_reg[0], rx};
end

UART_to_AXIS_0 Uart_Block (
  .aclk(clk),              
  .aresetn(~reset_reg[1]),        
  .in_tdata(tx_data),      
  .in_tvalid(tx_valid),    
  .in_tready(tx_ready),    
  .out_tdata(rx_data),      
  .out_tvalid(rx_valid),  
  .RX(rx),                  
  .TX(tx)                  
);

axis_data_fifo_0 fifo_inst (
  .s_axis_aresetn(~reset_reg[1]),  
  .s_axis_aclk(clk),        
  .s_axis_tvalid(rx_valid),       
  .s_axis_tdata(rx_data),      
  .m_axis_tvalid(tx_valid),    
  .m_axis_tready(tx_ready),    
  .m_axis_tdata(tx_data)      
);

endmodule
