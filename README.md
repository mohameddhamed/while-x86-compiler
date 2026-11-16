# While x86 Compiler

[![CI](https://github.com/mohameddhamed/while-x86-compiler/actions/workflows/ci.yml/badge.svg)](https://github.com/mohameddhamed/while-x86-compiler/actions/workflows/ci.yml)
[![Language: C++11](https://img.shields.io/badge/language-C%2B%2B11-00599C?logo=c%2B%2B)](https://en.cppreference.com/w/cpp/11)
[![Target: x86 NASM](https://img.shields.io/badge/target-32--bit%20x86%20NASM-red.svg)](https://www.nasm.us/)

An authentic Ahead-of-Time (AOT) compiler written in C++ that compiles the While imperative programming language directly into 32-bit x86 NASM assembly and links with an ELF C runtime library.

---

## Compiler Pipeline Architecture

```
                      While Source Code (.while)
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │   Lexical Analysis    │  Flex (while.l)
                     │  - Token stream       │
                     │  - Source line track  │
                     └───────────┬───────────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │   LALR(1) Parsing     │  Bisonc++ (while.y)
                     │  - Grammar validation │
                     │  - Shift-reduce logic │
                     └───────────┬───────────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │   Semantic Analysis   │  semantics.h
                     │  - Symbol table lookup│
                     │  - Type-checking      │
                     │    (integer, boolean) │
                     └───────────┬───────────┘
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │   x86 Code Generator  │  Parser.ih
                     │  - Label synthesis    │
                     │  - Register dispatch  │
                     └───────────┬───────────┘
                                 │
                                 ▼
                     32-bit x86 NASM Assembly (.asm)
                                 │
            ┌────────────────────┴────────────────────┐
            ▼                                         ▼
   ┌─────────────────┐                       ┌─────────────────┐
   │  NASM Assembler │                       │   C Runtime     │
   │  (-f elf32)     │                       │  (runtime/io.c) │
   └────────┬────────┘                       └────────┬────────┘
            │                                         │
            └────────────────────┬────────────────────┘
                                 │ GCC (-m32)
                                 ▼
                        Executable ELF Binary
```

---

## Key Systems Engineering Highlights

### 1. Register Allocation & Code Generation Model
- **Target Architecture:** 32-bit x86 (IA-32) using NASM assembly syntax.
- **Arithmetic & Logic Dispatch:**
  - Evaluates expressions using the accumulator (`eax`) and base register (`ebx`).
  - Integer modulus and division use `div ebx` with sign/zero extension into `edx`.
  - Boolean comparisons (`<`, `>`, `=`, `<=`, `>=`) utilize `cmp` followed by conditional byte sets (`setl`, `setg`, `sete`, etc.) onto `al`.
  - Stack preservation via `push`/`pop` sequences for intermediate subexpression values.
- **Control Flow:** Synthesizes unique assembly jump labels (`label0`, `label1`, ...) for `while-do-done` loops and `if-then-else-endif` branching constructs.

### 2. Semantic Analysis & Type Safety
- Enforces strict static typing (`integer`, `boolean`).
- Symbol table tracks scope, declaration rows, variable types, and allocates memory addresses in the `.bss` uninitialized data section (`resd` for 32-bit integers, `resb` for 8-bit booleans).
- Rejects undeclared variables, duplicate declarations, and type mismatches at compile time with descriptive error diagnostics.

### 3. C Runtime Interoperability
- Follows the standard 32-bit `cdecl` calling convention.
- Interfaces with native C runtime functions in `runtime/io.c`:
  - `read_unsigned()`, `read_signed()`, `read_boolean()`
  - `write_unsigned()`, `write_signed()`, `write_boolean()`

---

## Directory Structure

```
while-x86-compiler/
├── src/                    # Compiler implementation sources
│   ├── while.cc            # Main entry point and file handler
│   ├── while.l             # Flex lexical scanner definition
│   ├── while.y             # Bisonc++ LALR(1) parser grammar & codegen
│   ├── Parser.h            # Parser class declaration
│   ├── Parser.ih           # Parser internal helper methods & codegen logic
│   └── semantics.h         # Symbol table and type descriptor models
├── runtime/                # Native execution runtime
│   └── io.c                # C I/O bridge for 32-bit ELF linking
├── tests/                  # Verification suite
│   ├── 01.ok - 09.ok       # Functional test programs
│   ├── *.syntax-error      # Negative syntax validation tests
│   ├── *.semantic-error    # Negative semantic validation tests
│   └── run_tests.sh        # Automated compilation and execution runner
├── Makefile                # Build system
└── .github/workflows/      # Automated CI workflow on Ubuntu Linux
    └── ci.yml
```

---

## Building and Running

### Prerequisites
On Ubuntu / Debian:
```bash
sudo apt-get update
sudo apt-get install -y flex bisonc++ nasm gcc-multilib g++-multilib make
```

### Build the Compiler
```bash
make all
```

### Run Full Test Suite
```bash
make test
```

### Manual Compilation & Execution Workflow
```bash
# 1. Compile While source to x86 assembly
./bin/while tests/01.ok > tests/01.asm

# 2. Assemble to 32-bit ELF object
nasm -f elf32 tests/01.asm -o tests/01.o

# 3. Link with C runtime
gcc -m32 runtime/io.c tests/01.o -o tests/01.bin

# 4. Run binary
./tests/01.bin
```

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.
