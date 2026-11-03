#!/bin/bash

#Loop through test cases.
for i in 1 2 3 4; do
    tc_dir="Testcase${i}"
    diff_dir="Testcase${i}Diff"
    
    #Remove old Diff directory.
    rm -rf "$diff_dir"
    
    #Loop through all .1.txt files in current Testcase.
    for f1 in "$tc_dir"/*.1.txt; do
        #Skip if ! exist
        [ -e "$f1" ] || continue
        
        #Get "base" name.
        base=$(basename "$f1" .1.txt)
        f2="$tc_dir/${base}.2.txt"
        
        #Compare.
        if ! cmp -s "$f1" "$f2"; then
            #File differed so mkdir.
            mkdir -p "$diff_dir"
            
            #Save diff output to file.
            diff -u "$f1" "$f2" > "${diff_dir}/${base}Diff.txt"
        fi
    done
done