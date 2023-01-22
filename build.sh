#!/bin/bash

rm *.txt

cd attention_mechanism_32
rm *.o
rm *.txt
nasm -f elf32 sse_mulmatrix.nasm
nasm -f elf32 sse_multrasponematrix.nasm
nasm -f elf32 sse_summatvector.nasm
nasm -f elf32 sseutils32.nasm
gcc -m32 -msse -O0 -no-pie *.o att32c.c -o att32 -lm
./att32 -ds ../test_2048_48_32.ds -wq ../test_48_32_32.wq -wk ../test_48_32_32.wk -wv ../test_48_32_32.wv -bq ../test_32_32.bq -bk ../test_32_32.bk -bv ../test_32_32.bv -si 8 -n 64 -d > output_sse_32.txt
cp *.txt ..
cd ..


cd attention_mechanism_32_openMP
rm *.o
rm *.txt
# gcc -m32 -msse -O0 -no-pie -fopenmp ../attention_mechanism_32/*.o att32_omp.c -o att32_omp -lm
gcc -m32 -msse -O0 -no-pie -fopenmp att32_omp.c -o att32_omp -lm
./att32_omp -ds ../test_2048_48_32.ds -wq ../test_48_32_32.wq -wk ../test_48_32_32.wk -wv ../test_48_32_32.wv -bq ../test_32_32.bq -bk ../test_32_32.bk -bv ../test_32_32.bv -si 8 -n 64 -d > output_omp_32.txt
cp *.txt ..
cd ..

gcc -m32 -msse -O0 -no-pie att32c.c -o att32 -lm
./att32 -ds test_2048_48_32.ds -wq test_48_32_32.wq -wk test_48_32_32.wk -wv test_48_32_32.wv -bq test_32_32.bq -bk test_32_32.bk -bv test_32_32.bv -si 8 -n 64 -d > output_32_c.txt

cd attention_mechanism_64
rm *.o
rm *.txt
nasm -f elf64 avx_mulmatrix.nasm
nasm -f elf64 avx_multrasponematrix.nasm
nasm -f elf64 avx_summatvector.nasm
nasm -f elf64 sseutils64.nasm
gcc -m64 -msse -mavx -O0 -no-pie *.o att64c.c -o att64 -lm
./att64 -ds ../test_2048_48_64.ds -wq ../test_48_32_64.wq -wk ../test_48_32_64.wk -wv ../test_48_32_64.wv -bq ../test_32_64.bq -bk ../test_32_64.bk -bv ../test_32_64.bv -si 8 -n 64 -d > output_avx_64.txt
cp *.txt ..
cd ..

cd attention_mechanism_64_openMP
rm *.o
rm *.txt
# gcc -m64 -msse -mavx -O0 -no-pie -fopenmp ../attention_mechanism_64/*.o  att64_omp.c -o att64_omp -lm
gcc -m64 -msse -mavx -O0 -no-pie -fopenmp att64_omp.c -o att64_omp -lm
./att64_omp -ds ../test_2048_48_64.ds -wq ../test_48_32_64.wq -wk ../test_48_32_64.wk -wv ../test_48_32_64.wv -bq ../test_32_64.bq -bk ../test_32_64.bk -bv ../test_32_64.bv -si 8 -n 64 -d > output_omp_64.txt
cp *.txt ..
cd ..

gcc -m64 -msse -mavx -O0 -no-pie att64c.c -o att64 -lm
./att64 -ds test_2048_48_64.ds -wq test_48_32_64.wq -wk test_48_32_64.wk -wv test_48_32_64.wv -bq test_32_64.bq -bk test_32_64.bk -bv test_32_64.bv -si 8 -n 64 -d > output_64_c.txt

for filename in ./*.txt; do
    echo ""
    echo "results from file: "$filename;
    cat $filename | grep "ATT time = ";
    cat $filename | grep "Done. Differenza media ->"
    echo ""
done
