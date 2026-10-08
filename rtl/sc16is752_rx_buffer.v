`timescale 1ns / 1ps

//==============================================================================
// SC16IS752 RX BUFFER (FIFO)
// - 64-entry dual-port RAM
// - Supports character data + error status (parity, framing, break, overrun)
// - Read/Write pointers with occupancy counter
//==============================================================================

module sc16is752_rx_buffer #(
    parameter DEPTH_LOG2 = 6,
    parameter DEPTH = (1 << DEPTH_LOG2),
    parameter DATA_WIDTH = 11  // 8 bits data + 3 bits error flags
) (
    input  wire clk,
    input  wire reset,
    input  wire wr_en,
    input  wire rd_en,
    input  wire [DATA_WIDTH-1:0] wr_data,  // [10:8] = error flags, [7:0] = data
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire full,
    output wire empty,
    output wire [DEPTH_LOG2:0] count,
    output wire [6:0] rxlvl
);

    // Memory array
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Pointers
    reg [DEPTH_LOG2:0] wr_ptr;
    reg [DEPTH_LOG2:0] rd_ptr;
    reg [DEPTH_LOG2:0] fifo_count;

    integer i;

    // Status signals
    assign full = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);
    assign count = fifo_count;
    assign rxlvl = fifo_count[6:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= {DEPTH_LOG2+1{1'b0}};
            rd_ptr <= {DEPTH_LOG2+1{1'b0}};
            fifo_count <= {DEPTH_LOG2+1{1'b0}};
            rd_data <= {DATA_WIDTH{1'b0}};

            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            // Write side
            if (wr_en && !full) begin
                mem[wr_ptr[DEPTH_LOG2-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read side
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr[DEPTH_LOG2-1:0]];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Count update
            if ((wr_en && !full) && !(rd_en && !empty)) begin
                fifo_count <= fifo_count + 1'b1;
            end else if (!(wr_en && !full) && (rd_en && !empty)) begin
                fifo_count <= fifo_count - 1'b1;
            end
        end
    end

endmodule
