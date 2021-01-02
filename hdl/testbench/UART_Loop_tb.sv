`timescale 1ns / 1ps
`include "../header/Interfaces.svh"
`include "../header/testbench_settings.svh"
`include "../header/test_set.svh"

// ---------------------------------------------------------------
//------------- тестового окружения для UART Loop ----------------
// ---------------------------------------------------------------
module UART_Loop_tb();
    integer f_result;
    integer f_log;
    
    logic clk = 1'b0;
    logic resetn = 1'b0;
    
    logic uart_line;
    
    // mailbox для данных
    mailbox input_data_mb = new();
    mailbox output_data_mb = new();
    
    // mailbox для ошибок четности
    mailbox parity_err_mb = new();
    
    logic [BIT_PER_WORD-1:0] data_array[DATA_WORDS_NUMB], result_data_array[DATA_WORDS_NUMB];  // массив данных для передачи
    logic parity_err_array [DATA_WORDS_NUMB];                                                  // флаги ошибок четности

// ---------------------------------------------------------------------------------     
    // интерфейсы
    AXIS_intf axis_in(clk, resetn);
    AXIS_intf axis_out(clk, resetn);
    
// ---------------------------------------------------------------------------------            
    // тестируемые модули
    AXIS_to_UART_TX
    #(
        .CLK_FREQ(CLK_FREQ),       
        .BIT_RATE(BIT_RATE),    
        .BIT_PER_WORD(BIT_PER_WORD),     
        .PARITY_BIT(PARITY_BIT),       
        .STOP_BITS_NUM(STOP_BITS_NUM)    
    )
    DUT_TX
    (
        //  axi-stream интерфейс
        .aclk(axis_in.Slave.aclk), 
        .aresetn(axis_in.Slave.aresetn),
        .tdata(axis_in.Slave.tdata), 
        .tvalid(axis_in.Slave.tvalid),
        .tready(axis_in.Slave.tready),
        //  uart интерфейс    
        .TX(uart_line)  
    );
     
    UART_RX_to_AXIS
    #(
        .CLK_FREQ(CLK_FREQ),       
        .BIT_RATE(BIT_RATE),    
        .BIT_PER_WORD(BIT_PER_WORD),     
        .PARITY_BIT(PARITY_BIT),       
        .STOP_BITS_NUM(STOP_BITS_NUM)    
    )
    DUT_RX
    (
        //  axi-stream интерфейс
        .aclk(axis_out.Master.aclk), 
        .aresetn(axis_out.Master.aresetn),
        .tdata(axis_out.Master.tdata), 
        .tuser(axis_out.Master.tuser),
        .tvalid(axis_out.Master.tvalid),
        //  uart интерфейс    
        .RX(uart_line)    
    );
    
// ---------------------------------------------------------------------------------            
// формирование тактового сигнала 
    initial forever
        #(1000.0 / 2 / CLK_FREQ) clk = ~clk; 

// ---------------------------------------------------------------------------------                
// снятие сигнала сброса
    initial 
        #RESET_DEASSERT_DELAY resetn = 1'b1; 
        
// ---------------------------------------------------------------------------------        
// созадние тестовых массивов и запуск передачи
    initial begin
        // созадние тестовых массивов
        for(int i = 0; i < DATA_WORDS_NUMB; i++) begin
            data_array[i] = $urandom_range(2**BIT_PER_WORD - 1, 0);              
        end
        
        fork // запуск процессов передачи и приема данных
            axis_in.get_forever_from_mailbox(input_data_mb);
            axis_out.put_forever_to_mailbox(output_data_mb, parity_err_mb);
        join_none
        
        // запись в mailbox
        for(int i = 0; i < DATA_WORDS_NUMB; i++) begin
            #($urandom_range(DATA_MAX_DELAY, DATA_MIN_DELAY));
            input_data_mb.put(data_array[i]); 
        end
        
        // чтение данных из в mailbox
        for(int i = 0; i < DATA_WORDS_NUMB; i++) begin
            output_data_mb.get(result_data_array[i]);
            parity_err_mb.get(parity_err_array[i]); 
        end
        
        $finish;        
    end

// ---------------------------------------------------------------------------------        
// обработка результатов моделирования
     final begin
        automatic bit test_result = 1;
        automatic string file_path = find_file_path(`__FILE__);
        f_result = $fopen({file_path, "../../log_uart_loop_test/Test_Results.txt"}, "a");
        f_log = $fopen({file_path, "../../log_uart_loop_test/Test_Logs.txt"}, "a");
        
        for (int i = 0; i < DATA_WORDS_NUMB; i++) begin 
            // сравнение полученных данных
            if (result_data_array[i] != data_array[i]) begin
                $display("Data words number %3d not match! Gold value: %h. Result value: %h.", i, data_array[i], result_data_array[i]);
                $fdisplay(f_log, "Data words number %3d not match! Gold value: %h. Result value: %h.", i, data_array[i], result_data_array[i]);
                test_result = 0;
            end
            
            // сравнение бит четности
            if (PARITY_BIT != 0)
                if(parity_err_array[i]) begin
                    $display("Parite error in word number %3d!", i);
                    $fdisplay(f_log, "Parite error in word number %3d!", i);
                    test_result = 0;  
                end
        end
        // вывод результатов тестирования
        $display("-------------------------------------");
        if (test_result) begin
            $display("------------- TEST PASS -------------");
            $fdisplay(f_result, "TEST PASS");
        end else begin
            $display("------------- TEST FAIL -------------");
            $fdisplay(f_result, "TEST FAIL");
        end
        $display("-------------------------------------");
        
        $fclose(f_result);
        $fclose(f_log);    
     end
    
endmodule
