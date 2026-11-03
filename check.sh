#!/bin/bash

all_passed=true

#Loop through test cases.
for i in 1 2 3 4; do
    tc_dir="Testcase${i}"
    diff_dir="Testcase${i}Diff"
    tc_pass=true
    has_diffs=false
    
    #Check all file pairs.
    for f1 in "$tc_dir"/*.1.txt; do
        [ -e "$f1" ] || continue
        
        base=$(basename "$f1" .1.txt)
        f2="$tc_dir/${base}.2.txt"
        out_file="${diff_dir}/${base}Diff.txt"
        
        #If files differ, script.sh must generated a file.
        if ! cmp -s "$f1" "$f2"; then
            has_diffs=true
            if [ ! -d "$diff_dir" ]; then
                echo "Missing script.sh directory: $diff_dir" >&2
                tc_pass=false
            elif [ ! -f "$out_file" ]; then
                echo "Missing script.sh output file: $out_file" >&2
                tc_pass=false
            else
                #Compare contents, skip first two line.
                diff -u "$f1" "$f2" | tail -n +3 > /tmp/expected_$$.txt #$$=ProcessingID
                tail -n +3 "$out_file" > /tmp/actual_$$.txt 2>/dev/null
                
                if ! cmp -s /tmp/expected_$$.txt /tmp/actual_$$.txt; then
                    echo "Content does not match: $out_file" >&2
                    tc_pass=false
                fi
                #Remove temp.
                rm -f /tmp/expected_$$.txt /tmp/actual_$$.txt
            fi
        #If file ! differed, script.sh must not generated a file.
        else
            if [ -f "$out_file" ]; then
                echo "Output file should not exist for identical pair: $out_file" >&2
                tc_pass=false
            fi
        fi
    done
    
    #If all files in directory ! differed, Diff folder must not exist.
    if [ "$has_diffs" = false ] && [ -d "$diff_dir" ]; then
        echo "Directory should not exist: $diff_dir" >&2
        tc_pass=false
    fi
    
    #Print final output.
    if [ "$tc_pass" = true ]; then
        echo "Testcase${i}: PASS"
    else
        echo "Testcase${i}: FAIL"
        all_passed=false
    fi
done

#Exit with code.
if [ "$all_passed" = true ]; then
    exit 0
else
    exit 1
fi