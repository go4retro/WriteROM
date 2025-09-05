# WriteROM

WriteROM accomplishes the impossible, allowing one to write a ROM in place while installed in a circuit without a write line. No flying leads or pigtails are required. WriteROM allows writing to the FLASH using only read accesses.

In normal operation, WriteROM works just like a normal 28 pin JEDEC ROM. However, once a "knock" sequence of reads are performed on the device, the device enters into a programming mode, where address bits 7-0 are interpreted as the data, and bits 11-8 are considered the "operation". The following operations are supported:

| 10:8 | Description                |
| ---- | -------------------------- |
| 0    | set low byte of address    |
| 1    | set middle byte of address |
| 2    | set high byte of address   |
| 6    | read from stored address   |
| 7    | write to address           |

As expected, programming times will be increased due to the additional level of abstraction, but such a device can be cleanly inserted into any memory map, even those not allowing writes to a specific range of memory.

Currently, the design includes a 4Mbit (512kB) FLASH ROM, though the design can be extended to larger sizes if desired.

## License

Copyright (C) 2025 RETRO Innovations

These files are free designs; you can redistribute them and/or modify
them under the terms of the Creative Commons Attribution-ShareAlike 
4.0 International License.

You should have received a copy of the license along with this
work. If not, see http://creativecommons.org/licenses/by-sa/4.0/.

These files are distributed in the hope that they will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
license for more details.
