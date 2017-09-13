rm -f picocode.psm
echo "Preprocessing <picocode.m4> ........"
m4 picocode.m4 > picocode.psm
echo "Compiling <picocode.psm> ......."
./picoasm  -i picocode.psm
