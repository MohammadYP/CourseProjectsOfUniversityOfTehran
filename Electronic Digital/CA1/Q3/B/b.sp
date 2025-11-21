Q3- PartA CA1
*********Library*********
.lib    'mm018.l'   180nm
********Parts************
M1      V2      V2      0       0       NMOS        L=Lmin    w=W
M2      VDD      VDD     V2     0      NMOS        L=Lmin    w=W
M3      V4      V4      0       0       NMOS        L=Lmin    w=W
M4      V4      V4    VDD     VDD       PMOS        L=Lmin    w=W
Vs      VDD      0       Vsweep

.probe DC V(M1) W
.probe DC V(M3) W
*******PARAMETERS********
.param Lmin=180n
.param W=0.1u
.param Vsweep=3
*******SIMULATION********
.OPTIONS post=2
.DC     W       0.1u       5u       0.01u
.end