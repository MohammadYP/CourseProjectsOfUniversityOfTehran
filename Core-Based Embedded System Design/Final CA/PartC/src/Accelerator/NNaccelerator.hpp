#ifndef NN_HPP_INCLUDE
#define NN_HPP_INCLUDE

#include <systemc.h>
#include "Model.h"
using namespace std;

const int N = 32;

SC_MODULE(NNaccelerator)
{
    sc_in<sc_logic> clk,rst,write,read;
    sn_in<sc_lv<8>> addressIn,dataIn;
    sc_out<sc_lv<8>> dataOut;

    SC_CTOR(NNaccelerator)
    {
        SC_THREAD(operation);
        sensitive << clk << rst << start; 
    }
    void operation();
};


#endif