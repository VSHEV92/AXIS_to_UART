// ---------------------------------------------------
// --------------  AXIS ���������  -------------------
// ---------------------------------------------------
interface AXIS_intf (
    input logic aclk,
    input logic aresetn 
    );

    logic tready;
    logic tvalid;
    logic [7:0] tdata;
    logic [0:0] tuser;

    modport Master (
        input  aclk, aresetn,
        output tdata, tuser, tvalid 
    );

    modport Slave (
        input  aclk, aresetn,
        input  tdata, tvalid,
        output tready
    );

    //-------------------------------------------------------------------------------------
    // ��������� ��������� ������ �� axis � �������� �� mailbox
    task automatic put_forever_to_mailbox(ref mailbox data_mb, ref mailbox parity_err_mb);
        forever begin
            wait (aresetn);
            @(posedge aclk)
            // ���� ������ �������, ������ �� � mailbox
            if(tvalid) begin
                data_mb.put(tdata);
                parity_err_mb.put(tuser);
            end             
        end        
    endtask
    
    //-------------------------------------------------------------------------------------
    // ��������� ��������� ������ �� mailbox � �������� �� �� axis  
    task automatic get_forever_from_mailbox(ref mailbox data_mb);
        logic [7:0] data = 'b0;
        bit new_data = 1'b0; // ���� ����� ������ �� �����
        tvalid = 1'b0;
        forever begin
            wait (aresetn);
            @(posedge aclk)        
            if (!new_data) // �������� ����� ������ � ���������� �� �� �����
                if(data_mb.try_get(data)) begin
                    new_data = 1'b1;
                    tvalid <= 1'b1;
                    tdata <= data;
                end else
                    tvalid <= 1'b0;
            else // �����, ���� tready ����� �������, �������, ��� ������ ��������
                if(tready) begin 
                    new_data = 1'b0;     
                end               
        end        
    endtask

endinterface


// ---------------------------------------------------
// --------------  UART ���������  -------------------
// ---------------------------------------------------
interface UART_intf
    #(
        parameter int BIT_RATE = 115200,    // �������� ������ � ���/�
        parameter int BIT_PER_WORD = 8,     // ����� ��� � ����� ����� ������
        parameter int PARITY_BIT = 0,       // ��� ���������: 0 - none, 1 - odd, 2 - even
        parameter int STOP_BITS_NUM = 1     // ����� ����-���: 1 ��� 2
    )
    (
        input logic aresetn 
    );

    logic RX;
    logic TX;
    
    modport RX_Mod (
        input  RX 
    );
    
    modport TX_Mod (
        output  TX 
    );
    
    //-------------------------------------------------------------------------------------
    // ��������� ��������� ������ �� mailbox � �������� � uart rx
    task automatic get_forever_from_mailbox(ref mailbox data_mb, ref mailbox parity_err_mb);
        parameter bit_len_in_ns = 10e9/BIT_RATE;
        logic [BIT_PER_WORD-1:0] data;
        logic parity_err, parity_bit;
        
        RX = 1; 
        forever begin
            wait (aresetn);     
            // ��������� ������ � ������������ ���� ��������
            data_mb.get(data);
            parity_err_mb.get(parity_err);
            
            if (PARITY_BIT == 1)
                parity_bit = ~(^data);
            else
                parity_bit = ^data;
            
            if (parity_err)
                parity_bit = ~parity_bit;
                
            // ������ ������ � ����� RX    
            #bit_len_in_ns RX = 1'b0; // �����-���
            
            for (int i = 0; i<BIT_PER_WORD; i++) // ������
                #bit_len_in_ns RX = data[i];
            
            if (PARITY_BIT) // ��� ��������
                #bit_len_in_ns RX = parity_bit;
                
            #bit_len_in_ns RX = 1'b1; // ����-���;
            
            if (STOP_BITS_NUM == 2 ) // ������ ����-���
                #bit_len_in_ns RX = 1'b1;
                
            #bit_len_in_ns;                
        end        
    endtask
    
    //-------------------------------------------------------------------------------------
    // ��������� ��������� ������ �� uart � �������� �� � mailbox
    task automatic put_forever_to_mailbox(ref mailbox data_mb, ref mailbox parity_err_mb);
        parameter bit_len_in_ns = 10e9/BIT_RATE;
        logic [BIT_PER_WORD-1:0] data;
        logic parity_err;
        
        forever begin
            wait (aresetn);
            @(negedge TX); // ������� ����� TX
            
            // ���� ��� �������, ����� ������� �� �������� �����-���� 
            #(bit_len_in_ns/2);
            
            // ��������� ���� ������
            for (int i = 0; i<BIT_PER_WORD; i++) // ������
                #bit_len_in_ns data[i] = TX;
            
            // ���� ���� ��� �������� ��������� ���
            if (PARITY_BIT != 0) begin
                #bit_len_in_ns;
                if (PARITY_BIT == 1)
                    parity_err = ~(^{data, TX});
                else
                    parity_err = ^{data, TX};
            end else
                parity_err = 1'b0;
            
            // ���������� �������� ����-����
            #bit_len_in_ns; 
                
            // ������ ������ � ������ ��������
            data_mb.put(data);
            parity_err_mb.put(parity_err);
                       
        end        
    endtask  
    
endinterface    
    