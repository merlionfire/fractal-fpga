#!/usr/bin/perl -w 
use strict;
use 5.010;

use constant DEBUG => 1 ; 

#---------------------------------------------------------------------------------
#  Usage 
#---------------------------------------------------------------------------------
my $usage = " 
USAGE: $0 <picocode.v> 

"; 
#
#---------------------------------------------------------------------------------
#  Global vars
#---------------------------------------------------------------------------------

my $file_input ; 
my $code_full ;
my $parity_full ; 


#---------------------------------------------------------------------------------
#  Main
#---------------------------------------------------------------------------------
die $usage if @ARGV == 0 ; 

$file_input = shift @ARGV ; 

open( FILE_V, "<$file_input" ) || die "Unable to find file <$file_input>" ;  
open( FILE_BIN, '>:raw', 'picocode.bin' ) or die "Unable to open file picocode.bin" ; 

while (<FILE_V>) {
  # catch module interface   
  if ( /^\s*module/ .. /^\sendmodule/ ) {                                 
      if ( /INIT_.+h(\w+);/ ) {  $code_full     = $1 . $code_full; } 
      if ( /INITP_.+h(\w+);/ ) { $parity_full   = $1 . $parity_full; } 
  }
}  



my $code_idx   =  -4  ; 
my $parity_idx =  -1  ; 

my $code ; 
my $parity ; 

foreach ( 1..512 ) {

   $code  = "0x" .  substr($code_full, $code_idx, 4 ) ; 

   print FILE_BIN pack('s', hex $code  )  ; 

   $parity = hex ( "0x0" . substr($parity_full, $parity_idx, 1 ) ) ; 

   
   print FILE_BIN pack('c', ($parity & 0b0011 ) )   ; 

   $code_idx   = $code_idx - 4 ; 

   $code  = "0x" .  substr($code_full, $code_idx, 4 ) ; 

   print FILE_BIN pack('s', hex $code  )  ; 

   print FILE_BIN pack('c', ($parity >> 2 ) )   ; 

   $code_idx   = $code_idx - 4 ; 

   $parity_idx = $parity_idx - 1 ; 
}   

close FILE_V ; 
close FILE_BIN ;

exit;
#---------------------------------------------------------------------------------
#  Subroutine 
#     print_wires : print wire declarations   
#---------------------------------------------------------------------------------
