#!/bin/bash
set -euo pipefail #stop program in case of failed command/pipeline or use of unbound variable
IFS="\n\t"	#protected in case of files with space in their names"
shopt -s nullglob #do not enter the loop in case no file matches the extention

COMPLETED=0
SKIPPED=0
DRY_RUN=0
VERBOSE=0
EXTENSION=""
ERROR_MESSAGE="Usage: ./rename.sh [--dry-run] [--verbose] ext
For more help: ./rename --help"

welcome_message() {
echo "========================================================================"
echo "Welcome the the bash renaming scipt by babus"
echo "For more help on use run: ./rename.sh --help"
echo "========================================================================"

}

print_help(){
	cat "README"
}

start_log () {
	local timestamp=$(date '+%F %T')
	local extension=$EXTENSION
	local current_dir=$(pwd)
	if [[ DRY_RUN -eq 1 ]]; then
		local mode="DRY"
	else
		local mode="EXE"
	fi

	if [[ ! -d "logs" ]]; then
		if [[ VERBOSE -eq 1 ]]; then
			echo "Creating Logs' directory (./logs)"
		fi
		mkdir "logs"
	fi

	todays_log="logs/"$(date '+%Y%m%d')"_log.txt"

	if [[ ! -f "$todays_log" ]]; then
		if [[ VERBOSE -eq 1 ]]; then
			echo "Creating Log file: $todays_log"
		fi
	
		touch "$todays_log"
	fi

	{
		echo "#rename.sh log started at $timestamp"
		echo "#Mode:$mode"
		echo "#Directory:$current_dir"
		echo "#Extension:$extension"
		echo "--------------------------------------------"
	
	} >> "$todays_log"

}

run(){
	local old="$1"
	local new="$2"
	
	if [[ $DRY_RUN -eq 1 ]]; then
		echo "[DRY]: Renaming " "$old" "-->" "$new" | tee -a "$todays_log"
	else	
		echo "[EXE]: Renaming " "$old" "-->" "$new" | tee -a "$todays_log"
		mv -- "$old" "$new"	#"protection in case of special characters"
	fi
}


parse_args() {	#in case of error, this function exits instead of returning, since there is not something to be handled by the main script yet(logs etc.)

	local parsed=0
	while [[ "$#" -gt 0 && "$1" == --* ]]; do
		case "$1" in
			--dry-run)
				if [[ DRY_RUN -eq 0 ]]; then
					DRY_RUN=1
					((++parsed))
					shift
				else
					echo "$ERROR_MESSAGE">&2
					exit 2
				fi
			;;	
			--verbose)
				if [[ VERBOSE -eq 0 ]]; then
					VERBOSE=1
					((++parsed))
					shift
				else
					echo "$ERROR_MESSAGE">&2
					exit 2
				fi
			;;
			--help)
				if [[ "$#" -eq 1 && $parsed -eq 0 ]]; then
					print_help
					exit 0
				else
					echo "$ERROR_MESSAGE">&2
					exit 2
				fi
				;;
			*)
				echo "Unknown option: $1">&2
				exit 2
				;;
		esac
	done
	if [[ $# -ne 1 ]]; then
		echo "$ERROR_MESSAGE">&2
		exit 2
	fi

	if [[ ! "$1" =~ ^[A-Za-z]+$ ]]; then
		echo "file extension must contain only letters (use txt instead of .txt)">&2
		exit 2
	fi
	EXTENSION=$(echo "$1")
}
parse_args "$@"
welcome_message
start_log
prefix=$(date +%Y%m%d)
already_named=()
to_be_renamed=()

for file in *."$EXTENSION"; do
	if [[ $file =~ ^${prefix}_[0-9]{3}\.${EXTENSION}$ ]]; then
		already_named+=("$file")	
	else
		to_be_renamed+=("$file")
	fi
done

echo "The following files already have a name that matches the destination format. Rename will be skipped:" | tee -a "$todays_log"
if [[ "${#already_named[@]}" -eq 0 ]]; then
	echo "-" | tee -a "$todays_log"
else
	printf "%s\n" "${already_named[@]}" | tee -a "$todays_log"
fi

#count how many names will be skipped
SKIPPED=${#already_named[@]}
renamer=$((SKIPPED + 1 )) #start from the immediately next available name

echo "The following files will be renamed:" | tee -a "$todays_log"
for file in "${to_be_renamed[@]}"; do
	new_name=$(printf "%s_%03d.%s" "$prefix" "$renamer" "$EXTENSION")
	run "$file" "$new_name"
	((++COMPLETED))
	((++renamer))
done

if [[ "${#to_be_renamed[@]}" -eq 0 ]]; then
	echo "-" | tee -a "$todays_log"
fi

if [[ $COMPLETED -eq 0  && $SKIPPED -eq 0 ]]; then
	echo "No files with the specified extension were found"| tee -a "$todays_log"
fi

echo "Completed $COMPLETED actions and skipped $SKIPPED"| tee -a "$todays_log"
echo "----------------------------------------------" >> "$todays_log"
printf "\n" >> "$todays_log"
