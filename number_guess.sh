#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

GAME_MENU() {
  echo "Enter your username:"
  read USERNAME

  RETURNING_USERS=$($PSQL "SELECT username FROM games WHERE username='$USERNAME' GROUP BY username")

  #if new user
  if [[ -z $RETURNING_USERS ]]
  then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  GAME

  #if returning user
  else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(username) FROM games WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT guess_count FROM games WHERE username='$USERNAME' ORDER BY guess_count ASC LIMIT 1")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  GAME
  fi
}

GAME() {
  SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS
  GUESS_COUNT=1
  #start until loop
  until [[ $GUESS -eq $SECRET_NUMBER ]]
    do
      # if invalid guess
      if [[ ! $GUESS =~ ^[0-9]+$ ]]
      then
      echo -e "\nThat is not an integer, guess again:"
      read GUESS
      else
        (( GUESS_COUNT++ ))
        #if wrong guess
        if [[ $GUESS -lt $SECRET_NUMBER ]]
          then
            echo -e "\nIt's higher than that, guess again:"
            read GUESS
        elif [[ $GUESS -gt $SECRET_NUMBER ]]
          then 
            echo -e "\nIt's lower than that, guess again:"
            read GUESS
        fi
      fi
    done
  #if correct guess
  echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

  INSERT_GAME=$($PSQL "INSERT INTO games(username,secret_number,guess_count) VALUES('$USERNAME',$SECRET_NUMBER,$GUESS_COUNT)")
}

GAME_MENU
