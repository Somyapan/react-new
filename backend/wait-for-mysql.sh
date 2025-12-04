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

echo "Checking RDS connection..."
echo "MySQL Host: $MYSQL_HOST"
echo "MySQL Database: $MYSQL_DATABASE"

# For RDS, just start the server - it will retry connections internally
echo "Starting Node.js server..."
node server.js
