#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

QUERY="$1"

if [[ -z "$QUERY" ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

PATTERN='^[0-9]+$'
if [[ $QUERY =~ $PATTERN ]]
then
  QUERY_RESULT=$($PSQL  "SELECT * FROM elements e LEFT JOIN properties p ON e.atomic_number = p.atomic_number LEFT JOIN types t on t.type_id = p.type_id WHERE e.atomic_number=$QUERY" )
else
  QUERY_RESULT=$($PSQL  "SELECT * FROM elements e LEFT JOIN properties p ON e.atomic_number = p.atomic_number LEFT JOIN types t on t.type_id = p.type_id WHERE e.symbol='$QUERY' OR e.name='$QUERY'" )
fi

if [[ -z "$QUERY_RESULT" ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

while IFS="|" read ATOMIC_NUMBER SYMBOL NAME ATOMIC_NUMBER1 ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID TYPE_ID1 TYPE_NAME
do
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_NAME, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
done <<< "$QUERY_RESULT"
