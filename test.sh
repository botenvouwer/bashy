#!/bin/bash

. fail.sh
#echo $?
#find test.*
#echo $?

if [ $? -eq 0 ]
then
  echo $?
  echo "Function was good $?"
else
  echo $?
  echo "Function was bad $?"
fi

echo $?

if [ -f "bgt_39.zip" ]
then
  echo "File exits"
else
  echo "File does not exist"
fi

echo "...."

if [ $? -eq 0 ] && [ -s "bgt_39.zip" ]
then
  echo "works"
else
  echo "nope"
fi
