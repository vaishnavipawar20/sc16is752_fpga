# Verification Plan

This repository is staged in phases. Each phase includes a compile step, simulation check, and targeted validation of the affected logic.

## Phase 1 verification targets

- SPI command byte framing
- register write and read decode
- basic reset behavior
- UART transmission in idle mode
- UART Rx start-bit sampling state machine
- baud generator tick generation

## Recommended simulation flow

1. Run the SPI slave testbench.
2. Run the UART channel testbench.
3. Run a basic loopback testbench.
4. Verify that writes do not affect registers when CS is inactive.
5. Verify that RX data appears in the correct FIFO order.

## Known limitations in this phase

- Dual-channel register file is not yet complete.
- Full datasheet register-reset values are not yet implemented everywhere.
- No complete interrupt priority logic yet.
- No full GPIO, modem control, or flow-control model yet.

## Future validation goals

- 8-N-1, 8-E-1, 8-O-1, 7-N-1, 5-N-1 timing
- FIFO overflow and underflow checks
- CTS/RTS handshaking
- loopback self-test
- interrupt clearing via register access
