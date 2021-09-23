#!/bin/bash

ORIGINAL="bank_nl823_174748.4343.343243.3433:accountnumber"

ACCOUNTNUMBER=${ORIGINAL#bank_[a-z][a-z][1-9][1-9][1-9]_} #remove prefix
ACCOUNTNUMBER=${ACCOUNTNUMBER%:accountnumber} #remove suffix

echo $ACCOUNTNUMBER
