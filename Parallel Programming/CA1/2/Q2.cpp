// mohammad moein joniedi 810100113
// mohammad yahyapour 810100234

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <string>
#include <random>
#include <x86intrin.h>
#include <time.h>
#include <sys/time.h>



using namespace std;

const int ARR_SIZE = 1<<20;

int main() {


  float* arr = new float[ARR_SIZE];

  for (int i = 0; i < ARR_SIZE; i++) {
    float temp;
    temp = static_cast <float> (rand()) / static_cast <float> (RAND_MAX);
    
    arr[i] = temp;
    //cout << arr[i] << endl;
  }
  arr[1] = 10;
  arr[2] = 5;
  arr[3] = 20;

  
    struct timeval start, end;
    gettimeofday(&start, NULL);

  
  float sum = 0;
  for (int i = 0; i < ARR_SIZE; i++) {
    sum += arr[i];
  }
  float avg = sum / ARR_SIZE;

  sum = 0;
  float deviation;
  for (int i = 0; i < ARR_SIZE; i++) {
    float temp = arr[i] - avg;
    sum += pow(temp, 2);
  }
  deviation = sqrt(sum / ARR_SIZE);

  

  int numOfOutlier = 0;
  float Z_score;
  for (int i = 0; i < ARR_SIZE; i++) {
    float temp = (arr[i] - avg) / deviation;
    Z_score = abs(temp);
    if (Z_score > 2.5) {
      numOfOutlier++;
    }
  }

  cout << "Deviation: " << deviation << endl;
  cout << "Average: " << avg << endl;
  cout << "Number of outliers: " << numOfOutlier << endl;
  
  
  gettimeofday(&end, NULL);
  long seconds = (end.tv_sec - start.tv_sec);
  long micros = ((seconds * 1000000) + end.tv_usec) - (start.tv_usec);
  cout << "time: " << seconds << " " << micros << endl;

    

/////////////////////////////////////////////////////////////////////////////////////

    struct timeval start2, end2;
    gettimeofday(&start2, NULL);


  __m128 sum_vec = _mm_setzero_ps();
  for (int i = 0; i < ARR_SIZE; i += 4) {
    __m128 data = _mm_loadu_ps(&arr[i]);
    sum_vec = _mm_add_ps(sum_vec, data);
  }


  float sum_array[4];
  _mm_storeu_ps(sum_array, sum_vec);
  sum = sum_array[0] + sum_array[1] + sum_array[2] + sum_array[3];
  avg = sum / ARR_SIZE;


  __m128 avg_vec = _mm_set1_ps(avg);
  sum_vec = _mm_setzero_ps();

  for (int i = 0; i < ARR_SIZE; i += 4) {
    __m128 data = _mm_loadu_ps(&arr[i]);
    __m128 diff = _mm_sub_ps(data, avg_vec);
    __m128 sq_diff = _mm_mul_ps(diff, diff);
    sum_vec = _mm_add_ps(sum_vec, sq_diff);
  }


  _mm_storeu_ps(sum_array, sum_vec);
  float variance_sum = sum_array[0] + sum_array[1] + sum_array[2] + sum_array[3];
  deviation = sqrt(variance_sum / ARR_SIZE);


  __m128 dev_vec = _mm_set1_ps(deviation);
  __m128 threshold = _mm_set1_ps(2.5f);
  numOfOutlier = 0;
  __m128 absolute = _mm_set1_ps(0x7FFF);

  for (int i = 0; i < ARR_SIZE; i += 4) {
    __m128 data = _mm_loadu_ps(&arr[i]);
    __m128 diff = _mm_sub_ps(data, avg_vec);
    __m128 z_score = _mm_div_ps(diff, dev_vec);
    z_score = _mm_and_ps(z_score, absolute);


    __m128 mask = _mm_cmpgt_ps(z_score, threshold);

    int mask_res = _mm_movemask_ps(mask);
    numOfOutlier += __popcntq(mask_res);

  }

  cout << "Deviation: " << deviation << endl;
  cout << "Average: " << avg << endl;
  cout << "Number of outliers: " << numOfOutlier << endl;

        gettimeofday(&end2, NULL);
    long seconds2 = (end2.tv_sec - start2.tv_sec);
    long micros2 = ((seconds2 * 1000000) + end2.tv_usec) - (start2.tv_usec);
    cout << "time: " << seconds2 << " " << micros2 << endl;

    cout << "speed up " << (seconds + (float)micros / 1000000) / (seconds2 + (float)micros2 / 1000000) << endl;

  delete[] arr;
  return 0;
}
