#!/bin/bash

cd attention_mechanism_32
rm *.o
nasm -f elf32 sse_mulmatrix.nasm
nasm -f elf32 sse_multrasponematrix.nasm
nasm -f elf32 sse_summatvector.nasm
nasm -f elf32 sseutils32.nasm
gcc -m32 -msse -O0 -no-pie *.o att32c.c -o att32.exe -lm
./att32.exe -ds ../test_2048_48_32.ds -wq ../test_48_32_32.wq -wk ../test_48_32_32.wk -wv ../test_48_32_32.wv -bq ../test_32_32.bq -bk ../test_32_32.bk -bv ../test_32_32.bv -si 8 -n 64 -d > output.txt
cd ..


cd attention_mechanism_32_openMP
rm *.o
gcc -m32 -msse -O0 -no-pie -fopenmp ../attention_mechanism_32/*32.o att32c.c -o att32.exe -lm
./att32.exe -ds ../test_2048_48_32.ds -wq ../test_48_32_32.wq -wk ../test_48_32_32.wk -wv ../test_48_32_32.wv -bq ../test_32_32.bq -bk ../test_32_32.bk -bv ../test_32_32.bv -si 8 -n 64 -d > output.txt
cd ..

cd attention_mechanism_64
rm *.o
nasm -f elf64 avx_mulmatrix.nasm
nasm -f elf64 avx_multrasponematrix.nasm
nasm -f elf64 avx_summatvector.nasm
nasm -f elf64 sseutils64.nasm
gcc -m64 -msse -mavx -O0 -no-pie *.o att64c.c -o att64.exe -lm
./att64.exe -ds ../test_2048_48_64.ds -wq ../test_48_32_64.wq -wk ../test_48_32_64.wk -wv ../test_48_32_64.wv -bq ../test_32_64.bq -bk ../test_32_64.bk -bv ../test_32_64.bv -si 8 -n 64 -d > output.txt
cd ..

# cd attention_mechanism_64_openMP
#rm *.o
# gcc -m64 -msse -mavx -O0 -no-pie -fopenmp ../attention_mechanism_64/*.o  att64c.c -o att64.exe -lm
# ./att64.exe -ds ../test_2048_48_64.ds -wq ../test_48_32_64.wq -wk ../test_48_32_64.wk -wv ../test_48_32_64.wv -bq ../test_32_64.bq -bk ../test_32_64.bk -bv ../test_32_64.bv -si 8 -n 64 -d > output.txt
# cd ..
