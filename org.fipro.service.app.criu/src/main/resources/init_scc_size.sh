#!/bin/bash

# This script is an adaption of the OpenLiberty script to calculate the cache size to avoid wasted space
# https://github.com/OpenLiberty/ci.docker/blob/main/releases/latest/kernel-slim/helpers/build/populate_scc.sh

# Initial size of the SCC layer
SCC_SIZE="80m"  

if [[ $JAVA_OPTS_EXTRA == *"-Xshareclasses"* ]] ;
then
  # We assume that JAVA_OPTS_EXTRA contains the -Xshareclasses configuration
  
  JAVA_OPTS_EXTRA_ORIGINAL=$JAVA_OPTS_EXTRA
  
  CREATE_LAYER="$JAVA_OPTS_EXTRA,createLayer"
  DESTROY_LAYER="$JAVA_OPTS_EXTRA,destroy"
  PRINT_LAYER_STATS="$JAVA_OPTS_EXTRA,printTopLayerStats"
  
  # Start the application and create the initial cache
  echo "Calculating SCC layer upper bound, starting with initial size $SCC_SIZE."
  JAVA_OPTS_EXTRA="$CREATE_LAYER -Xscmx$SCC_SIZE"
  . ./start.sh
  
  # Find out how full it is
  FULL=`( java $PRINT_LAYER_STATS || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
  echo "SCC layer is $FULL% full. Destroying layer."
  
  # Destroy the layer once we know roughly how much space we need
  java $DESTROY_LAYER || true
  
  # Remove the m suffix
  SCC_SIZE="${SCC_SIZE:0:-1}"
  
  # Calculate the new size based on how full the layer was (rounded to nearest m)
  SCC_SIZE=`awk "BEGIN {print int($SCC_SIZE * $FULL / 100.0 + 0.5)}"`
  
  # Make sure size is >0
  [ $SCC_SIZE -eq 0 ] && SCC_SIZE=1
  
  # Add the m suffix back
  SCC_SIZE="${SCC_SIZE}m"
  
  echo "Re-creating layer with size $SCC_SIZE"
  JAVA_OPTS_EXTRA="$CREATE_LAYER -Xscmx$SCC_SIZE"
  . ./start.sh
  
  # Tell the user how full the final layer is
  FULL=`( java $PRINT_LAYER_STATS || true ) 2>&1 | awk '/^Cache is [0-9.]*% .*full/ {print substr($3, 1, length($3)-1)}'`
  echo "SCC layer is $FULL% full"
else
  # simply call the start script as there is no -Xshareclasses configuration
  . ./start.sh
fi
