`timescale 1ns / 1ps

module sc16is752_spi_slave (
    input  wire clk,
    input  wire reset,
    input  wire cs_n,
    input  wire sclk,
    input  wire mosi,
    output reg  miso,
    output reg  [7:0] cmd_byte,
    output reg  [7:0] data_byte,
    output reg  cmd_valid,
    output reg  read_req,
    output reg  write_req,
    output reg  [7:0] read_data,
    input  wire [7:0] host_read_data
);

    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [2:0] state;
    reg [7:0] command_buffer;
    reg [7:0] address_buffer;
    reg [7:0] data_buffer;
    reg active;
    reg last_cs;

    localparam SPI_IDLE = 3'd0;
    localparam SPI_CMD  = 3'd1;
    localparam SPI_ADDR = 3'd2;
    localparam SPI_DATA = 3'd3;

    always @(posedge sclk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'd0;
            bit_count <= 4'd0;
            state <= SPI_IDLE;
            active <= 1'b0;
            cmd_valid <= 1'b0;
            read_req <= 1'b0;
            write_req <= 1'b0;
            miso <= 1'bz;
            command_buffer <= 8'd0;
            address_buffer <= 8'd0;
            data_buffer <= 8'd0;
            last_cs <= 1'b1;
        end else if (cs_n == 1'b1) begin
            miso <= 1'bz;
            shift_reg <= 8'd0;
            bit_count <= 4'd0;
            state <= SPI_IDLE;
            cmd_valid <= 1'b0;
            read_req <= 1'b0;
            write_req <= 1'b0;
            active <= 1'b0;
        end else if (cs_n == 1'b0) begin
            active <= 1'b1;
            shift_reg <= {shift_reg[6:0], mosi};
            bit_count <= bit_count + 1'b1;

            if (bit_count == 4'd7) begin
                case (state)
                    SPI_IDLE: begin
                        command_buffer <= {shift_reg[6:0], mosi};
                        state <= SPI_ADDR;
                        cmd_valid <= 1'b1;
                        cmd_byte <= {shift_reg[6:0], mosi};
                    end
                    SPI_ADDR: begin
                        address_buffer <= {shift_reg[6:0], mosi};
                        state <= SPI_DATA;
                    end
                    SPI_DATA: begin
                        data_buffer <= {shift_reg[6:0], mosi};
                        if (command_buffer[7] == 1'b0) begin
                            write_req <= 1'b1;
                        end else begin
                            read_req <= 1'b1;
                        end
                        state <= SPI_IDLE;
                    end
                    default: begin
                        state <= SPI_IDLE;
                    end
                endcase
            end
        end
    end

    always @(negedge sclk or posedge reset) begin
        if (reset) begin
            miso <= 1'b0;
        end else if (cs_n == 1'b0) begin
            if (command_buffer[7] == 1'b1) begin
                miso <= host_read_data[7];
                read_data <= host_read_data;
            end else begin
                miso <= 1'b0;
            end
        end else begin
            miso <= 1'bz;
        end
    end

endmodule
