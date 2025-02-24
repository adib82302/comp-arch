#!/bin/bash

echo "Comparing ground truth outputs to new processor"

cd ~/comp-arch/p3 || { echo "Error: Directory not found"; exit 1; }

mkdir -p output

for source_file in programs/*.s programs/*.c; do
    [ "$source_file" = "programs/crt.s" ] && continue
    program=$(basename "$source_file" | cut -d '.' -f1)
    echo "Running $program"

    # Ensure simv exists
    if [ ! -f "./simv" ]; then
        echo "❌ ERROR: simv not found in p3_implementation/"
        exit 1
    fi

    # Run simulation
    ./simv +MEMORY="programs/$program.mem" +WRITEBACK="output/$program.wb" +PIPELINE="output/$program.ppln" > "output/$program.out"

    # Compare writeback output (.wb)
    echo "Comparing writeback output for $program"
    if diff -u "output/$program.wb" "../p3_original/ground_truth/$program.wb" > "output/$program_wb.diff"; then
        echo "Writeback output for $program: ✅ PASS"
    else
        cat "output/$program_wb.diff"  # Show the exact difference
        echo "Failed"
    fi

    # Compare memory output (.out) only for lines starting with '@@@'
    echo "Comparing memory output for $program"
    grep "^@@@" "output/$program.out" > "output/$program.filtered"
    grep "^@@@" "../p3_original/ground_truth/$program.out" > "output/$program_ground.filtered"

    if diff -u "output/$program.filtered" "output/$program_ground.filtered" > "output/$program_mem.diff"; then
        echo "Memory output for $program: ✅ PASS"
    else
        cat "output/$program_mem.diff"  # Show the exact difference
        echo "Failed"
    fi

    # Clean up temporary filtered files
    rm -f "output/$program.filtered" "output/$program_ground.filtered" "output/$program_wb.diff" "output/$program_mem.diff"

done

echo "Comparison complete."
