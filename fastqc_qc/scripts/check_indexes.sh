zcat $1 | head -n 400000 | grep '^@[NM]' | cut -d: -f10 | sort | uniq -c | sort -nr | head -n 250 > $1.indices.txt 
