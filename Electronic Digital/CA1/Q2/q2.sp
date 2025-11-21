1- PMOS Q2 CA1
*********Library*********
.lib 'mm018.l' 180nm
********NMOS*************
M1      VD      Vg_node      VDD         VDD         PMOS        L='Lmin'       W='Wn'
Vd     VDD     Vg_node      0.4            
VSD     VDD     VD      0               
VDD     VDD     0       1

.probe DC I(M1) V(VD) 
*******PARAMETERS********
.param Lmin=180n              
.param Wn=4u
*******SIMULATION********

.DC VSD 0 1.5 0.01       

.alter                       
Vd      VDD     Vg_node      0.4
.OPTIONS post=2 nomod file="sim2.sw0"

.alter                        
Vd      VDD     Vg_node      0.6
.OPTIONS post=2 nomod file="sim2.sw1"

.alter                        
Vd      VDD     Vg_node      0.8
.OPTIONS post=2 nomod file="sim2.sw2"

.alter                       
Vd      VDD     Vg_node      1.0
.OPTIONS post=2 nomod file="sim2.sw3"

.end
