* Circuit Extracted by Tanner Research's L-Edit Version 8.30 / Extract Version 8.30 ;
* TDB File:  D:\Desktop\Electronic Digital\CA5\part 1\layout 4-nand\4-nand.tdb
* Cell:  Cell0	Version 1.04
* Extract Definition File:  ..\..\L-Edit & S-Edit\L-Edit\Tech\Part1\MHP_N05.EXT
* Extract Date and Time:  01/12/2025 - 09:37
.inc '0.5micron.lib' tt
.param      t=2p
* Warning:  Layers with Unassigned AREA Capacitance.
*   <poly wire>
*   <subs>
*   <n well wire>
*   <P Diff Resistor>
*   <N Well Resistor>
*   <N Diff Resistor>
*   <Poly Resistor>
*   <allsubs>
*   <LPNP collector>
*   <LPNP emitter>
*   <Metal1>
*   <Metal1-Tight>
*   <Metal2>
*   <Metal2-Tight>
* Warning:  Layers with Unassigned FRINGE Capacitance.
*   <ndiff>
*   <poly wire>
*   <subs>
*   <pdiff>
*   <n well wire>
*   <P Diff Resistor>
*   <N Well Resistor>
*   <N Diff Resistor>
*   <Poly Resistor>
*   <Pad Comment>
*   <AllMetal1>
*   <allsubs>
*   <LPNP collector>
*   <LPNP emitter>
*   <AllMetal2>
*   <Metal3>
*   <Metal1>
*   <Metal1-Tight>
*   <Metal2>
*   <Metal2-Tight>
* Warning:  Layers with Zero Resistance.
*   <poly wire>
*   <subs>
*   <n well wire>
*   <PMOS Capacitor>
*   <NMOS Capacitor>
*   <cap using Cap-Well>
*   <Pad Comment>
*   <allsubs>
*   <LPNP collector>
*   <LPNP emitter>
*   <Metal1>
*   <Metal1-Tight>
*   <Metal2>
*   <Metal2-Tight>

Cpar1 GND 0 C=131.196f
Cpar2 Out 0 C=283.612f
Cpar3 VDD 0 C=204.246f
Cpar4 4 0 C=39.564f
Cpar5 5 0 C=41.712f
Cpar6 6 0 C=39.564f
* Warning: Node A has zero nodal parasitic capacitance.
* Warning: Node B has zero nodal parasitic capacitance.
* Warning: Node C has zero nodal parasitic capacitance.
* Warning: Node D has zero nodal parasitic capacitance.

M1 Out D VDD VDD PMOS L=2.5u W=8u AD=80p PD=36u AS=36p PS=17u 
* M1 DRAIN GATE SOURCE BULK (67 25 69.5 33) 
M2 VDD C Out VDD PMOS L=2.5u W=8u AD=36p PD=17u AS=38p PS=17.5u 
* M2 DRAIN GATE SOURCE BULK (55.5 25 58 33) 
M3 Out B VDD VDD PMOS L=2.5u W=8u AD=38p PD=17.5u AS=36p PS=17u 
* M3 DRAIN GATE SOURCE BULK (43.5 25 46 33) 
M4 VDD A Out VDD PMOS L=2.5u W=8u AD=36p PD=17u AS=68p PS=33u 
* M4 DRAIN GATE SOURCE BULK (32 25 34.5 33) 
M5 Out D 4 GND NMOS L=2.5u W=8u AD=80p PD=36u AS=36p PS=17u 
* M5 DRAIN GATE SOURCE BULK (67 -3.5 69.5 4.5) 
M6 4 C 5 GND NMOS L=2.5u W=8u AD=36p PD=17u AS=38p PS=17.5u 
* M6 DRAIN GATE SOURCE BULK (55.5 -3.5 58 4.5) 
M7 5 B 6 GND NMOS L=2.5u W=8u AD=38p PD=17.5u AS=36p PS=17u 
* M7 DRAIN GATE SOURCE BULK (43.5 -3.5 46 4.5) 
M8 6 A GND GND NMOS L=2.5u W=8u AD=36p PD=17u AS=68p PS=33u 
* M8 DRAIN GATE SOURCE BULK (32 -3.5 34.5 4.5) 

* Total Nodes: 10
* Total Elements: 14
* Total Number of Shorted Elements not written to the SPICE file: 0
* Extract Elapsed Time: 0 seconds

Vsupply     VDD      0       1

V_A         A       0       PULSE   0       1      0     10f       10f       1600n     3200n
V_B         B       0       PULSE   0       1      0     10f       10f       800n      1600n
V_C         C       0       PULSE   0       1      0     10f       10f       400n      800n
V_D         D       0       PULSE   0       1      0     10f       10f       200n      400n

.option post=2
.tran   1ps    3500ns

.END
