#!/bin/bash

testvar='hallo world'

echo 'test'

cat <<EOF

dit is een test


${testvar}

jaja

EOF

echo 'end test'
