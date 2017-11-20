#! /bin/sh

for I in 1 2 3
do
    bsub -q short -J "myjob[$I]" -o %I.out -e %I.err sleep 30
done
for I in 4 5 6 
do
    bsub -q short -J "myjob[$I]" -o %I.out -e %I.err sleep 60
done

bsub -K -q short -w "done(myjob)" -o all_done.out -e all_done.err echo "all done(myjob)"

