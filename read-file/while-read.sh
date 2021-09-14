#!/bin/bash
set -eu
set -o pipefail

while read -r entry_value; do
	echo "-${entry_value}#"


done < test.txt
#done < list.txt
