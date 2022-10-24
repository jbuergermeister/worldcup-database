#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games;")
# echo $($PSQL "SELECT * FROM teams;")

cat games.csv | while IFS="," read YEAR ROUND WIN OPP WIN_GOALS OPP_GOALS
do
#  echo $YEAR $ROUND $WIN $OPP $WIN_GOALS $OPP_GOALS
  if [[ $WIN != 'winner' && $OPP != 'opponent' ]]
  then
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN';")
    if [[ -z $WIN_ID ]]
    then
      WIN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WIN');")
      if [[ WIN_RESULT = "INSERT 0 1" ]]
      then
        echo Inserted team $WIN
      fi
    fi
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")
    if [[ -z $OPP_ID ]]
    then
      OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPP');")
      if [[ OPP_RESULT = "INSERT 0 1" ]]
      then
        echo Inserted team $OPP
      fi
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WIN OPP WIN_GOALS OPP_GOALS
do
  if [[ $WIN != 'winner' ]]
  then
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN';")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")
    GAME_RESULT=$($PSQL "INSERT INTO games(year,winner_id,opponent_id,winner_goals,opponent_goals,round) VALUES($YEAR,$WIN_ID,$OPP_ID,$WIN_GOALS,$OPP_GOALS,'$ROUND');")
  fi
done

echo -e "\n$($PSQL "SELECT * FROM teams;")\n"
echo -e "\n$($PSQL "SELECT * FROM games;")\n"