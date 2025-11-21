#include <stdint.h>
#include <stdio.h>

# define READ_PORT ((volatile uint32_t*)0x01000000)
# define WRITE_PORT ((volatile uint32_t*)0x01000004)
# define GPIO_CNFreg ((volatile uint32_t*)0x01000008)

# define N_FACT_ACC ((volatile uint32_t*)0x10000000)
# define RESULT_FACT_ACC ((volatile uint32_t*)0x10000004)
# define FACT_ACC_CNFreg ((volatile uint32_t*)0x10000008)

__attribute__((interrupt ("machine")))
void m_mode_external_interrupt_handler(void) {
    // disabling interrupt and interrupt_enable gpio
    *GPIO_CNFreg = 0x00000000;

	*N_FACT_ACC = *READ_PORT;
	
	volatile uint32_t *result = (volatile uint32_t *)(0x00100000);

    *FACT_ACC_CNFreg = 0x00000003;

    while(*FACT_ACC_CNFreg != 0x00000005){
    }
    *FACT_ACC_CNFreg = 0x00000000;

	*result = *RESULT_FACT_ACC;
	*WRITE_PORT = *result;

    // enabling interrupt_enable gpio
    *GPIO_CNFreg = 0x00000001;
}

int main() {
    // Enable machine timer/software/external interrupt in the mie register
    asm volatile("csrs mstatus, %0" : : "r"(0x8)); // Set the MIE (Machine Interrupt Enable) bit in mstatus
    asm volatile("csrs mie, %0" : : "r"(0x800)); // Enable external interrupts in mie (Machine Interrupt Enable)
	
    
    uintptr_t mtvec_value = (uintptr_t)&m_mode_external_interrupt_handler;
    asm volatile("csrw mtvec, %0" : : "r"(mtvec_value));
   
    // enabling interrupt_enable gpio
    *GPIO_CNFreg = 0x00000001;

    while (1) {
	}
        
    return 0;
}

