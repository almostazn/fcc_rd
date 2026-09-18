#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM USERS WHERE NAME = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL $"INSERT INTO users(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM USERS WHERE NAME = '$USERNAME'")

  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(total_guesses) from games WHERE user_id = $USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((1 + $RANDOM % 1000))
GUESS=0
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
while [[ $SECRET_NUMBER -ne $GUESS ]]
do
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[  $SECRET_NUMBER -lt $GUESS ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $SECRET_NUMBER -gt $GUESS ]]
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  (( GUESS_COUNT++ ))
done


echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
INSERT_GAME=$($PSQL "INSERT INTO games(total_guesses, user_id) VALUES($GUESS_COUNT, $USER_ID)")