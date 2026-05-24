# 0OS - A Minimal x86 Bootloader Operating System

A lightweight, educational x86 16-bit operating system written in assembly language. This project implements a basic bootloader system with two-stage boot, real-mode kernel, and a command interpreter.

## Table of Contents

- [Features](#features)
- [Project Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [Development Setup](#development-setup)
- [Building](#building)
- [Testing](#testing)
- [License](#license)

## Features

- **Two-Stage Bootloader**: Classic bootloader architecture with Stage 1 and Stage 2
- **Real Mode Kernel**: 16-bit x86 real mode OS kernel
- **Command Interface**: Simple command input processor at boot time
- **Assembly-Based**: Pure x86 assembly language implementation
- **Educational**: Designed for learning OS fundamentals and x86 assembly
- **Bootable Disk Image**: Pre-compiled disk image ready to run in emulators

## Project Overview

0OS is a minimal educational operating system that demonstrates the fundamentals of operating system design. It implements:

1. **Stage 1 Bootloader** (boot.asm): Loaded by the BIOS, sets up the system and loads Stage 2
2. **Stage 2 Bootloader** (boot2.asm): Prepares the kernel environment and starts the command interpreter
3. **Kernel Functions** (functions.asm): Common utility functions for printing, input handling, and command processing

The system uses BIOS interrupts for hardware interaction and operates entirely in real mode, providing a transparent view of low-level system operations.

## Prerequisites

To work with 0OS, you will need:

- **Assembler**: NASM (Netwide Assembler) v2.0 or later
- **Emulator** (for testing): QEMU, VirtualBox, Bochs, or similar x86 emulator
- **Development Tools**: 
  - Make (optional, for building)
  - dd or similar disk image tool (for creating bootable media)
- **Knowledge**: Basic understanding of x86 assembly and OS concepts

## Installation

### Running the Pre-Built Disk Image

The easiest way to get started is to use the pre-built disk image:

```bash
# Download the latest disk image
# Available at: https://raw.githubusercontent.com/notvl4d/0OS/main/disk.img

# Boot with QEMU
qemu-system-i386 -drive format=raw,file=disk.img

# Or write to a physical USB drive (Linux/macOS)
# WARNING: Replace /dev/sdX with your actual USB device
sudo dd if=disk.img of=/dev/sdX bs=4M && sync
```

### Building from Source

To build the disk image from assembly source:

```bash
# Assemble Stage 1 bootloader
nasm -f bin boot.asm -o boot.bin

# Assemble Stage 2 bootloader
nasm -f bin boot2.asm -o boot2.bin

# Create a 1.44 MB floppy disk image
dd if=/dev/zero of=disk.img bs=1024 count=1440

# Write Stage 1 to the boot sector
dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc

# Write Stage 2 to sector 2
dd if=boot2.bin of=disk.img bs=512 seek=1 conv=notrunc
```

## Usage

### Booting the System

1. **With QEMU** (recommended):
   ```bash
   qemu-system-i386 -drive format=raw,file=disk.img
   ```

2. **With VirtualBox**:
   - Create a new VM with IDE storage
   - Attach `disk.img` as a virtual hard drive
   - Start the VM

3. **On Physical Hardware**:
   - Write the disk image to a USB drive using `dd` or equivalent
   - Boot from USB (may require BIOS/UEFI configuration)

### Interacting with 0OS

Once the system boots, you will see:

```
Salut!
Apasa orice tasta pentru a continua
```

1. Press any key to continue to Stage 2
2. The system will load Stage 2 and present a command prompt (`$`)
3. Enter characters at the command prompt:
   - **$ symbol** (`$`): Exits the prompt
   - **Enter key**: Processes current input (displays newline and prompt)
   - **Other keys**: Echoes the character to the screen

### Example Session

```
Salut!
Apasa orice tasta pentru a continua
[Press any key]
Stage 2 a fost incarcat.
$hello[Enter]
$_
```

## Project Structure

```
0OS/
├── README.md              # This file
├── boot.asm              # Stage 1 bootloader
├── boot2.asm             # Stage 2 bootloader/kernel
├── functions.asm         # Shared utility functions
└── disk.img              # Pre-built 1.44 MB disk image
```

### File Descriptions

- **boot.asm** (510 bytes):
  - Loaded at `0x7C00` by BIOS
  - Displays welcome message
  - Loads Stage 2 from disk (sector 2) into memory at `0x8000`
  - Jumps to Stage 2

- **boot2.asm** (arbitrary size):
  - Loaded at `0x8000`
  - Displays "Stage 2 loaded" message
  - Implements command input loop
  - Handles keyboard input and displays output

- **functions.asm**:
  - `printf`: Outputs null-terminated strings using BIOS
  - `endl`: Prints newline (CR + LF)
  - `cmdinp`: Command input handler with character-level processing

- **disk.img**:
  - 1.44 MB floppy disk image
  - Boot sector contains Stage 1
  - Sector 2 contains Stage 2

## Architecture

### Memory Layout

```
0x0000 - 0x7BFF  │ BIOS Interrupt Vectors, DOS Boot Block
0x7C00 - 0x7DFF  │ Stage 1 Bootloader (512 bytes)
0x7E00 - 0x7FFF  │ Boot Stack/Scratch Space
0x8000 - ...     │ Stage 2 Bootloader & Kernel
... - 0x9FBFF   │ Extended Conventional Memory
```

### Boot Sequence

```
1. BIOS performs POST
   ↓
2. BIOS loads Sector 1 (512 bytes) to 0x7C00 (boot.asm)
   ↓
3. Stage 1: Initialize system, display messages
   ↓
4. Stage 1: Load Sector 2 (boot2.asm) to 0x8000 using INT 0x13
   ↓
5. Stage 1: Jump to 0x8000
   ↓
6. Stage 2: Display prompt, enter command loop
   ↓
7. Stage 2: Process keyboard input via INT 0x16
   ↓
8. Loop until $ is pressed
```

### BIOS Interrupts Used

- **INT 0x10**: Video BIOS Services
  - Function 0x00: Set video mode (mode 0x03 = 80x25 text)
  - Function 0x0E: Teletype output (print character)
  - Function 0x02: Set cursor position
  - Function 0x03: Read cursor position

- **INT 0x13**: Disk BIOS Services
  - Load sectors from disk into memory

- **INT 0x16**: Keyboard BIOS Services
  - Read keyboard input

## Configuration

### Memory Addresses

Modify these in the assembly files to adjust memory layout:

```asm
# In boot.asm (Stage 1 address)
ORG 0x7C00

# In boot2.asm (Stage 2 address)
ORG 0x8000
```

### Boot Messages

Edit the message strings in each stage:

**boot.asm**:
```asm
mesaj1 db "Salut!",0
mesaj2 db "Apasa orice tasta pentru a continua",0
```

**boot2.asm**:
```asm
msg1 db "Stage 2 a fost incarcat.",0
msg2 db "$",0
```

### Disk Sector Configuration

Modify the disk read parameters in boot.asm:

```asm
mov cl, 0x02      ; Start sector (2 for Stage 2)
mov al, 1         ; Number of sectors to read
mov ch, 0x00      ; Cylinder
mov dh, 0x00      ; Head
mov bx, 0x8000    ; Destination address
```

## Development Setup

### Install Development Tools

**Ubuntu/Debian**:
```bash
sudo apt-get update
sudo apt-get install nasm qemu-system-x86 build-essential
```

**macOS** (Homebrew):
```bash
brew install nasm qemu
```

**Windows** (using Chocolatey):
```powershell
choco install nasm qemu
```

### Clone the Repository

```bash
git clone https://github.com/notvl4d/0OS.git
cd 0OS
```

### Project Layout

```
0OS/
├── boot.asm         # Stage 1 - edit to customize bootloader
├── boot2.asm        # Stage 2 - edit to customize kernel
├── functions.asm    # Shared functions - expand with new utilities
└── disk.img         # Output disk image
```

## Building

### Using NASM Command Line

```bash
# Assemble bootloader
nasm -f bin boot.asm -o boot.bin -l boot.lst

# Assemble second stage
nasm -f bin boot2.asm -o boot2.bin -l boot2.lst

# Create 1.44 MB floppy image
dd if=/dev/zero of=disk.img bs=1024 count=1440

# Write bootloader (sector 1)
dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc

# Write stage 2 (sector 2+)
dd if=boot2.bin of=disk.img bs=512 seek=1 conv=notrunc
```

### Using a Makefile

Create a `Makefile` for easier builds:

```makefile
.PHONY: all clean run

all: disk.img

boot.bin: boot.asm functions.asm
	nasm -f bin boot.asm -o boot.bin

boot2.bin: boot2.asm functions.asm
	nasm -f bin boot2.asm -o boot2.bin

disk.img: boot.bin boot2.bin
	dd if=/dev/zero of=disk.img bs=1024 count=1440
	dd if=boot.bin of=disk.img bs=512 count=1 conv=notrunc
	dd if=boot2.bin of=disk.img bs=512 seek=1 conv=notrunc

run: disk.img
	qemu-system-i386 -drive format=raw,file=disk.img

clean:
	rm -f boot.bin boot2.bin disk.img *.lst
```

Then build with:
```bash
make              # Build disk.img
make run          # Build and run in QEMU
make clean        # Clean build artifacts
```

### Verifying the Build

```bash
# Check disk image size
ls -lh disk.img

# Dump first sector to verify bootloader
xxd -l 512 disk.img | head -20

# Verify boot signature
tail -c 2 disk.img | xxd  # Should show "aa55"
```

## Testing

### Test in QEMU

```bash
# Basic boot test
qemu-system-i386 -drive format=raw,file=disk.img

# With serial output for debugging
qemu-system-i386 -drive format=raw,file=disk.img -serial stdio

# With additional debugging
qemu-system-i386 -drive format=raw,file=disk.img -d int,cpu_reset -D qemu.log

# Headless mode (for scripting)
qemu-system-i386 -drive format=raw,file=disk.img -nographic -serial stdio
```

### Manual Test Checklist

- [ ] Stage 1 displays "Salut!" message
- [ ] Stage 1 displays "Apasa orice tasta pentru a continua"
- [ ] Pressing a key advances to Stage 2
- [ ] Stage 2 displays "Stage 2 a fost incarcat."
- [ ] Command prompt `$` appears
- [ ] Typing characters displays them on screen
- [ ] Pressing Enter creates a newline and shows new prompt
- [ ] Pressing `$` exits the command interpreter

### Testing Boot Signature

```bash
# Should output "aa55" (in hex)
tail -c 2 disk.img | od -A x -t x1
```

### Debugging with QEMU

Enable debugging mode to step through code:

```bash
# Start QEMU with GDB server on port 1234
qemu-system-i386 -drive format=raw,file=disk.img -s -S

# In another terminal, connect with GDB
gdb
(gdb) target remote localhost:1234
(gdb) break *0x7c00
(gdb) continue
(gdb) stepi  # Step instruction
(gdb) info registers
(gdb) x/10i $pc  # Examine next 10 instructions
```

## Development Workflow

### Modifying the Bootloader

1. Edit `boot.asm` or `boot2.asm`
2. Edit `functions.asm` to add/modify shared functions
3. Run `nasm -f bin <file>.asm -o <file>.bin` to assemble
4. Recreate `disk.img` with the new binaries
5. Test in QEMU
6. Debug as needed using QEMU's GDB interface

### Adding New Functions

Add functions to `functions.asm` following the existing pattern:

```asm
myfunction:
    ; Do work here
    ret
```

Call from other modules:
```asm
call myfunction
```

### Common Modifications

**Change video mode**:
```asm
mov al, 0x03  ; Change to other modes (0x00, 0x01, 0x02, etc.)
```

**Extend command buffer**:
```asm
i_buffer db 256 dup(0)  ; Increase from 2 bytes to 256
```

**Add more disk sectors**:
```asm
mov al, 4  ; Read 4 sectors instead of 1
```

## Known Limitations

- **16-bit Real Mode**: Limited to ~1 MB addressable memory
- **No Protected Mode**: Cannot use modern CPU features
- **No Disk Filesystem**: Raw sector access only
- **Minimal Command Support**: Basic character echo only
- **No Multitasking**: Single-threaded execution
- **Single CPU**: No SMP support
- **No Networking**: No network stack

## Future Enhancements

Possible extensions for this project:

- [ ] Protected mode kernel
- [ ] File system support (FAT12/FAT16)
- [ ] Memory management (paging/segmentation)
- [ ] Command parsing and simple commands
- [ ] Interrupt handler extension
- [ ] Disk I/O abstraction layer
- [ ] User/kernel mode separation
- [ ] Simple text editor or utilities
- [ ] Better error handling

## License

This project is provided as-is for educational purposes. Please refer to any LICENSE file in the repository for specific terms.

## References

### x86 Assembly & Architecture
- **Intel x86 Manuals**: https://software.intel.com/content/www/us/en/develop/download/intel-64-and-ia-32-architectures-developer-manual-volume-2a-instruction-set-reference-a-m.html
- **OSDev Wiki**: https://wiki.osdev.org/
- **NASM Documentation**: https://www.nasm.us/doc/

### BIOS Interrupts
- **Ralph Brown's Interrupt List**: http://www.cs.cmu.edu/~ralf/files/interrupt.txt
- **Ralf Brown's Interrupt Reference**: http://www.delorie.com/djgpp/doc/rbinter/

### Bootloaders
- **OSDev Bootloader Guide**: https://wiki.osdev.org/Bootloader
- **Writing a Boot Loader**: https://www.codeproject.com/Articles/36907/Writing-a-boot-loader-in-assembly-language

### Emulators
- **QEMU**: https://www.qemu.org/
- **Bochs**: https://bochs.sourceforge.io/

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test thoroughly in QEMU
5. Commit with clear messages
6. Push to your fork
7. Submit a pull request

## Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Check existing issues for similar problems
- Provide clear reproduction steps
- Include QEMU version and OS details

---

**Disclaimer**: This is an educational project. It is not intended for production use or as a complete operating system. It demonstrates fundamental OS and assembly concepts for learning purposes.

**Last Updated**: 2026
