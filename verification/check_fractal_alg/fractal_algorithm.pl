#!/usr/bin/perl  -w 
use strict;
#use Chart::Gnuplot;
use 5.010;

my @px=(0..767) ; 
my @py= reverse (0..767) ; 
my @result ; 

my $cy   = -1.5 ; 
my $delta= 3/768 ;   
my $iter_max   = 32 ;  

foreach my $py (@py) {

   my $cx = -2 ; 

   foreach my $px ( @px ) {
      if ( calc_fractal( $cx, $cy ) ) { 
         push  @result, 1   ;    
      } else {
         push  @result, 0   ;    
      }   
       
      $cx += $delta ; 
   }

   $cy += $delta ;  

}   

my @points ; 

my $i = 0 ; 
my $print_num = 0 ; 

$cy   = -1.5 ; 
foreach my $py (@py) {
   my $cx = -2 ; 

   foreach my $px ( @px ) {
      if ( $result[$i] ) {
         my @xy = ( $cx , $cy ) ; 
         push @points, \@xy ; 
         if ( $print_num < 3 ) {
              printf "(px,py) = (%0d,%0d), (cx,cy) = ( %0f, %0f )\n", $px, $py, $cx, $cy ; 
              $print_num++ ;  
         }   
      }   
      $i++; 
      $cx += $delta ; 
   }
   $cy += $delta ;  
}   

# Create chart object and specify the properties of the chart
#my $chart = Chart::Gnuplot->new(
#                  output => "fractal.pdf",
#                  terminal => 'pdfcairo', 
#                  title  => "fractal",
#                  xlabel => "cx",
#                  ylabel => "cy",
#                  xrange => [-2.0, 1.0 ],
#                  yrange => [-1.0, 1.0 ],
#                  
#
#            );
#
#
#my $dataset = Chart::Gnuplot::DataSet->new(
#                  points   => \@points,
#                  pointtype => "dot",
#                  pointsize => 1,
#              ) ; 
#
#$chart->plot2d($dataset) ; 


sub calc_fractal {
   my ($x, $y ) = @_ ; 
   my ($x0, $y0 ) = @_ ;  
   
   my $iter = 0 ; 

   while (  $iter <= $iter_max  )  {
      if ( $x ** 2 + $y ** 2 > 4 ) { 
         if ( $x ** 2 + $y ** 2 > 15 ) {
            printf "Warning : (%0f,%0f): x^2+y^ > 15\n", $x, $y ;    
         }
         return 0 ; 
      } 

      my $x_temp =  $x ** 2 - $y ** 2 + $x0 ; 
      $y =  2 *  $x * $y + $y0 ; 
      $x = $x_temp ; 

      $iter++ ; 
   }
   return 1 ; 
}


   


