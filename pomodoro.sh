#!/bin/bash

show_dialog() {
  local title=$1
  local message=$2
  zenity --info --title="$title" --text="$message"
}

# Validate input for cycles
validate_cycles_input() {
  local input=$1
  if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    zenity --error --title="Invalid Input" --text="Please enter a valid number."
    return 1
  elif [ "$input" -lt 3 ] || [ "$input" -gt 5 ]; then
    zenity --error --title="Invalid Input" --text="Please enter a number between 3 and 5."
    return 1
  fi
  return 0
}

# Validate input for minutes (generic)
validate_input() {
  local input=$1
  if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    zenity --error --title="Invalid Input" --text="Please enter a valid number."
    return 1
  elif [ "$input" -le 0 ]; then
    zenity --error --title="Invalid Input" --text="Please enter a positive number greater than 0."
    return 1
  elif [ "$input" -gt 40 ]; then
    zenity --error --title="Invalid Input" --text="Please enter a number less than or equal to 40."
    return 1
  fi
  return 0
}

# Validate the input for break minutes
validate_break_minutes() {
  local input=$1
  if ! [[ "$input" =~ ^[0-9]+$ ]]; then
    zenity --error --title="Invalid Input" --text="Please enter a valid number."
    return 1
  elif [ "$input" -lt 5 ] || [ "$input" -gt 15 ]; then
    zenity --error --title="Invalid Input" --text="Please enter a number between 5 and 15."
    return 1
  fi
  return 0
}

# Prompt user for websites to monitor
prompt_for_websites() {
  local websites=()
  local website_input
  while true; do
    website_input=$(zenity --entry --title="Enter Website" --text="Enter a website to monitor (e.g., YouTube):")
    if [ $? -ne 0 ]; then
      break
    fi
    if [ -n "$website_input" ]; then
      websites+=("$website_input")
    else
      break
    fi
  done
  echo "${websites[@]}"
}

# Prompt user for websites to monitor
websites_to_monitor=($(prompt_for_websites))

if [ ${#websites_to_monitor[@]} -eq 0 ]; then
  show_dialog "Error" "No websites entered. Exiting."
  exit 1
fi

# Loop until valid inputs are provided or user cancels
while true; do
  cycles=$(zenity --entry --title="Set Cycles" --text="Enter the number of cycles (3-5):" --entry-text "3")

  if [ $? -ne 0 ]; then
    exit 0
  fi

  if ! validate_cycles_input "$cycles"; then
    continue
  fi

  break
done

main_minutes=$(zenity --entry --title="Set Timer" --text="Enter the main timer duration in minutes (1-40):" --entry-text "2")

if [ $? -ne 0 ]; then
  exit 0
fi

if ! validate_input "$main_minutes"; then
  exit 1
fi

break_minutes=$(zenity --entry --title="Set Break Timer" --text="Enter the break timer duration in minutes (5-15):" --entry-text "5")

if [ $? -ne 0 ]; then
  exit 0
fi

if ! validate_break_minutes "$break_minutes"; then
  exit 1
fi

# Let's run the timer ->
run_timer() {
  local duration=$1
  local end_message=$2
  local display_text=$3

  start_time=$(date +%s)
  end_time=$((start_time + duration * 60))

  while true; do
    current_time=$(date +%s)

    # Check if the specified number of minutes have passed
    if [ $current_time -ge $end_time ]; then
      show_dialog "Timer" "$end_message"
      break
    fi

    countdown_seconds=$((end_time - current_time))
    countdown_minutes=$((countdown_seconds / 60))
    countdown_seconds=$((countdown_seconds % 60))

    printf "\r$display_text: %02d:%02d\033[K" $countdown_minutes $countdown_seconds

    sleep 1
  done
  printf "\n"
}

# Close distracting tabs
close_distracting_tabs() {
  declare -A sites_messages
  for site in "${websites_to_monitor[@]}"; do
    sites_messages["$site"]="$site detected and closed! No distractions."
  done

  while true; do
    # Get the window list with detailed information
    window_list=$(wmctrl -l)

    while IFS= read -r line; do
      # Get the window ID and title
      window_id=$(echo "$line" | awk '{print $1}')
      window_title=$(echo "$line" | cut -d ' ' -f 5-)

      for site in "${!sites_messages[@]}"; do
        if [[ "$window_title" == *"$site"* ]]; then
          wmctrl -ic "$window_id"
          echo -e "\n+------------------------------------------------------------+\n${sites_messages[$site]}\n+------------------------------------------------------------+"
          break  # No need to check other sites once a match is found
        fi
      done
    done <<< "$window_list"

    sleep 5
  done
}

close_distracting_tabs &

for (( i=1; i<=cycles; i++ )); do
  run_timer "$main_minutes" "$main_minutes minutes have passed. Starting break timer." "Countdown"
  run_timer "$break_minutes" "Break time of $break_minutes minutes has ended." "Break Time"
done

show_dialog "Completed" "All cycles have been completed. Application closing."

# Terminate the process being monitored if it has been accessed
kill %1

