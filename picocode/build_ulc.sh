rm -f ulc.psm
rm -f picocode.bin
echo "Preprocessing <ulc.m4> ........"
m4 ulc.m4 > ulc.psm
echo "Compiling <ulc.psm> ......."
./picoasm  -i ulc.psm
./picocode2bin.pl  ulc.v
echo "Binary file picocode.bin has been created successfully" 

# vim -b picocode.bin
# In VIM :%!xxd

