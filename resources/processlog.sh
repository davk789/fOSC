#!/bin/bash
# this looks at the sc-output.txt and fosc-output.txt on the desktop
# not intended for reuse

cd "~/Desktop"

nodes=(958
954
945
898
897
787
786
774
716
715
693
677
652
625
607
608
564
497
492
468
459
456
455
454
453
426
417
413
408
387
386
381
378
365
363
364
362
361
360
359
351
350
315
314
313
305
304
297
293
280
279
175
164
160
159
155
146
141
136
125
124
115
111
95
90
89
83
73
72
68
64
60
56
50
49
46
38
34
30
20
)

cat fosc-output.txt | grep "fOSC" > fosc-output-clean.txt
cat sc-output.txt | grep "fOSC" > sc-output-clean.txt


for n in "${nodes[@]}"
do
# separates out all the offending voices, doesn't preserve the order
# from teh log, because I don't feel like making the proper regexp
    cat sc-output-clean.txt | grep ", $n," >> sc-output-filtered.txt
    cat fosc-output-clean.txt | grep ", $n," >> fosc-output-filtered.txt
done
