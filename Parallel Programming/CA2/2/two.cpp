#include <iostream>
#include <complex>
#include <SFML/Graphics.hpp>
#include <sys/time.h>
#include <omp.h>

using namespace std;

const int NUM_ITERATION = 1000;
const double X_START = -3.0;
const double X_END = 3.0;
const double Y_START = -3.0;
const double Y_END = 3.0;
const double STEP = 0.001;
const int INT_Y_START = Y_START / STEP;
const int INT_Y_END = Y_END / STEP;
const double SCALE = 2;
const double THRESHOLD = 3;
const int X_RESOLOUTION = 1000;
const int Y_RESOLOUTION = 1000;

const int DOT_SHIFT_X = X_RESOLOUTION / 2;
const int DOT_SHIFT_Y = Y_RESOLOUTION / 2;

int main(int argc, char *argv[])
{

    sf::RenderWindow window(sf::VideoMode(X_RESOLOUTION, Y_RESOLOUTION), "serial");
    // window.clear(sf::Color(0, 0, 255));
    sf::CircleShape dots;
    dots.setRadius(1);
    dots.setFillColor(sf::Color::Red);
    complex<double> c;
    complex<double> z;

    c = complex(-0.7, 0.27015);

    struct timeval start, end;
    gettimeofday(&start, NULL);

    for (double y = Y_START; y < Y_END; y += STEP)
    {
        for (double x = X_START; x < X_END; x += STEP)
        {
            z = complex(x, y);
            
            for (int i = 0; i < NUM_ITERATION; i++)
            {
                z = (z * z) + c;
                if (abs(z) > THRESHOLD)
                    break;
            }
            if (abs(z) <= THRESHOLD)
            {
                dots.setPosition(x * 100 * SCALE + DOT_SHIFT_X, y * 100 * SCALE + DOT_SHIFT_Y);
                window.draw(dots);
            }
        }
    }

    gettimeofday(&end, NULL);
    long seconds = (end.tv_sec - start.tv_sec);
    long micros = ((seconds * 1000000) + end.tv_usec) - (start.tv_usec);
    cout << seconds << " " << micros << endl;
    window.display();

    /////////////////////////////////////////////////////////////////////////

    sf::RenderWindow window2(sf::VideoMode(X_RESOLOUTION, Y_RESOLOUTION), "parallel");
    // window2.clear(sf::Color(0, 0, 255));
    sf::CircleShape dots2;
    dots2.setRadius(1);
    dots2.setFillColor(sf::Color::Red);

    struct timeval start2, end2;
    gettimeofday(&start2, NULL);
    double y;

    #pragma omp parallel for private (z, y) shared(window2, c)
    
        
        for (int int_y = INT_Y_START; int_y < INT_Y_END; int_y += 1)
        {
            y = int_y * STEP;
            for (double x = X_START; x < X_END; x += STEP)
            {
                z = complex(x, y);

                for (int i = 0; i < NUM_ITERATION; i++)
                {
                    z = (z * z) + c;
                    if (std::abs(z) > THRESHOLD)
                        break;
                }

                if (std::abs(z) <= THRESHOLD)
                {
                    #pragma omp critical
                    {
                        dots2.setPosition(x * 100 * SCALE + DOT_SHIFT_X, y * 100 * SCALE + DOT_SHIFT_Y);
                        window2.draw(dots2);
                    }
                }
            }
        }
    

    gettimeofday(&end2, NULL);
    long seconds2 = (end2.tv_sec - start2.tv_sec);
    long micros2 = ((seconds2 * 1000000) + end2.tv_usec) - (start2.tv_usec);
    cout << seconds2 << " " << micros2 << endl;
    window2.display();

    cout << "speed up " << (seconds + (float)micros / 1000000) / (seconds2 + (float)micros2 / 1000000) << endl;
    getchar();
}
