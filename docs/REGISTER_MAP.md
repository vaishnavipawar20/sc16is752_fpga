# SC16IS752 Register Map (Planned / Phase 1 Skeleton)

This document is a staged register specification for the FPGA implementation. It is intentionally written as a working specification for the hardware model rather than as a final datasheet clone.

## General register set

The register map below follows the SC16IS752-compatible organization commonly used by the device family. The exact access behavior must be verified against the datasheet when final compatibility is pursued.

| Address | Name | Access | Reset | Notes |
| --- | --- | --- | --- | --- |
| 0x00 | RHR / THR | R/W | x | FIFO read/write port |
| 0x01 | IER | R/W | 0x00 | Interrupt enable |
| 0x02 | IIR / FCR | R/W | 0x00 | Interrupt ID / FIFO control |
| 0x03 | LCR | R/W | 0x1D | Line control |
| 0x04 | MCR | R/W | 0x00 | Modem control |
| 0x05 | LSR | R | 0x60 | Line status |
| 0x06 | MSR | R | 0x00 | Modem status |
| 0x07 | SPR | R/W | 0x00 | Scratchpad |
| 0x08 | TXLVL | R | 0x00 | TX FIFO level |
| 0x09 | RXLVL | R | 0x00 | RX FIFO level |
| 0x0A | IODir | R/W | 0x00 | GPIO direction |
| 0x0B | IOState | R/W | 0x00 | GPIO state |
| 0x0C | IOIntEna | R/W | 0x00 | GPIO interrupt enable |
| 0x0E | IOControl | R/W | 0x00 | GPIO control |
| 0x0F | EFCR | R/W | 0x00 | Enhanced feature control |

## Special register set

| Address | Name | Access | Reset | Notes |
| --- | --- | --- | --- | --- |
| 0x00 | DLL | R/W | 0x00 | Divisor latch low |
| 0x01 | DLH | R/W | 0x00 | Divisor latch high |

## Enhanced register set

The enhanced register block is planned for later phases and is not assumed complete in the Phase 1 skeleton.

- EFR
- XON1
- XON2
- XOFF1
- XOFF2

## Phase 1 implementation status

The current RTL skeleton includes:

- register address decode
- write-enable generation for a subset of the SC16IS752 register map
- SPI access path from address + channel select + read/write bit
- base UART config bits for word length and baud divisor setup

The following features remain staged for later phases:

- full dual-channel bank selection
- complete enhanced register definitions
- complete FIFO status and trigger-level logic
- modem control / status logic
- GPIO interrupt behavior
- software flow control blocks
