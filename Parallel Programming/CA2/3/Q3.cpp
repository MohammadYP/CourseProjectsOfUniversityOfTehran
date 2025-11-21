#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

int main() {
    long int num_points = 10000000;
    long int points_in_circle = 0;
    double x, y;
    double pi_estimate;
    double start_serial, end_serial, start_parallel, end_parallel;


    srand(time(NULL));

    start_serial = omp_get_wtime();
    for (long int i = 0; i < num_points; i++) {
        x = (double)rand() / RAND_MAX;
        y = (double)rand() / RAND_MAX;


        if (x * x + y * y <= 1.0) {
            points_in_circle++;
        }
    }
    end_serial = omp_get_wtime();
    double delay_serial = end_serial - start_serial;
    printf("Serial Time = %f\n",delay_serial);

    pi_estimate = 4.0 * (double)points_in_circle / num_points;
    printf("Approximate value of Pi = %f\n", pi_estimate);

    points_in_circle = 0;
    pi_estimate = 0;

    start_parallel = omp_get_wtime();
    
#pragma omp parallel for private(x, y) reduction(+:points_in_circle)
    for (long int i = 0; i < num_points; i++) {
        x = (double)rand() / RAND_MAX;
        y = (double)rand() / RAND_MAX;


        if (x * x + y * y <= 1.0) {
            points_in_circle++;
        }
    }

    end_parallel = omp_get_wtime();
    double delay_parallel = end_parallel - start_parallel;
    printf("Parallel Time = %f\n", delay_parallel);

    pi_estimate = 4.0 * (double)points_in_circle / num_points;
    printf("Approximate value of Pi = %f\n\n", pi_estimate);

    double speedup = delay_serial / delay_parallel;

    printf("Speedup = %f\n", speedup);

    return 0;
}

