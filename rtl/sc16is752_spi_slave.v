`timescale 1ns / 1ps

module sc16is752_register_file (
    input  wire clk,
    input  wire reset,
    input  wire [7:0] spi_addr,
    input  wire [7:0] spi_data_in,
    input  wire spi_write,
    input  wire spi_read,
    input  wire [1:0] channel_sel,
    output reg  [7:0] reg_data_out,
    output reg  [15:0] divisor_a,
    output reg  [15:0] divisor_b,
    output reg  [7:0] lcr_a,
    output reg  [7:0] lcr_b,
    output reg  [7:0] ier_a,
    output reg  [7:0] ier_b,
    output reg  [7:0] spr_a,
    output reg  [7:0] spr_b,
    output reg  [7:0] thr_a,
    output reg  [7:0] thr_b
);

    localparam REG_RHR_THR = 8'h00;
    localparam REG_IER     = 8'h01;
    localparam REG_IIR_FCR = 8'h02;
    localparam REG_LCR     = 8'h03;
    localparam REG_MCR     = 8'h04;
    localparam REG_LSR     = 8'h05;
    localparam REG_MSR     = 8'h06;
    localparam REG_SPR     = 8'h07;
    localparam REG_DLL     = 8'h00;
    localparam REG_DLH     = 8'h01;

    reg [7:0] regbank_a [0:255];
    reg [7:0] regbank_b [0:255];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 256; i = i + 1) begin
                regbank_a[i] <= 8'd0;
                regbank_b[i] <= 8'd0;
            end
            divisor_a <= 16'd0;
            divisor_b <= 16'd0;
            lcr_a <= 8'h1D;
            lcr_b <= 8'h1D;
            ier_a <= 8'd0;
            ier_b <= 8'd0;
            spr_a <= 8'd0;
            spr_b <= 8'd0;
            thr_a <= 8'd0;
            thr_b <= 8'd0;
            reg_data_out <= 8'd0;
        end else begin
            if (spi_write) begin
                case (channel_sel)
                    2'b00: begin
                        case (spi_addr[3:0])
                            4'h0: begin
                                regbank_a[8'h00] <= spi_data_in;
                                thr_a <= spi_data_in;
                            end
                            4'h1: begin
                                regbank_a[8'h01] <= spi_data_in;
                                ier_a <= spi_data_in;
                            end
                            4'h3: begin
                                regbank_a[8'h03] <= spi_data_in;
                                lcr_a <= spi_data_in;
                            end
                            4'h7: begin
                                regbank_a[8'h07] <= spi_data_in;
                                spr_a <= spi_data_in;
                            end
                            default: begin
                                regbank_a[spi_addr] <= spi_data_in;
                            end
                        endcase
                    end
                    2'b01: begin
                        case (spi_addr[3:0])
                            4'h0: begin
                                regbank_b[8'h00] <= spi_data_in;
                                thr_b <= spi_data_in;
                            end
                            4'h1: begin
                                regbank_b[8'h01] <= spi_data_in;
                                ier_b <= spi_data_in;
                            end
                            4'h3: begin
                                regbank_b[8'h03] <= spi_data_in;
                                lcr_b <= spi_data_in;
                            end
                            4'h7: begin
                                regbank_b[8'h07] <= spi_data_in;
                                spr_b <= spi_data_in;
                            end
                            default: begin
                                regbank_b[spi_addr] <= spi_data_in;
                            end
                        endcase
                    end
                    default: begin
                    end
                endcase
            end

            if (spi_read) begin
                case (channel_sel)
                    2'b00: begin
                        reg_data_out <= regbank_a[spi_addr];
                    end
                    2'b01: begin
                        reg_data_out <= regbank_b[spi_addr];
                    end
                    default: begin
                        reg_data_out <= 8'd0;
                    end
                endcase
            end
        end
    end

endmodule
