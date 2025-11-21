// mohammad moein joniedi 810100113
// mohammad yahyapour 810100234

#include <stdio.h>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <iostream>
#include <sys/time.h>
#include <x86intrin.h>

using namespace std;
using namespace cv;

int main(int argc, char **argv)
{
    struct timeval start, end;
    gettimeofday(&start, NULL);
    string filename = "Q4.mp4";
    VideoCapture capture(filename);

    Mat frame1;
    Mat frame2;
    int NROWS = 1080;
    int NCOLS = 1920;
    int ex = static_cast<int>(capture.get(CAP_PROP_FOURCC));
    VideoWriter output_file;
    output_file.open("output.mp4", ex, capture.get(CAP_PROP_FPS), Size(NCOLS, NROWS), true);

    capture >> frame1;
    capture >> frame2;

    Vec3b *dados = new Vec3b[NROWS * NCOLS];

    while (true)
    {
        
        if (frame1.empty() or frame2.empty())
            break;

        for (int i = 0; i < NROWS; i++)
            for (int j = 0; j < NCOLS; j++)
            {
                dados[i * NCOLS + j] = frame2.at<Vec3b>(i, j) - frame1.at<Vec3b>(i, j);
            }

        Mat output(NROWS, NCOLS, CV_8UC3, dados);

        output_file.write(output);
        frame2 = frame1.clone();
        capture >> frame1;

    }
    capture.release();
    output_file.release();
    gettimeofday(&end, NULL);
    long seconds = (end.tv_sec - start.tv_sec);
    long micros = ((seconds * 1000000) + end.tv_usec) - (start.tv_usec);
    cout << seconds << " " << micros << endl;

    /////////////////////////////////////////////////////////////////////////////////////////

    struct timeval start2, end2;
    gettimeofday(&start2, NULL);

    VideoCapture capture2(filename);
    VideoWriter output_file2;
    output_file2.open("output2.mp4", ex, capture2.get(CAP_PROP_FPS), Size(NCOLS, NROWS), true);
    capture2 >> frame1;
    capture2 >> frame2;

    unsigned char temp1[16];
    unsigned char temp2[16];
    __m128i a, b, c;
    unsigned char tempArr[16];

    uchar *dados2 = new uchar[NROWS * NCOLS * 3];
    //Vec3b *dados3 = new Vec3b[NROWS * NCOLS];

    while (true)
    {

        if (frame1.empty() or frame2.empty())
            break;

        for (int i = 0; i < NROWS; i++)
            for (int j = 0; j < NCOLS * 3; j += 16)
            {

                a = _mm_load_si128((__m128i *)&frame2.at<Vec3b>(i, (j)/3)[(j)%3]);
                b = _mm_load_si128((__m128i *)&frame1.at<Vec3b>(i, (j)/3)[(j)%3]);
                c = _mm_subs_epu8(a, b);
                
                _mm_store_si128((__m128i*)&dados2[i * NCOLS * 3 + j], c);
                
            }
            
        Mat output2(NROWS, NCOLS, CV_8UC3, dados2);
        output_file2.write(output2);
        frame2 = frame1.clone();
        capture2 >> frame1;
        
    }
    capture2.release();
    output_file2.release();

    gettimeofday(&end2, NULL);
    long seconds2 = (end2.tv_sec - start2.tv_sec);
    long micros2 = ((seconds2 * 1000000) + end2.tv_usec) - (start2.tv_usec);
    cout << seconds2 << " " << micros2 << endl;


    cout << "speed up " << (seconds + (float)micros/1000000) / (seconds2 + (float)micros2/1000000)<< endl;
}