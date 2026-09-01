#!/bin/bash

set -e

which fragmenstein

echo "Running fragmenstein laboratory combine..."

time fragmenstein laboratory combine -i ../hits.sdf -t *desolv.pdb --victor WictorNoPlace

if [ $? -ne 0 ]; then
    echo "Error: fragmenstein laboratory combine failed."
    exit 1
else
    echo "Done: fragmenstein laboratory combine completed successfully."
fi
