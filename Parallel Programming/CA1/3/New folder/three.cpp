#include <stdio.h>
// #include <opencv2/core/core.hpp>
// #include <opencv2/highgui/highgui.hpp>
#include <vector>
#include <iostream>
#include <sys/time.h>
#include <x86intrin.h>

using namespace std;
typedef union
{
    __m128i int128;
    unsigned char m128_u8[16];
    signed char m128_i8[16];
    unsigned short m128_u16[8];
    signed short m128_i16[8];
} intVec;

int main(int argc, char **argv)
{

    struct timeval start, end;
    gettimeofday(&start, NULL);

    string str = "aaabccccddddddddxhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhllllllllllllllllllllllllllllllllllllllllllllllllllllllloooooooooooooooooooooooooooooooooooppppppppppppppppppppppppppppppppkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffflllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllloooooooooooooooooooooooooooooooooooooooooooooooooooogggggggggggggggggggggggggggggg";
    int i = str.size();
    string letters;
    char kam;
    for (int j = 0; j < i; ++j)
    {
        int count = 1;
        while (str[j] == str[j + 1])
        {
            count++;
            j++;
            kam = str[j];
        }
        letters.push_back(str[j]);
        letters += std::to_string(count);
    }

    gettimeofday(&end, NULL);
    long seconds = (end.tv_sec - start.tv_sec);
    long micros = ((seconds * 1000000) + end.tv_usec) - (start.tv_usec);
    cout << "time: " << seconds << " " << micros << endl;

    cout << letters << endl;

    cout << "ratio: " << ((float)str.size() / (float)letters.size()) << endl;

    //////////////////////////////////////////////////////////////////
    struct timeval start2, end2;
    gettimeofday(&start2, NULL);

    int len = str.size();
    int n = (16 - (len % 16)) % 16;
    string temp = "";

    for (int i = 0; i < n; i++)
        temp += str[len - 1];
    str += temp;

    char tempo[16];
    __m128i a, b, c; //, count;
    intVec tmp, tmpa, tmpb;

    int counter = 0;
    string merged_str = "" ;
    merged_str += str[0];
    char fStr = str[0];

    while (len != 0)
    {
        a = _mm_load_si128((__m128i *)&str[0]);
        b = _mm_set1_epi8(fStr);
        c = _mm_cmpeq_epi8(a, b);
        _mm_store_si128((__m128i*)tempo, c);
        //cout << merged_str << endl;
        for (int k = 0; k < 16; k++)
        {
            //cout << (int)tempo[k] << endl;
            if (len == 0)
                break;
            //cout << tmp.m128_u8[k] << endl;
            
            if (tempo[k] != 0x00)
            {
                //cout << "j" << endl;
                len--;
                counter++;
                str.erase(0, 1);
            }
            else
            {
                merged_str += to_string(counter);
                counter = 0;
                merged_str += str[0];
                fStr = str[0];
                //cout << merged_str << endl;
                break;
            }
            // cout <<(int)counter[k]<< endl;
        }

    }

    merged_str += to_string(counter);

    cout << merged_str << endl;

    gettimeofday(&end2, NULL);
    long seconds2 = (end2.tv_sec - start2.tv_sec);
    long micros2 = ((seconds2 * 1000000) + end2.tv_usec) - (start2.tv_usec);
    cout << seconds2 << " " << micros2 << endl;

    cout << "speed up " << (seconds + (float)micros / 1000000) / (seconds2 + (float)micros2 / 1000000) << endl;
}