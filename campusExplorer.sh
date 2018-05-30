#!/bin/bash

MAILGUN_API_KEY=""
MAILGUN_EMAIL=""
MAILGUN_API_STRING=""  # https://api.mailgun.net/v3/ ...   /messages
MY_EMAIL=""

NEW_ITEMS=0
CURRENT_TIME="`date +%Y-%m-%d/%H:%M:%S`"

HOUSING_SEEN="./housing_seen.txt" # specify the full path
HOUSING_NEW="./housing_new.html" # specify the full path
echo "" > "$HOUSING_NEW"

NEW_BATCH="./newBatch.txt" # specify the full path

printf "<div> $CURRENT_TIME </div>\n" >> "$HOUSING_NEW"

declare -a URLS=("http://supost.com/search/sub/66" "http://supost.com/search/sub/60" "http://supost.com/search/sub/59")

for s in "${URLS[@]}"
do
  curl "$s" | grep -i "campus\|escondido\|rains\|munger\|ev\|kennedy\|lyman\|sand\|portola\|studio\|abrams\|blackwelder\|hulme\|hills\|altos\|alma\|oak\|sharon\|highrise\|lowrise\|palo\|menlo" > "$NEW_BATCH"
  printf "<div> $s </div>\n" >> "$HOUSING_NEW"
  while read LINE; do
    grep -q "$LINE" "$HOUSING_SEEN" || {
      if [[ $LINE != *"from 15th July to 15th September"* ]] && [[ $LINE != *"csrf"* ]]; then
        echo "$LINE" >> "$HOUSING_SEEN"
        printf "<div> \n    $LINE \n</div>\n" | sed 's/<span.*span>/ /g' >> "$HOUSING_NEW"
        let "NEW_ITEMS+=1"
      fi
    }
  done <"$NEW_BATCH"
  printf "<br><br>\n" >> "$HOUSING_NEW"
done

if ((NEW_ITEMS > 0)) ; then
  echo "new items: $NEW_ITEMS"
  cat "$HOUSING_NEW" | curl -s --user "api:$MAILGUN_API_KEY" \
     "$MAILGUN_API_STRING" \
     -F from="$MAILGUN_EMAIL" \
     -F to="$MY_EMAIL" \
     -F subject='Housing upd' \
     -F html="<-"
fi
cat "$HOUSING_NEW"
