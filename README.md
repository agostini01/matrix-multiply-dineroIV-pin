# Goal

Get graphs such as the ones presented by
* http://hpc2010.hpclatam.org/papers/39jaiio-hpc-10.pdf

# TLDR

```
source setup.sh
cd sparse-matrices
$PIN_ROOT/pin -t $PIN_ROOT/source/tools/SimpleExamples/obj-intel64/pinatrace.so -- ./main -f den -a tests/matrices/64x64_2nz_01.mtx -b tests/matrices/64x64_2nz_02.mtx
cat pinatrace.out| sed -e '1,3d' | awk -v OFS=' ' '{print $2 " " $3 " " $4}' | sed -e 's/\(0x\)[^(1-9a-f)]*\([1-9a-f]\)/\1\2/' | sed '$ d' > memtrace.out
$DINERO_ROOT/dineroIV -l1-isize 16k -l1-dsize 8192 -l1-ibsize 32 -l1-dbsize 16 < memtrace.out
```

# How to run?

Setup the local enviroment with:
* `source setup.sh`

Collect the memtrace file with:
* `$PIN_ROOT/pin -t $PIN_ROOT/source/tools/SimpleExamples/obj-intel64/pinatrace.so -- <your application>`
* Replace `<your application>` with your binary command line, such as `ls`
* This file follows the format:  `"MemInstAddr: R/W MemAddr SizeOfIO Value"`

Extract from the generated trace file the correct information:
* `read file | remove first 3 lines | print columns 2,3,4| format addresses| remove last blank line > print to file`
* `cat pinatrace.out| sed -e '1,3d' | awk -v OFS=' ' '{print $2 " " $3 " " $4}' | sed -e 's/\(0x\)[^(1-9a-f)]*\([1-9a-f]\)/\1\2/' | sed '$ d' > memtrace.out`

Run under dinero

* `$DINERO_ROOT/dineroIV -l1-isize 16k -l1-dsize 8192 -l1-ibsize 32 -l1-dbsize 16 < memtrace.out`

## Note on dinero file format:

In dinero, accesstype is:
*	r  read
*	w  write
*	i  instruction fetch
*	m  miscellaneous (like a read but won't generate prefetch)
*	c  copyback (no invalidate implied)
*	v  invalidate (no copyback implied)
* Address and size are hexadecimal, with optional 0x or 0X prefix.

See `https://cse.buffalo.edu/~rsridhar/courses/cse341/hw/dinero.pdf` for more
information.

# Other pin tools 

These assume a fixed cache design

Data cache:

```
$PIN_ROOT/pin -t $PIN_ROOT/source/tools/Memory/obj-intel64/dcache.so -- /bin/ls
cat dcache.out
```

Instruction cache:
```
$PIN_ROOT/pin -t $PIN_ROOT/source/tools/Memory/obj-intel64/icache.so -- /bin/ls
cat icache.out
```

# Looking into sparse and dense matrices?

This project has interesting implementations for different sparse and dense 
matrices.
* `git clone https://github.com/agostini01/sparse-matrices.git`
  * Original author: `https://github.com/nesro/sparse-matrices`

To run enter the folder and execute:
* `cd sparse-matrices`
* `./main -f den -a tests/matrices/64x64_2nz_01.mtx -b tests/matrices/64x64_2nz_02.mtx  -v`
  * For dense
* `./main -f csr -a tests/matrices/64x64_2nz_01.mtx -b tests/matrices/64x64_2nz_02.mtx  -v`
  * For csr


## Getting the data memory trace and simulating in DineroIV

For a dense example:
```
cd sparse-matrices
$PIN_ROOT/pin -t $PIN_ROOT/source/tools/SimpleExamples/obj-intel64/pinatrace.so -- ./main -f den -a tests/matrices/64x64_2nz_01.mtx -b tests/matrices/64x64_2nz_02.mtx
cat pinatrace.out| sed -e '1,3d' | awk -v OFS=' ' '{print $2 " " $3 " " $4}' | sed -e 's/\(0x\)[^(1-9a-f)]*\([1-9a-f]\)/\1\2/' | sed '$ d' > memtrace.out
$DINERO_ROOT/dineroIV -l1-isize 16k -l1-dsize 8192 -l1-ibsize 32 -l1-dbsize 16 < memtrace.out
```

For a csr example:
```
cd sparse-matrices
$PIN_ROOT/pin -t $PIN_ROOT/source/tools/SimpleExamples/obj-intel64/pinatrace.so -- ./main -f csr -a tests/matrices/64x64_2nz_01.mtx -b tests/matrices/64x64_2nz_02.mtx
cat pinatrace.out| sed -e '1,3d' | awk -v OFS=' ' '{print $2 " " $3 " " $4}' | sed -e 's/\(0x\)[^(1-9a-f)]*\([1-9a-f]\)/\1\2/' | sed '$ d' > memtrace.out
$DINERO_ROOT/dineroIV -l1-isize 16k -l1-dsize 8192 -l1-ibsize 32 -l1-dbsize 16 < memtrace.out
```
