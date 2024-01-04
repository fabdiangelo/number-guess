#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

NUMBER=$(( $RANDOM % 1000 + 1 ))

while [[ ! $USERNAME || $(echo $USERNAME | wc -m) -gt 23 ]] 
do
  echo "Enter your username:"
  read USERNAME
done

USER=$($PSQL "SELECT username, best_game, games_count FROM users WHERE username='$USERNAME'")

if [[ $USER == "" ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_count) VALUES ('$USERNAME', 0)")
else
  echo $USER | while read NAME BAR BEST BAR CANT
  do
    echo "Welcome back, $NAME! You have played $CANT games, and your best game took $BEST guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
read NUM
COUNT=1

while [[ $NUMBER != $NUM ]]
do
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $NUM > $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    COUNT=$(( $COUNT + 1 ))
  else
    echo "It's higher than that, guess again:"
    COUNT=$(( $COUNT + 1 ))
  fi

  read NUM
done


ADD_TRY=$($PSQL "UPDATE users SET games_count=(games_count+1) WHERE username='$USERNAME'")

BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME' AND best_game IS NOT NULL")
if [[ $COUNT < $BEST || $BEST == "" ]]
then
  ADD_BEST=$($PSQL "UPDATE users SET best_game=$COUNT WHERE username='$USERNAME'")
fi

echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"