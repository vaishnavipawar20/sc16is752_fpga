`timescale 1ns / 1ps

module sc16is752_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH_LOG2 = 6,
    parameter DEPTH = (1 << DEPTH_LOG2)
) (
    input  wire clk,
    input  wire reset,
    input  wire wr_en,
    input  wire rd_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire full,
    output wire empty,
    output wire [DEPTH_LOG2:0] count
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [DEPTH_LOG2:0] wr_ptr;
    reg [DEPTH_LOG2:0] rd_ptr;
    reg [DEPTH_LOG2:0] fifo_count;

    assign full  = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);
    assign count = fifo_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr      <= {DEPTH_LOG2+1{1'b0}};
            rd_ptr      <= {DEPTH_LOG2+1{1'b0}};
            fifo_count  <= {DEPTH_LOG2+1{1'b0}};
            rd_data     <= {DATA_WIDTH{1'b0}};
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[DEPTH_LOG2-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1;
                if (!rd_en || !empty) begin
                    fifo_count <= fifo_count + 1;
                end
            end

            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr[DEPTH_LOG2-1:0]];
                rd_ptr <= rd_ptr + 1;
                fifo_count <= fifo_count - 1;
            end
        end
    end

endmodule
