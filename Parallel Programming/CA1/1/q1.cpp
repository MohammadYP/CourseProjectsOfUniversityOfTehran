// mohammad moein joniedi 810100113
// mohammad yahyapour 810100234

#include <opencv2/opencv.hpp>
#include <iostream>
#include <xmmintrin.h>
#include <intrin.h>

using namespace cv;
using namespace std;

void blendSerial(const Mat& image, const Mat& logo, Mat& output) {
    for (int y = 0; y < logo.rows; y++) {
        for (int x = 0; x < logo.cols; x++) {
            output.at<Vec3b>(y, x) = (image.at<Vec3b>(y, x) + 0.625 * logo.at<Vec3b>(y, x));
        }
    }
}


void blendSIMD(const Mat& image, const Mat& logo, Mat& output) {
    //const __m128i factor = _mm_set1_ps(0.625f); 
    for (int y = 0; y < logo.rows; y++) {
        for (int x = 0; x < logo.cols * 3; x += 16) {
            __m128i pixelImage = _mm_load_si128((__m128i*) & image.at<Vec3b>(y, (x) / 3)[(x) % 3]);
            __m128i pixelLogo = _mm_load_si128((__m128i*) & logo.at<Vec3b>(y, (x) / 3)[(x) % 3]);

            __m128i fact = _mm_srli_epi16(pixelLogo, 1);
            __m128i lsbZero = _mm_set1_epi8(0x7F);
            __m128i fact1 = _mm_and_si128(lsbZero, fact);
            fact = _mm_srli_epi16(pixelLogo, 3);
            __m128i lsb3Zero = _mm_set1_epi8(0x1F);
            __m128i fact2 = _mm_and_si128(lsb3Zero, fact);

            __m128i factoredLogo = _mm_adds_epu8(fact1, fact2);

            __m128i result = _mm_adds_epu8(pixelImage, factoredLogo);
            _mm_storeu_si128((__m128i*) & output.at<Vec3b>(y, (x) / 3)[(x) % 3], result);
        }
    }
}

int main() {
    Mat image = imread("front.png");
    Mat logo = imread("logo.png");

    if (image.empty() || logo.empty()) {
        cerr << "Error: Could not load images!" << endl;
        return -1;
    }

    resize(logo, logo, Size(160,160));

    Mat outputSerial = image.clone();
    Mat outputSIMD = image.clone();

    double t1 = (double)getTickCount();
    blendSerial(image, logo, outputSerial);
    t1 = ((double)getTickCount() - t1) / getTickFrequency();
    cout << "Serial Time: " << t1 << " seconds" << endl;

    double t2 = (double)getTickCount();
    blendSIMD(image, logo, outputSIMD);
    t2 = ((double)getTickCount() - t2) / getTickFrequency();
    cout << "SIMD Time: " << t2 << " seconds" << endl;
    cout << "Speedup: " << t1 / t2 << endl;

    imshow("Blended Serial", outputSerial);
    imshow("Blended SIMD", outputSIMD);
    waitKey(0);

    imwrite("output_serial.png", outputSerial);
    imwrite("output_simd.png", outputSIMD);


    return 0;
}
