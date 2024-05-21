#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read USERNAME_INPUT

# search username in database
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_INPUT'")
GAMES_PLAYED=0
BEST_GAME=0
GUESS_COUNT=0

# if username not found, then new user
if [[ -z $USERNAME ]]; then
	echo -e "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  USERNAME=$USERNAME_INPUT
# if found, get games_played and best_game from user
else
	GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
	BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
	echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


# generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM%1000 + 1 ))
echo -e "Guess the secret number between 1 and 1000:"


GUESS_NUMBER_LOOP() {

  read GUESS
	GUESS_COUNT=$(( GUESS_COUNT + 1 ))

	# if input is not an integer
	if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
		echo -e "That is not an integer, guess again:"
	elif (( GUESS > SECRET_NUMBER )); then
		echo -e "It's lower than that, guess again:"
	elif (( GUESS < SECRET_NUMBER )); then
		echo -e "It's higher than that, guess again:"
	elif (( GUESS == SECRET_NUMBER )); then
    # Guessed correctly!

		GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))

		# if there is no guess count (new user)
		if (( BEST_GAME == 0 )); then
			# INSERT
			BEST_GAME=$(( GUESS_COUNT ))
			INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME', $GAMES_PLAYED, $BEST_GAME)")
		elif (( GUESS_COUNT < BEST_GAME )); then
			# UPDATE
			BEST_GAME=$(( GUESS_COUNT ))
			UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
			UPDATE2_USER_RESULT=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE username='$USERNAME'")
		else
			UPDATE_USER_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
			
		fi

    echo -e "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
	fi
}

until [[ $GUESS -eq $SECRET_NUMBER ]]
do
	GUESS_NUMBER_LOOP
done
