#!/bin/bash


todays_log="logs/$(date '+%Y%m%d')_log.txt"
touch "$todays_log"
for i in {1..100}; do

echo "run #$i" | tee -a "$todays_log"
#ftiakse apo 0 ews 10 arxeia pou na prohgoyntai alfarithmitika tou 20251102_XXX.txt (format0)
end=$((RANDOM%11))
echo "creating $end pre-files" | tee -a "$todays_log"
for ((i=1; i<="$end"; i++))
do
	file=$(printf "11111111_%03d.txt" "$i")
	touch "$file"
done
#printf "==========================================================\n"

#ftiakse apo 0 ews 10 arxeia me th morfh 20251102_XXX.txt (format1)
end=$((RANDOM%11))
end2="$end"
echo "creating $end files" | tee -a "$todays_log"
for ((i=1; i<="$end"; i++))
do
	file=$(printf "20251110_%03d.txt" "$i")
	touch "$file"
done
#printf "==========================================================\n"
#ftiakse apo 0 ews 10 arxeia pou na erxontai meta apo to 20251102_XXX.txt (format2)
end=$((RANDOM%11))
echo "creating $end post-files" | tee -a "$todays_log"
for ((i=1; i<="$end"; i++))
do
	file=$(printf "333333333_%03d.txt" "$i")
	touch "$file"
done
#printf "==========================================================\n"


./rename.sh txt
rm *.txt #clean-up
printf "==============================================\n" >> "$todays_log"
done
