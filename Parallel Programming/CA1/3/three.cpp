// mohammad moein joniedi 810100113
// mohammad yahyapour 810100234

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
    int chunk_size = str.size() / 16;

    char *my_str[16];
    for (int i = 0; i < 16; i++)
        my_str[i] = &str[i * chunk_size];

    char tempo[16];
    unsigned char counter[16] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    __m128i a, b, c, count;
    __m128i d = _mm_set1_epi8(1);

    string output[16] = {"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""};
    vector<vector<int>> output_num = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}};

    intVec tmp, tmpa, tmpb;

    for (int j = 0; j < 16; j++)
        tempo[j] = my_str[j][0];
    b = _mm_load_si128((__m128i *)tempo);

    for (int i = 0; i < chunk_size - 1; i++)
    {
        a = b;

        for (int j = 0; j < 16; j++)
            tempo[j] = my_str[j][i + 1];
        b = _mm_load_si128((__m128i *)tempo);
        c = _mm_cmpeq_epi8(a, b);
        tmp.int128 = c;

        count = _mm_load_si128((__m128i *)&counter);
        count = _mm_adds_epu8(count, _mm_and_si128(c, d));

        _mm_store_si128((__m128i *)counter, count);

        for (int k = 0; k < 16; k++)
        {
            if (tmp.m128_u8[k] == 0x00)
            {
                output[k] += my_str[k][i];
                output_num[k].push_back(counter[k]);
                counter[k] = 1;
            }
            // cout <<(int)counter[k]<< endl;
        }

        // if (i == chunk_size - 2)
        // {
        //     for (int k = 0; k < 16; k++)
        //     {
        //         output[k] += my_str[k][i + 1];
        //         output_num[k].push_back(counter[k]);
        //     }
        // }
    }

    for (int k = 0; k < 16; k++)
    {
        output[k] += my_str[k][chunk_size - 1];
        output_num[k].push_back(counter[k]);
    }

    // for (int j = 0; j < 16; j++)
    //     cout << output[j] << endl;

    output_num[15][output[15].size() - 1] = output_num[15][output[15].size() - 1] - n;
    int temp_num = 0;
    string merged_str = "";
    bool flag = false;
    for (int i = 0; i < 16; i++)
    {
        for (int j = 0; j < output[i].size(); j++)
        {
            if (flag == true)
            {
                // if (i != 15 && output[i + 1].size() == 1 && merged_str[merged_str.size() - 1] == output[i + 1][0])
                if (i != 15 && merged_str[merged_str.size() - 1] == output[i + 1][0])
                {
                    temp_num += output_num[i + 1][0];
                }
                else
                {
                    merged_str += to_string(temp_num);
                    flag = false;
                }
            }

            else if (j == output[i].size() - 1 && output[i][j] == output[i + 1][0])
            {
                merged_str += output[i][j];
                temp_num = output_num[i][j] + output_num[i + 1][0];
                // merged_str += to_string(output_num[i][j] + output_num[i + 1][0]);
                flag = true;
            }
            else
            {
                merged_str += output[i][j];
                merged_str += to_string(output_num[i][j]);
            }
        }
    }

    cout << merged_str << endl;

    gettimeofday(&end2, NULL);
    long seconds2 = (end2.tv_sec - start2.tv_sec);
    long micros2 = ((seconds2 * 1000000) + end2.tv_usec) - (start2.tv_usec);
    cout << seconds2 << " " << micros2 << endl;

    cout << "speed up " << (seconds + (float)micros / 1000000) / (seconds2 + (float)micros2 / 1000000) << endl;
}