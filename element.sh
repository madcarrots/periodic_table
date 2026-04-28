#!/usr/bin/bash

# Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Database connection 
PSQL="psql --username=freecodecamp --dbname=periodic_table -t -A -F '|'"

# Input for identifying element
INPUT=$1

# Determine what the input refers to, first atomic_number
if [[ $INPUT =~ ^[0-9]+$ ]]; then
  WHERE="e.atomic_number = $INPUT"
else
# Then either symbol or name
  WHERE="e.symbol = '$INPUT' OR e.name = '$INPUT'"
fi

# Query to fetch all required data in one go
QUERY="
  SELECT 
    e.atomic_number,
    e.name,
    e.symbol,
    # update type to come from types table, instead. use "t" instead of "p"
    t.type,
    p.atomic_mass,
    p.melting_point_celsius,
    p.boiling_point_celsius
  FROM elements e
  JOIN properties p ON e.atomic_number = p.atomic_number
  # Add join to types table
  JOIN types t ON p.type_id = t.type_id 
  WHERE $WHERE;
"

# Run the query and capture the result
ELEMENT_INFO=$($PSQL -c "$QUERY")

# If nothing was returned, then he element doesn't exist
if [ -z "$ELEMENT_INFO" ]; then
  echo "I could not find that element in the database."
else
  # Parse the pipe-separated result into variables
  # variables match the order of the query items
  IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT_INFO"

  # Remove any single quotes
  ATOMIC_NUMBER="${ATOMIC_NUMBER//\'/}"
  NAME="${NAME//\'/}"
  SYMBOL="${SYMBOL//\'/}"
  TYPE="${TYPE//\'/}"
  MASS="${MASS//\'/}"
  MELTING="${MELTING//\'/}"
  BOILING="${BOILING//\'/}"

  # Output the information exactly as stated in the instructions, without excess quotes 
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
fi