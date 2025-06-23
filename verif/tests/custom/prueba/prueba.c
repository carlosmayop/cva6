/*
**
** Copyright 2020 OpenHW Group
**
** Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     https://solderpad.org/licenses/
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
*/

#include <stdint.h>
#include <stdio.h>

typedef int32_t i32;
typedef uint32_t u32;
typedef int8_t i8;
typedef uint8_t u8;

u32 xorshift32(u32 seed) {
    u32 x = seed;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return x;
}

// FXMADD
int fxmadd(i32 a, i32 b, i32 c, u8 inm){
    uint64_t mult = a * b;
    uint64_t mult_shifted = mult >> inm;
    return mult_shifted + c;
}

__attribute__((always_inline))
inline i32 __fxmadd(i32 a, i32 b, i32 c, u8 inm) {
    int x;
    const u8 inm_low_bits = inm & 0b111 ;
    const u8 inm_high_bits = (inm >> 3) & 0b11;
    asm volatile(
        ".insn r4 CUSTOM_1, %4, %5, %0, %1, %2, %3\n"
        : "=r" (x)
        : "r" (a), "r" (b), "r" (c), "i" (inm_low_bits), "i" (inm_high_bits)
    );
    return x;
}

__attribute__((always_inline))
inline u8 test_fxmadd(const u8 inm, const u32 ntimes) {
    i32 a = 1, b = 2, c = 3;
    for (int i = 0; i < ntimes; i++) {
        
        a = xorshift32(a);
        b = xorshift32(b);
        c = xorshift32(c);
        
        if (__fxmadd(a, b, c, inm) != fxmadd(a, b, c, inm)) {
            return 1;
        }
		
    }
    return 0;
}

int main(int argc, char* arg[]) {

	return test_fxmadd(2, 10);
	
}
