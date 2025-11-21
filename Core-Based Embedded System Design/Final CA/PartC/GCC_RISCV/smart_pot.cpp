#include <stdint.h>
#include <stdio.h>

#define READ_PORT_TEMPERATURE ((volatile uint32_t *)0xFFFFFF08)
#define READ_PORT_HUMIDITY ((volatile uint32_t *)0xFFFFFF04)

#define WRITE_TIMER ((volatile uint32_t *)0xFFFFF000)
#define READ_INTERRUPT_TIMER ((volatile uint32_t *)0xFFFFF004)

#define WRITE_PUMP ((volatile uint32_t *)0xFFFF0F00)

#define READ_FLS ((volatile uint32_t *)0xFFFF0000)

#define WRITE_SEND_DATA ((volatile uint32_t *)0xFFF10000)
#define START_SEND_DATA ((volatile uint32_t *)0xFFF10004)

#define WRITE_CNF_RECIEVED_DATA ((volatile uint32_t *)0xFFF10000)
#define READ_CNF_RECIEVED_DATA ((volatile uint32_t *)0xFFF00004)
#define READ_RECIEVED_DATA ((volatile uint32_t *)0xFFF00008)

#define FXP_SCALE_BITS 10
#define FXP_SCALE (1 << FXP_SCALE_BITS) // Result is 1024

#define BASE_PUMP_DURATION_MS 20

#define BASE_TEMP_C 25
#define KT_FXP 51 // Fixed-point representation of K_T = 0.05

#define CHECK_TIME 400

int MOISTURE_THRESHOLD = 60

__attribute__((interrupt("machine"))) void m_mode_external_interrupt_handler(void)
{
    if(*READ_CNF_RECIEVED_DATA == 1)
    {
        MOISTURE_THRESHOLD = *READ_RECIEVED_DATA;
    }
}

int32_t calculate_pump_duration_ms_integer(int32_t current_moisture, int32_t current_temp)
{

    if (current_moisture >= MOISTURE_THRESHOLD)
    {
        return 0;
    }

    int32_t factor_moisture_fxp = ((int32_t)(MOISTURE_THRESHOLD - current_moisture) * FXP_SCALE) / MOISTURE_THRESHOLD;

    int32_t factor_temp_fxp = FXP_SCALE + (KT_FXP * (current_temp - BASE_TEMP_C));

    if (factor_temp_fxp < 0)
    {
        factor_temp_fxp = 0;
    }

    int32_t final_duration = (int32_t)BASE_PUMP_DURATION_MS * factor_moisture_fxp;
    final_duration = (final_duration * factor_temp_fxp) >> FXP_SCALE_BITS;
    final_duration = final_duration >> FXP_SCALE_BITS;

    return (int32_t)final_duration;
}

int main()
{
    // Enable machine timer/software/external interrupt in the mie register
    asm volatile("csrs mstatus, %0" : : "r"(0x8)); // Set the MIE (Machine Interrupt Enable) bit in mstatus
    asm volatile("csrs mie, %0" : : "r"(0x800));   // Enable external interrupts in mie (Machine Interrupt Enable)

    uintptr_t mtvec_value = (uintptr_t)&m_mode_external_interrupt_handler;
    asm volatile("csrw mtvec, %0" : : "r"(mtvec_value));

    // enabling interrupt_enable gpio
    // *GPIO_CNFreg = 0x00000001;

    uint32_t Temperature;
    uint32_t Humidity;
    uint32_t FLS;
    // uint32_t TimerIRQ;

    while (1)
    {
        *WRITE_TIMER = CHECK_TIME;

        while (*READ_INTERRUPT_TIMER != 1)
        {
        }

        Temperature = *READ_PORT_TEMPERATURE;
        Humidity = *READ_PORT_HUMIDITY;
        FLS = *READ_FLS;
        // TimerIRQ = *READ_INTERRUPT_TIMER;

        if (FLS < 10)
        {
            // hard warning
        }
        else if (FLS < 20)
        {
            // warning
        }
        else
        {
            int32_t pumpDuration = calculate_pump_duration_ms_integer(Humidity, Temperature);

            if (pumpDuration != 0)
            {
                *WRITE_TIMER = pumpDuration;
                *WRITE_PUMP = 1;
                while (*READ_INTERRUPT_TIMER != 1)
                {
                }
                *WRITE_PUMP = 0;
                
            }

            *WRITE_SEND_DATA = pumpDuration;
            *START_SEND_DATA = 1;

        }
    }

    return 0;
}
