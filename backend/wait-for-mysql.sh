# #!/bin/sh

# # Wait until MySQL is reachable
# echo $MYSQL
# while ! nc -z $MYSQL_HOST 3306; do
#   echo "Waiting for MySQL..."
#   sleep 3
# done

# # Then start the Node app
# node server.js




#!/bin/sh

#echo "Waiting for MySQL at $MYSQL_HOST:3306"

#while ! (echo > /dev/tcp/$MYSQL_HOST/3306) >/dev/null 2>&1; do
#  echo "MySQL not reachable..."
#  sleep 3
#done

#echo "MySQL is reachable. Starting server..."
#node server.js


#!/bin/sh

echo "Waiting for MySQL at $MYSQL_HOST:3306"

# Loop until MySQL is reachable
while ! nc -z "$MYSQL_HOST" 3306; do
  echo "MySQL not reachable..."
  sleep 3
done

echo "MySQL is reachable. Starting server..."
node server.js
