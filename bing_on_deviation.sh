set -euox pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SOUNDS_DIR=$SCRIPT_DIR/sounds

BEEP=$SOUNDS_DIR/clearly.ogg
PRICE_DOWN=$SOUNDS_DIR/moonless.ogg

function get_deviation_percentage {
  python3 -c "print(round(abs((1 - ($1 / $2))*100)))"
}

function round {
  if [[ $(echo -n "$1" | grep '.') ]]; then
    echo "$1" | cut -d '.' -f1
  else
    echo "$1"
  fi
}

function get_price {
  curl https://blockchain.info/ticker | jq -r '.USD."15m"'
}

function beep_percentage_deviation {
  # plays the $BEEP sound for the number of percentage point difference since last execution
  # on the last beep it will play $PRICE_DOWN instead if the price has gone down since last execution
  price=$(get_price)
  if [[ -f /tmp/bing_on_deviation ]]; then
    old_price=$(cat /tmp/bing_on_deviation)
  fi
  echo "$price" > /tmp/bing_on_deviation
  if [[ "$old_price" ]]; then
    difference=$(get_deviation_percentage $price $old_price)
    for i in $(seq 1 $difference); do
      if ((i==difference)); then
        if (( $(round $old_price) > $(round $price) )); then
          paplay $PRICE_DOWN
        else
          paplay $BEEP
        fi
      else
        paplay $BEEP
      fi
    done
  fi
}

beep_percentage_deviation
