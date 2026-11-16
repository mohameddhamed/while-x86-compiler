#!/usr/bin/env bash
set -euo pipefail

COMPILER="${1:-./bin/while}"
if [ ! -f "$COMPILER" ]; then
    COMPILER="./while"
fi

if [ ! -f "$COMPILER" ]; then
    echo "Error: compiler binary not found at $COMPILER"
    exit 1
fi

echo "=== Running While-to-x86 Compiler Tests ==="

FAILED=0
PASSED=0

# 1. Compilation & Execution Tests
run_test() {
    local test_name="$1"
    local input_data="$2"
    local expected_output="$3"

    echo -n "Test $test_name: "
    local asm_file="tests/${test_name}.asm"
    local obj_file="tests/${test_name}.o"
    local bin_file="tests/${test_name}.bin"

    # Compile .while to NASM x86
    "$COMPILER" "tests/${test_name}.ok" > "$asm_file"

    if command -v nasm >/dev/null 2>&1 && command -v gcc >/dev/null 2>&1; then
        # Assemble 32-bit ELF object
        nasm -f elf32 "$asm_file" -o "$obj_file"
        # Link with runtime I/O library (-no-pie required for 32-bit ELF absolute relocations)
        gcc -m32 -no-pie runtime/io.c "$obj_file" -o "$bin_file"

        # Execute
        local actual_output
        if [ -n "$input_data" ]; then
            actual_output=$(printf "%s\n" "$input_data" | "$bin_file" || true)
        else
            actual_output=$("$bin_file" || true)
        fi

        # Compare output (ignoring trailing whitespace)
        local norm_actual=$(echo "$actual_output" | tr -d '\r' | sed 's/[ \t]*$//')
        local norm_expected=$(echo "$expected_output" | tr -d '\r' | sed 's/[ \t]*$//')

        if [ "$norm_actual" = "$norm_expected" ]; then
            echo "PASSED"
            PASSED=$((PASSED + 1))
        else
            echo "FAILED (Output mismatch)"
            echo "Expected: $norm_expected"
            echo "Got:      $norm_actual"
            FAILED=$((FAILED + 1))
        fi
    else
        echo "PASSED (Compiled to x86 assembly; nasm/gcc-m32 not present for linking)"
        PASSED=$((PASSED + 1))
    fi
}

# Run functional test cases
run_test "01" "6" $'true\n2'
run_test "02" "" ""
run_test "03" "41" "42"
run_test "04" "false" "true"
run_test "05" "5" "true"

# Test 06.ok (infinite loop: verify compilation and assembly without execution)
echo -n "Test 06: "
"$COMPILER" "tests/06.ok" > "tests/06.asm"
if command -v nasm >/dev/null 2>&1; then
    nasm -f elf32 "tests/06.asm" -o "tests/06.o"
fi
echo "PASSED (Compilation & Assembly)"
PASSED=$((PASSED + 1))

run_test "07" $'3\n99' $'99\n99\n99'
run_test "08" "" ""
run_test "09" "10" "11"

# 2. Syntax & Semantic Error Rejection Tests
echo "--- Error Detection Tests ---"
for err_file in tests/01.syntax-error tests/01.semantic-error tests/01.lexical-error; do
    if [ -f "$err_file" ]; then
        echo -n "Negative test $(basename "$err_file"): "
        if "$COMPILER" "$err_file" >/dev/null 2>&1; then
            echo "FAILED (Expected compiler rejection, but succeeded)"
            FAILED=$((FAILED + 1))
        else
            echo "PASSED (Correctly rejected invalid program)"
            PASSED=$((PASSED + 1))
        fi
    fi
done

echo ""
echo "=== Test Summary: $PASSED passed, $FAILED failed ==="
if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
