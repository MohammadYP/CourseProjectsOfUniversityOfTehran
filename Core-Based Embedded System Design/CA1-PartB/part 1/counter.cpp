#include <systemc.h>
using namespace std;

SC_MODULE(uCounterRaEL)
{
    sc_in<sc_logic> rst, clk, cen, pld;
    sc_in<sc_lv<32>> parin;
    sc_out<sc_logic> cout;
    sc_out<sc_lv<32>> cntout;


    SC_CTOR(uCounterRaEL)
    {
        SC_METHOD(counting);
        sensitive << rst << clk;
    }
    void counting();
};

void uCounterRaEL::counting()
{
    if (rst == '1')
    {
        cntout = 0;
    }
    else if (clk->event() && (clk == '1'))
    {
        if (pld == '1')
            cntout = parin;
        else if (cen == '1')
            cntout = cntout->read().to_uint() + 1;
    }

    cout = (cntout->read() == 4294967295) ? sc_logic_1 : sc_logic_0;
}

SC_MODULE(CounterTB)
{

    sc_signal<sc_logic> rst, clk, cen, pld;
    sc_signal<sc_lv<32>> parin;
    sc_signal<sc_logic> cout;
    sc_signal<sc_lv<32>> cntout;

    uCounterRaEL *CNT;

    SC_CTOR(CounterTB)
    {

        // parin = "4294967290";
        CNT = new uCounterRaEL("CNT");
        CNT->clk(clk);
        CNT->rst(rst);
        CNT->cen(cen);
        CNT->pld(pld);
        CNT->parin(parin);
        CNT->cout(cout);
        CNT->cntout(cntout);


        SC_THREAD(inputing);
        SC_THREAD(reseting);
        SC_THREAD(clocking);
        // sensitive << cout.posedge_event();
    }
    void inputing();
    void reseting();
    void clocking();
};

void CounterTB::inputing()
{
    parin = 4294967290;
    pld = SC_LOGIC_0;
    wait(20, SC_NS);
    pld = SC_LOGIC_1;
    wait(100, SC_NS);
    pld = SC_LOGIC_0;
    cen = SC_LOGIC_1;
}

void CounterTB::clocking()
{
    clk = sc_logic('1');
    for (int i = 0; true; i++)
    {
        clk = sc_logic('0');
        wait(50, SC_NS);
        clk = sc_logic('1');
        wait(50, SC_NS);

    }
}

void CounterTB::reseting()
{
    rst = (sc_logic)'0';
    wait(5, SC_NS);
    rst = (sc_logic)'1';
    wait(5, SC_NS);
    rst = (sc_logic)'0';
};

int sc_main(int argc, char *argv[]) 
{
    sc_report_handler::set_actions(SC_ID_VECTOR_CONTAINS_LOGIC_VALUE_, SC_DO_NOTHING);

    CounterTB tb("tb");
    sc_trace_file *vcdfile;
    vcdfile = sc_create_vcd_trace_file("Counter_test");
    sc_trace(vcdfile, tb.clk, "clk");
    sc_trace(vcdfile, tb.rst, "rst");
    sc_trace(vcdfile, tb.pld, "pld");
    sc_trace(vcdfile, tb.cen, "cen");
    sc_trace(vcdfile, tb.parin, "parin");
    sc_trace(vcdfile, tb.cout, "cout");
    sc_trace(vcdfile, tb.cntout, "cntout");
    
    sc_start(1000, SC_NS);
    return 0;
}