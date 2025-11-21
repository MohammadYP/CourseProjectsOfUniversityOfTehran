#include <stdint.h>
#include <stdio.h>

__attribute__((interrupt ("machine")))
void m_mode_external_interrupt_handler(void) {
	volatile uint32_t *result = (volatile uint32_t *)(0x00100000);
    int n=10;
    int factorial = 1.0;
        for (int i = 1; i <= n; ++i) {
            factorial *= i;
        }
	* result = factorial;
}

int main() {
    // Enable machine timer/software/external interrupt in the mie register
    asm volatile("csrs mstatus, %0" : : "r"(0x8)); // Set the MIE (Machine Interrupt Enable) bit in mstatus
    asm volatile("csrs mie, %0" : : "r"(0x800)); // Enable external interrupts in mie (Machine Interrupt Enable)
	
    
    uintptr_t mtvec_value = (uintptr_t)&m_mode_external_interrupt_handler;
    asm volatile("csrw mtvec, %0" : : "r"(mtvec_value));
   
    
    while (1) {
	}
        
    return 0;
}

