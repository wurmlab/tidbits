#Compress all files larger than 1Gb that are not already compressed - use 20 threads
find ./ -type f -size +1G | egrep -v '(bam|gz|zip|bz|sff|dmg|sai|ctx)' | xargs -t -P 20 -I __ gzip __
