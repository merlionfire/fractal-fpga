#!/usr/bin/perl  -w 
use strict;
use 5.010;


#my $cx = 0x08_00_00_00 ;   # 0.5  
#print_float_from_hex ( $cx )  ;  

#$cx = 0xF8_00_00_00 ;      # -0.5
#print_float_from_hex ( $cx )  ;  
#
#$cx = 0x18_00_00_00 ;      #  1.5
#print_float_from_hex ( $cx )  ;  
#
#$cx = 0xe8_00_00_00 ;      #  -1.5 
#print_float_from_hex ( $cx )  ;  
#
#$cx = 0x03_00_00_00 ;      #  9/256
#print_float_from_hex ( $cx )  ;  


my $cx = 0x08_00_00_00 ;    
my $cy = 0xF8_00_00_00 ; 

fractal_calc( $cx, $cy, 10 ) ; 

sub fractal_calc {

   my ( $cx0, $cy0, $iter )   =  @_  ;    
   my $cx  = $cx0 ; 
   my $cx0_float = hex2float( $cx0 ) ; 
   my $cx_float = $cx0_float ; 
   printf "cx=0x%08x => %f\n", $cx, $cx_float ; 

   my $cy  =  $cy0 ;   
   my $cy0_float = hex2float( $cy0 ) ; 
   my $cy_float  = $cy0_float ; 
   printf "cy=0x%08x => %f\n", $cy, $cy_float ; 

   foreach my $round ( 1..$iter ) { 
      printf "Round %0d :\n", $round  ; 
      my $cx2_float = $cx_float * $cx_float ; 
      my $cy2_float = $cy_float * $cy_float ; 
      my $cxy_float = $cx_float * $cy_float ; 
      my $cx2       = $cx * $cx ; 
      my $cy2       = $cy * $cy ; 
      my $cxy       = hex_multiply($cx , $cy ) ;  

      $cx2  =  hex64to32($cx2) ;  
      $cy2  =  hex64to32($cy2) ;  
printf "\tcxy= 0x%016x \n", $cxy ; 
      $cxy  =  hex64to32($cxy) ;  
printf "\tcxy= 0x%016x \n", $cxy ; 


printf "\tcx2= 0x%08x ==> %f\n", $cx2, $cx2_float ; 
printf "\tcy2= 0x%08x ==> %f\n", $cy2, $cy2_float ; 
printf "\tcxy= 0x%08x ==> %f\n", $cxy, $cxy_float ; 

      $cx_float  =  $cx2_float - $cy2_float + $cx0_float ; 
      $cy_float  =  2 * $cxy_float + $cy0_float ; 

      $cx        =  ($cx2 - $cy2 + $cx0 ) & 0xFF_FF_FF_FF; 
      $cy        =  ( $cxy << 2  + $cy0  ) & 0xFF_FF_FF_FF; 
      print "\n" ; 
      printf "\tcx = 0x%08x => %f\n", $cx, $cx_float ; 
      printf "\tcy = 0x%08x => %f\n", $cy, $cy_float ; 
   } 

}


sub print_float_from_hex { 
   my $x = shift @_ ; 
   my $float = hex2float( $x ) ; 
   printf "cx=0x%08x => %f\n", $x, $float ; 
}    


sub hex64to32 { 
   my $x = shift @_ ; 
   $x = $x >> 28 ; 
   $x = $x & 0xFF_FF_FF_FF ; 
   return $x; 

}
sub hex2float {
   my $x = shift @_ ; 
   my $positive = 1 ; 
   my $frac2dec = 0.5 ; 

   if ( $x & 0x80_00_00_00 ) {
#printf "Before : x = 0x%08x\n", $x ;   
      $x = ~$x + 0x00_00_00_01 ; 
      $x = $x & 0xFF_FF_FF_FF ; 
      $positive  = 0 ; 
#printf "After  : x = 0x%08x\n", $x ;   
   }

   my $integer    = $x >> 28 ; 
   my $fraction   = $x & 0x0F_FF_FF_FF ; 

   foreach ( 1..28 ) { 
      if ( $fraction & 0x08_00_00_00 )  {
         $integer += $frac2dec ; 
      }
      $fraction  = $fraction << 1 ; 
      $fraction  = $fraction & 0x0F_FF_FF_FF ; 
      $frac2dec /= 2  ; 
   }
   
   if ( ! $positive ) { $integer = - $integer ; } 
      
   return $integer ; 

}


sub hex_multiply {

   my ( $x, $y ) = @_ ; 
   my $xy ; 

   my $x_positive  = 1 ; 
   if ( $x & 0x80_00_00_00 ) {
#printf "Before : x = 0x%08x\n", $x ;   
      $x = ~$x + 0x00_00_00_01 ; 
      $x_positive  = 0 ; 
#printf "After  : x = 0x%08x\n", $x ;   
   }
   
   my $y_positive  = 1 ; 
   if ( $y & 0x80_00_00_00 ) {
#printf "Before : y = 0x%08x\n", $y ;   
      $y = ~$y + 0x00_00_00_01 ; 
      $y_positive  = 0 ; 
#printf "After  : y = 0x%08x\n", $y ;   
   }

   $xy   =  $x * $y ; 

   if ( ( $x_positive + $y_positive ) == 1 ) {
      $xy = ~$xy + 1 ; 
   }

#   printf "xy = 0x%08x\n", $xy ;   
   return $xy ; 
}








