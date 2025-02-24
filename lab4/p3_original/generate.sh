#!/bin/bash

echo "Generating ground truth outputs from original processor"


make clean && make

mkdir -p ground_truth

for source_file in programs/*.s programs/*.c; do
    [ "$source_file" = "programs/crt.s" ] && continue
    program=$(basename "$source_file" | cut -d '.' -f1)
    echo "Running $program"

    # Run simulation with `simv` instead of `simulator`
    ./simv +MEMORY="programs/$program.mem" +WRITEBACK="output/$program.wb" +PIPELINE="output/$program.ppln" > "output/$program.out"

    # Copy BOTH .wb and .out files if they exist
    if [ -f "output/$program.wb" ]; then
        cp "output/$program.wb" "ground_truth/$program.wb"
    else
        echo "WARNING: output/$program.wb not found!"
    fi

    if [ -f "output/$program.out" ]; then
        cp "output/$program.out" "ground_truth/$program.out"
    else
        echo "WARNING: output/$program.out not found!"
    fi
done

echo "Ground truth generation complete."
