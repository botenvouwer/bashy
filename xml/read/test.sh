#!/bib/bash

TEST=$(xmlstarlet sel -t -v "//test/foo" test.xml)

echo $TEST

