`timescale 1ns / 1ps

module tb_uart_channel;

    reg clk;
    reg reset;
    reg [15:0] divisor;
    reg baud_enable;
    reg [7:0] tx_fifo_data;
    reg tx_fifo_write;
    reg rx_input;

    wire tx_output;
    wire tx_busy;
    wire rx_valid;
    wire [7:0] rx_data;
    wire framing_error;
    wire parity_error;
    wire break_detected;

    sc16is752_uart_channel dut (
        .clk(clk),
        .reset(reset),
        .divisor(divisor),
        .baud_enable(baud_enable),
        .tx_fifo_data(tx_fifo_data),
        .tx_fifo_write(tx_fifo_write),
        .rx_input(rx_input),
        .tx_output(tx_output),
        .tx_busy(tx_busy),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .framing_error(framing_error),
        .parity_error(parity_error),
        .break_detected(break_detected)
    );

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        divisor = 16'd10;
        baud_enable = 1'b1;
        tx_fifo_data = 8'h55;
        tx_fifo_write = 1'b0;
        rx_input = 1'b1;
        #20 reset = 1'b0;
        #50 tx_fifo_write = 1'b1;
        #20 tx_fifo_write = 1'b0;
        #500;
        $display("UART channel tb complete");
        $finish;
    end

    always #5 clk = ~clk;

endmodule
