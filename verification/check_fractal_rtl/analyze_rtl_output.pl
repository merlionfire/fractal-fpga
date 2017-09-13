#!/usr/bin/perl  -w 
use strict;
use Chart::Gnuplot;
use 5.010;

my @points ; 
my @points_expect ; 
my $iter_max   = 32 ;  

#if ( ! open FILE , "< rtl_output.dat" ) {
if ( ! open FILE , "< rtl_output_simple.dat" ) {
   die "Can NOT open file <rtl_output.dat" ; 
}


while (<FILE>) {
   chomp ; 
   my ( $px, $py,$cx, $cy, $found ) = /(\w{3}),(\w{3}).*cx=(\w{8}),cy=(\w{8})],(\w)/ ; 
   $px = hex($px) ;
   $py = hex($py) ;
   $cx = hex($cx) ; 
   $cy = hex($cy) ; 
#printf "(%03d,%03d) [0x%08x,0x%08x] => ", $px, $py, $cx, $cy ;  
   $cx = hex2float($cx) ; 
   $cy = hex2float($cy) ; 
#printf "[%f,%f]\n", $cx, $cy ;  
   if ( $found )  {
      my @xy = ( $cx , $cy ); 
      push @points, \@xy ; 
   }
   if ( calc_fractal( $cx, $cy ) ) { 
      my @xy = ( $cx , $cy ); 
      push @points_expect, \@xy ; 

   }   
}

# Create chart object and specify the properties of the chart
my $chart = Chart::Gnuplot->new(
                  output => "fractal_rtl_fast.pdf",
                  terminal => 'pdfcairo', 
                  title  => "fractal",
                  xlabel => "cx",
                  ylabel => "cy",
                  xrange => [-2.0, 1.0 ],
                  yrange => [-1.0, 1.0 ],
                  

            );


my $dataset = Chart::Gnuplot::DataSet->new(
                  points   => \@points,
                  pointtype => "dot",
                  pointsize => 1,
              ) ; 

$chart->plot2d($dataset) ; 

#my $chart_expect = Chart::Gnuplot->new(
#                  output => "fractal_rtl_expect.pdf",
#                  terminal => 'pdfcairo', 
#                  title  => "fractal",
#                  xlabel => "cx",
#                  ylabel => "cy",
#                  xrange => [-2.0, 1.0 ],
#                  yrange => [-1.0, 1.0 ],
#            );
#
#
#my $dataset_expect = Chart::Gnuplot::DataSet->new(
#                  points   => \@points_expect,
#                  pointtype => "dot",
#                  pointsize => 1,
#              ) ; 
#
#$chart_expect->plot2d($dataset_expect) ; 

close FILE ; 

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

sub calc_fractal {
   my ($x, $y ) = @_ ; 
   my ($x0, $y0 ) = @_ ;  
   
   my $iter = 0 ; 

   while (  $iter <= $iter_max  )  {
      if ( $x ** 2 + $y ** 2 > 4 ) { return 0 ; } 

      my $x_temp =  $x ** 2 - $y ** 2 + $x0 ; 
      $y =  2 *  $x * $y + $y0 ; 
      $x = $x_temp ; 

      $iter++ ; 
   }
   return 1 ; 
}

