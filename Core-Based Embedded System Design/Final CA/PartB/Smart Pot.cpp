#include <iostream>
#include <unistd.h>
#include <cstdlib>
#include <ctime>

using namespace std;

int threshold;
int water_level = 3;

void Timer()
{
    sleep(2);
    cout << "passed 1 hours" << endl;
    cout << "Sampling " << endl;
}

int MoistureSensor()
{
    srand(time(0));
    int moisture = rand() % 15;
    cout << "Moisture : " << moisture << endl;
    return moisture;
}

int WriteMem()
{
    cout << "reading from memory" << endl;
    return threshold;
}

bool WaterLevelSensor()
{
    return water_level;
}

void Pump()
{
    if(water_level == 0)
    {
        cout << "out of water" << endl;
        return;
    }
    
    cout << "pumping water" << endl;
    water_level --;
    

}

void Wireless()
{
    int t;
    cout << "give threshold: ";
    cin >> t;
    threshold = t;
}

int main()
{

    int moisture;
    int thresh;
    
    Wireless(); // interface with application on phone

    while (true)
    {
        cout << endl ;

        Timer();

        moisture = MoistureSensor();

        thresh = WriteMem();

        if(moisture < thresh)
        {
            cout << "Low moisture. Turn on the pump. " << endl;
            Pump();
        }
        else
        {
            cout << "enough moisture. Do nothing." << endl;
        }

        cout << endl ;
           
    }
    return 0;
}