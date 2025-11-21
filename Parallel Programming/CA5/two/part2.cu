#include <iostream>
#include "opencv2/opencv.hpp"
#include "opencv2/highgui.hpp"
#include <bits/stdc++.h>
#include <sys/time.h>

using namespace std;

__constant__ int kernel_x[9];
__constant__ int kernel_y[9];

__global__ void gpuPart(uchar *img, double *output, int dim_x, int dim_y)
{

    int idx_x = dim_x * blockIdx.x + threadIdx.x + 1;
    int idx_y = dim_x * blockIdx.y + threadIdx.y + 1;

    double out_x = 0;
    double out_y = 0;

    out_x += img[dim_x * (idx_x + 0) + idx_y + 0] * kernel_x[0];
    out_x += img[dim_x * (idx_x + 0) + idx_y + 1] * kernel_x[1];
    out_x += img[dim_x * (idx_x + 0) + idx_y + 2] * kernel_x[2];
    out_x += img[dim_x * (idx_x + 1) + idx_y + 0] * kernel_x[3];
    out_x += img[dim_x * (idx_x + 1) + idx_y + 1] * kernel_x[4];
    out_x += img[dim_x * (idx_x + 1) + idx_y + 2] * kernel_x[5];
    out_x += img[dim_x * (idx_x + 2) + idx_y + 0] * kernel_x[6];
    out_x += img[dim_x * (idx_x + 2) + idx_y + 1] * kernel_x[7];
    out_x += img[dim_x * (idx_x + 2) + idx_y + 2] * kernel_x[8];

    out_y += img[dim_x * (idx_x + 0) + idx_y + 0] * kernel_y[0];
    out_y += img[dim_x * (idx_x + 0) + idx_y + 1] * kernel_y[1];
    out_y += img[dim_x * (idx_x + 0) + idx_y + 2] * kernel_y[2];
    out_y += img[dim_x * (idx_x + 1) + idx_y + 0] * kernel_y[3];
    out_y += img[dim_x * (idx_x + 1) + idx_y + 1] * kernel_y[4];
    out_y += img[dim_x * (idx_x + 1) + idx_y + 2] * kernel_y[5];
    out_y += img[dim_x * (idx_x + 2) + idx_y + 0] * kernel_y[6];
    out_y += img[dim_x * (idx_x + 2) + idx_y + 1] * kernel_y[7];
    out_y += img[dim_x * (idx_x + 2) + idx_y + 2] * kernel_y[8];

    output[dim_x * (idx_x + 1) + idx_y + 1] = (double)sqrt((out_x * out_x) + (out_y * out_y));
}

int main(int argc, char **argv)
{

    cv::Mat img = cv::imread("flower.jpg", 1);
    cv::cvtColor(img, img, cv::COLOR_BGR2GRAY);
    cv::Mat img2 = cv::Mat(img.rows, img.cols, CV_64F);

    struct timeval start, end;
    gettimeofday(&start, NULL);

    int dim_x = img.cols - 2;
    int dim_y = img.rows - 2;

    uchar *input;
    double *output;

    cudaMalloc(&input, sizeof(uchar) * (img.cols * img.rows));
    cudaMalloc(&output, sizeof(double) * (img.cols * img.rows));

    dim3 block(32, 32);
    dim3 grid((dim_x + block.x - 1) / block.x, (dim_y + block.y - 1) / block.y);

    cudaMemcpy(input, img.data, sizeof(uchar) * (img.cols * img.rows), cudaMemcpyHostToDevice);

    int temp_kernel_x[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
    int temp_kernel_y[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};

    cudaMemcpy(kernel_x, &temp_kernel_x, sizeof(int) * 9, cudaMemcpyHostToDevice);
    cudaMemcpy(kernel_y, &temp_kernel_y, sizeof(int) * 9, cudaMemcpyHostToDevice);

    gpuPart<<<grid, block>>>(input, output, img.cols, img.rows);
    cudaDeviceSynchronize();

    cudaMemcpy(img2.data, output, sizeof(double) * (img.cols, img.rows), cudaMemcpyDeviceToHost);

    double max = *max_element(img2.data, img2.data + (img.cols * img.rows));
    for (int i = 0; i < img.cols; i++)
        for (int j = 0; j < img.rows; j++)
            img2.at<double>(j, i) /= max;



    gettimeofday(&end, NULL);
    long seconds = (end.tv_sec - start.tv_sec);
    long micros = ((seconds * 1000000) + end.tv_usec) - (start.tv_usec);
    cout << seconds << " " << micros << endl;

    cv::namedWindow("result", cv::WINDOW_AUTOSIZE);
    cv::imshow("result", img2);
    cv::waitKey(0);
}