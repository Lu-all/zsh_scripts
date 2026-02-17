#!/bin/zsh

DIR=$(dirname -- "$0")

adjust_lightness_path=$(find $DIR -name "adjust_lightness.py" -type f)
if [ -z "$adjust_lightness_path" ]; then
    echo "adjust_lightness.py not found, where is it? (Write complete path, e.g. /home/user/adjust_lightness.py)"
    read adjust_lightness_path
fi

colourpeek_path=$(find $HOME/Library/Python -name "colourpeek" -type f)
if [ -z "$colourpeek_path" ]; then
    echo "colourpeek not found, where is it? (Write complete path, e.g. /home/user/colourpeek)"
    read colourpeek_path
fi

help () {
	echo "Usage: colorfun <function> <function_arguments> [--format=<target_format>]"
	echo "Color manipulation functions for zsh."
	echo "Provides functions to adjust and obtain colors from images. The color outputs are in 0xAARRGGBB format by default."
	echo "Requires 'colourpeek' Python package."
	echo "For example, 'colorfun redder "0x50005566" 100 --format="#RRGGBB"' returns '#645566'."
	echo "Arguments:"
	echo "  <function>                  The color function to use (see below)"
	echo "  --format=<target_format>    (Optional) Specify output format: RRGGBB, AARRGGBB, #RRGGBB, #AARRGGBB, 0xRRGGBB, 0xAARRGGBB"
	echo "Functions:"
	echo "  redder <color> [increment]    Make color redder"
	echo "  greener <color> [increment]   Make color greener"
	echo "  bluer <color> [increment]     Make color bluer"
	echo "  yellower <color> [increment]  Make color yellower"
	echo "  purpler <color> [increment]   Make color purpler"
	echo "  half_color <color>            Make color half transparent"
	echo "  darker <color> [increment]    Make color darker"
	echo "  lighter <color> [increment]   Make color lighter"
	echo "  saturation <color>            Get saturation of color as a number in the range 0-255"
	echo "  obtain_color <image_path>     Obtain dominant color from image and adjust its lightness. Optimized to get an accent color in dark backgrounds."
}

increment() {
  # Convert to decimal
  value_dec=$((16#$1))
  # Increment value (with a max of 255)
  increment=$2
  value_dec=$((value_dec + increment))
  if [ $value_dec -gt 255 ]; then
      value_dec=255
  fi
  if [ $value_dec -lt 0 ]; then
	  value_dec=0
  fi

  # Output in hex
  printf "%02X" $value_dec
}

parse_format() {
  input_color="$1"
  target_format="$2"
  cleaned_color=$(parse_hex "$input_color")
  if [ "$target_format" = "RRGGBB" ]; then
    echo "${cleaned_color:2:6}"
  elif [ "$target_format" = "AARRGGBB" ]; then
    echo "${cleaned_color:0:8}"
  elif [ "$target_format" = "#RRGGBB" ]; then
	echo "#${cleaned_color:2:6}"
  elif [ "$target_format" = "#AARRGGBB" ]; then
	echo "#${cleaned_color:0:8}"
  elif [ "$target_format" = "0xRRGGBB" ]; then
	echo "0x${cleaned_color:2:6}"
  elif [ "$target_format" = "0xAARRGGBB" ]; then
	echo "0x${cleaned_color:0:8}"
  else
	echo "Error: Unknown target format '$target_format'." >&2
	exit 1
  fi
}

parse_hex() {
  input_color="$1"
  # Remove leading '#' if present
  if [[ "$input_color" == \#* ]]; then
	input_color="${input_color:1}"
  fi
  if [[ "$input_color" == 0x* ]]; then
	input_color="${input_color:2}"
  fi
  if [[ ${#input_color} -eq 6 ]]; then
	# RRGGBB -> 0xAARRGGBB
	input_color="FF$input_color"
  elif [[ ${#input_color} -ne 8 ]]; then
	echo "Error: Invalid color format. Use #RRGGBB, #AARRGGBB, 0xRRGGBB, or 0xAARRGGBB." >&2
	exit 1
  fi
  echo "$input_color"
}


redder() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="$2"
  else
    increment=100
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  RR_new=$(increment $RR $increment)
  out="${AA}${RR_new}${GG}${BB}"
  echo "$out"
}


greener() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="$2"
  else
    increment=100
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  GG_new=$(increment $GG $increment)
  out="${AA}${RR}${GG_new}${BB}"
  echo "$out"
}

bluer() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="$2"
  else
    increment=100
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  BB_new=$(increment $BB $increment)
  out="0x${AA}${RR}${GG}${BB_new}"
  echo "$out"
}

yellower() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment_r="$2"
  else
    increment_r=100
  fi
  increment_g=$((increment_r - 25))
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  RR_new=$(increment $RR $increment_r)
  GG_new=$(increment $GG $increment_g)
  out=""0x${AA}${RR_new}${GG_new}${BB}
  echo "$out"
}

purpler() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="$2"
  else
    increment=100
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  RR_new=$(increment $RR $increment)
  BB_new=$(increment $BB $increment)
  out=""0x${AA}${RR_new}${GG}${BB_new}
  echo "$out"
}

half_color() {
  original_color="$1"
  out="0x50${original_color:$((${#original_color}-6))}"
  echo "$out"
}

darker() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="-$2"
  else
    increment="-100"
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  RR_new=$(increment $RR $increment)
  GG_new=$(increment $GG $increment)
  BB_new=$(increment $BB $increment)
  out=""0x${AA}${RR_new}${GG_new}${BB_new}
  echo "$out"
}

lighter() {
  original_color="$1"
  if [ ! -z "$2" ]; then
    increment="$2"
  else
    increment=100
  fi
  AA=${original_color:0:2}
  RR=${original_color:2:2}
  GG=${original_color:4:2}
  BB=${original_color:6:2}

  RR_new=$(increment $RR $increment)
  GG_new=$(increment $GG $increment)
  BB_new=$(increment $BB $increment)
  out=""0x${AA}${RR_new}${GG_new}${BB_new}
  echo "$out"
}

saturation(){
  original_color="$1"
  RR=${original_color:2:2}
  RR=$((16#$RR))
  GG=${original_color:4:2}
  GG=$((16#$GG))
  BB=${original_color:6:2}
  BB=$((16#$BB))
  MIN="$RR"
  MAX="$RR"
  if [ "$GG" -lt "$RR" ]; then
    MIN="$GG"
  else
    MAX="$GG"
  fi
  if [ "$BB" -lt "$MIN" ]; then
    MIN="$BB"
  elif [ "$BB" -gt "$MAX" ]; then
    MAX="$BB"
  fi
  SATURATION=$(( "$MAX" - "$MIN" ))
  echo "$SATURATION"
  exit 0
}

obtain_color () {
  INPUT_IMAGE="$(echo $1)"
  if [ ! -f "$(echo $INPUT_IMAGE)" ] || [ -z "$(echo $INPUT_IMAGE)" ]; then
	echo "Warning: Image file '$INPUT_IMAGE' not found, reporting default color (0xFFFFFF)" >&2
	# Default to white if no image provided
    COLOR_OG="0xffffffff"
  else
	COLORS="$($colourpeek_path $INPUT_IMAGE)"
	# get the 4 most abundant colors
	COLOR_1=$(echo "$COLORS" | grep -Eo '[0-9A-Fa-f]{6}' | head -n1)
	COLOR_2=$(echo "$COLORS" | grep -Eo '[0-9A-Fa-f]{6}' | head -n2 | tail -n1)
	COLOR_3=$(echo "$COLORS" | grep -Eo '[0-9A-Fa-f]{6}' | head -n3 | tail -n1)
	COLOR_4=$(echo "$COLORS" | grep -Eo '[0-9A-Fa-f]{6}' | head -n4 | tail -n1)
	COLOR_1_PARSED=$(parse_hex "$COLOR_1")
	COLOR_2_PARSED=$(parse_hex "$COLOR_2")
	COLOR_3_PARSED=$(parse_hex "$COLOR_3")
	COLOR_4_PARSED=$(parse_hex "$COLOR_4")
	# Get Saturation of the 4 colors
	SAT_1=$(saturation "$COLOR_1_PARSED")
	SAT_2=$(saturation "$COLOR_2_PARSED")
	SAT_3=$(saturation "$COLOR_3_PARSED")
	SAT_4=$(saturation "$COLOR_4_PARSED")
	# Choose the most saturated color
	if [ "$SAT_1" -gt "$SAT_2" ] && [ "$SAT_1" -gt "$SAT_3" ] && [ "$SAT_1" -gt "$SAT_4" ]; then
		COLOR_OG="$COLOR_1_PARSED"
	elif [ "$SAT_2" -gt "$SAT_3" ] && [ "$SAT_2" -gt "$SAT_4" ]; then
		COLOR_OG="$COLOR_2_PARSED"
	elif [ "$SAT_3" -gt "$SAT_4" ]; then
		COLOR_OG="$COLOR_3_PARSED"
	else
		COLOR_OG="$COLOR_4_PARSED"
	fi
   fi
   # Adjust lightness
   COLOR=$(python3 "$adjust_lightness_path" "$COLOR_OG")
   # Avoid dark unsaturated colors (personally not appealing as accent colors and hard to see)
   if [ "$( saturation $COLOR )" -lt 5 ]; then
    COLOR="$( lighter $COLOR 50 )"
   fi
   echo "$COLOR"
}

modified_params=()
target_format="0xAARRGGBB"
for param in "$@"; do
  	if [ "$param" = "-h" ]; then
		help
		exit 0
	elif [[ "$param" == --format=* ]]; then
		target_format="${param#--format=}"
	else
		modified_params+=("$param")
	fi
done

if [ "${#modified_params[@]}" -lt 2 ]; then
  help >&2
  exit 1
fi

function_name="${modified_params[1]}"
required_argument="${modified_params[2]}"
if [ "${#modified_params[@]}" -gt 2 ]; then
	optional_arguments="${modified_params[3]}"
else
	optional_arguments=""
fi

if [ "$function_name" = "obtain_color" ]; then
  # Required argument is an image path (no parsing needed)
  transformed_color=$(obtain_color "$required_argument" "$optional_arguments")
else
  # Required argument is a color (parsing needed)
  parsed_color=$(parse_hex "$required_argument")
  case "$function_name" in
	"redder") transformed_color=$(redder "$parsed_color" "$optional_arguments") ;;
	"greener") transformed_color=$(greener "$parsed_color" "$optional_arguments") ;;
	"bluer") transformed_color=$(bluer "$parsed_color" "$optional_arguments") ;;
	"yellower") transformed_color=$(yellower "$parsed_color" "$optional_arguments") ;;
	"purpler") transformed_color=$(purpler "$parsed_color" "$optional_arguments") ;;
	"half_color") transformed_color=$(half_color "$parsed_color") ;;
	"darker") transformed_color=$(darker "$parsed_color" "$optional_arguments") ;;
	"lighter") transformed_color=$(lighter "$parsed_color" "$optional_arguments") ;;
	"saturation") saturation "$parsed_color" ;; # exit 0 in function
	*)
	  echo "Error: Unknown function '$function_name'." >&2
	  echo "Usage: colorfun <function> ..." >&2
	  echo "(Or use -h for help)" >&2
	  exit 1
	  ;;
  esac
fi

# Format output
parse_format "$transformed_color" "$target_format"
