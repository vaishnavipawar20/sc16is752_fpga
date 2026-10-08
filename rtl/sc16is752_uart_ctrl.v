`timescale 1ns/1ps

//==============================================================================
// SC16IS752 UART Control Register Decoder
// Decodes control registers (LCR, MCR, IER, FCR) and produces
// control signals for TX/RX engines
//==============================================================================

module sc16is752_uart_ctrl (
    input  wire clk,
    input  wire reset,

    input  wire [7:0] lcr_in,  // Line Control Register
    input  wire [7:0] mcr_in,  // Modem Control Register
    input  wire [7:0] ier_in,  // Interrupt Enable Register
    input  wire [7:0] fcr_in,  // FIFO Control Register

    // Decoded output signals
    output reg  [3:0] data_bits,
    output reg        parity_enable,
    output reg        parity_odd,
    output reg        stop_1bit,
    output reg        stop_2bit,
    output reg        fifo_enable,
    output reg        rx_fifo_reset,
    output reg        tx_fifo_reset,
    output reg        loopback_enable,
    output reg        rts_enable,
    output reg        cts_enable,
    output reg        xon1_enable,
    output reg        xoff1_enable,
    output reg        xon_any_enable,
    output reg        sw_flow_enable
);

    //
    // LCR (Line Control Register) bit fields:
    // [1:0]   WORDLEN  (00=5, 01=6, 10=7, 11=8 bits)
    // [2]     STOPBIT  (0=1 stop, 1=1.5 or 2 stops)
    // [3]     PEN      (0=no parity, 1=parity enabled)
    // [4]     EPS      (0=odd parity, 1=even parity)
    // [5]     STICKP   (stick parity)
    // [6]     BC       (break control)
    // [7]     DLAB     (divisor latch access)
    //
    // MCR (Modem Control Register) bit fields:
    // [0]     DTR
    // [1]     RTS
    // [2]     OUT1
    // [3]     OUT2
    // [4]     LOOP (loopback enable)
    // [5]     XOFF_DIS (XOFF disable)
    //
    // FCR (FIFO Control Register) bit fields:
    // [0]     FIFO_EN
    // [1]     RX_FIFO_RST
    // [2]     TX_FIFO_RST
    // [5:4]   RX_FIFO_TRIG (00=1, 01=4, 10=8, 11=14)
    //
    // IER (Interrupt Enable Register) bit fields:
    // [0]     RDA_IEN  (RX data available)
    // [1]     THRE_IEN (TX holding register empty)
    // [2]     RLS_IEN  (RX line status)
    // [3]     MSI_IEN  (modem status)
    //

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_bits <= 4'd8;
            parity_enable <= 1'b0;
            parity_odd <= 1'b0;
            stop_1bit <= 1'b1;
            stop_2bit <= 1'b0;
            fifo_enable <= 1'b0;
            rx_fifo_reset <= 1'b0;
            tx_fifo_reset <= 1'b0;
            loopback_enable <= 1'b0;
            rts_enable <= 1'b0;
            cts_enable <= 1'b0;
            xon1_enable <= 1'b0;
            xoff1_enable <= 1'b0;
            xon_any_enable <= 1'b0;
            sw_flow_enable <= 1'b0;
        end else begin
            //------------------------------------------------------------------
            // Decode LCR
            //------------------------------------------------------------------
            case (lcr_in[1:0])
                2'b00: data_bits <= 4'd5;
                2'b01: data_bits <= 4'd6;
                2'b10: data_bits <= 4'd7;
                2'b11: data_bits <= 4'd8;
                default: data_bits <= 4'd8;
            endcase

            // Stop bits
            stop_1bit <= (lcr_in[2] == 1'b0);
            stop_2bit <= (lcr_in[2] == 1'b1);

            // Parity
            parity_enable <= lcr_in[3];
            parity_odd <= (lcr_in[4] == 1'b0);  // 0=odd, 1=even

            //------------------------------------------------------------------
            // Decode MCR
            //------------------------------------------------------------------
            rts_enable <= mcr_in[1];
            cts_enable <= mcr_in[0];
            loopback_enable <= mcr_in[4];

            //------------------------------------------------------------------
            // Decode FCR
            //------------------------------------------------------------------
            fifo_enable <= fcr_in[0];
            rx_fifo_reset <= fcr_in[1];
            tx_fifo_reset <= fcr_in[2];

            //------------------------------------------------------------------
            // Decode IER (basic mapping, extended modes not fully implemented)
            //------------------------------------------------------------------
            xon1_enable <= ier_in[0];
            xoff1_enable <= ier_in[1];
            xon_any_enable <= ier_in[2];
            sw_flow_enable <= ier_in[3];
        end
    end

endmodule
