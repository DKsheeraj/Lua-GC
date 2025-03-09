# Build targets
all: fullgc incremental_gc generational_gc nogc

# Build fullgc executable
fullgc: 
	gcc -g -o fullgc fullgc.c -llua -lm -ldl

# Build incremental_gc executable
incremental_gc: 
	gcc -g -o incremental_gc incrementalgc.c -llua -lm -ldl

# Build generational_gc executable
generational_gc: 
	gcc -g -o generational_gc generationalgc.c -llua -lm -ldl

nogc:
	gcc -g -o nogc nogc.c -llua -lm -ldl

# Run profiling with Callgrind
callgrind: fullgc incremental_gc generational_gc
	valgrind --tool=callgrind --callgrind-out-file=fullgc.callgrind ./fullgc
	valgrind --tool=callgrind --callgrind-out-file=incremental_gc.callgrind ./incremental_gc
	valgrind --tool=callgrind --callgrind-out-file=generational_gc.callgrind ./generational_gc

# Convert Callgrind output to DOT format using gprof2dot
dot: fullgc.callgrind incremental_gc.callgrind generational_gc.callgrind
	gprof2dot -f callgrind fullgc.callgrind -o fullgc.dot
	gprof2dot -f callgrind incremental_gc.callgrind -o incremental_gc.dot
	gprof2dot -f callgrind generational_gc.callgrind -o generational_gc.dot

# Generate PNG images from DOT files
png: fullgc.dot incremental_gc.dot generational_gc.dot
	dot -Tpng fullgc.dot -o fullgc.png
	dot -Tpng incremental_gc.dot -o incremental_gc.png
	dot -Tpng generational_gc.dot -o generational_gc.png


summary: fullgc.callgrind incremental_gc.callgrind generational_gc.callgrind
	callgrind_annotate fullgc.callgrind > fullgc_summary.txt
	callgrind_annotate incremental_gc.callgrind > incremental_gc_summary.txt
	callgrind_annotate generational_gc.callgrind > generational_gc_summary.txt

perf: 
	perf stat -e branch-misses,page-faults,cache-misses,instructions,cycles ./fullgc
	perf stat -e branch-misses,page-faults,cache-misses,instructions,cycles ./incremental_gc
	perf stat -e branch-misses,page-faults,cache-misses,instructions,cycles ./generational_gc
	perf stat -e branch-misses,page-faults,cache-misses,instructions,cycles ./nogc



# Clean up generated files
clean:
	rm -f fullgc incremental_gc generational_gc
	rm -f *.callgrind
	rm -f *.dot
	rm -f *.png
	rm -f *.txt