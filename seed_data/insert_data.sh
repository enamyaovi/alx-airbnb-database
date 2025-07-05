#! /bin/bash

#script to insert data from all csv files in this directory into their respective tables in the database airbnb_clone


#MySQL configuration files
USER="enamyaovi"
DB="airbnb_clone"
HOST="172.17.176.1"

#create a variable that stores connection data to the database
MYSQL="mysql -u $USER -h $HOST $DB -N -B -e"

#disable foreign key checks 
$MYSQL "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE payments; TRUNCATE TABLE bookings; TRUNCATE TABLE reviews; TRUNCATE TABLE messages; TRUNCATE TABLE properties;TRUNCATE TABLE location;TRUNCATE TABLE users;SET FOREIGN_KEY_CHECKS = 1;"

while IFS="," read -r ID CITY STREET
do

    # Escape single quotes to avoid SQL injection issues
    CITY_ESCAPED=${CITY//\'/\\\'}
    STREET_ESCAPED=${STREET//\'/\\\'}

    if [[ $ID != "location_id" ]]
    then    
        LOCATION_ID=$($MYSQL "SELECT location_id FROM location WHERE city='$CITY_ESCAPED' AND street='$STREET_ESCAPED';")
        #if not found
        if [[ -z $LOCATION_ID ]]
        then    
            # insert the city, streed and id values
            INSERT_LOCATION_RESULTS=$($MYSQL "INSERT INTO location(location_id,city,street) VALUES('$ID', '$CITY', '$STREET'); SELECT LAST_INSERT_ID();")
                if [[ $INSERT_LOCATION_RESULTS ]]
                then
                    echo "Inserted: $CITY : $STREET"
                fi
            fi
    fi
done < location.csv

while IFS="," read -r ID FIRST LAST MAIL PWD PHN ROLE CREATED
do
    #check if a user with id exisit
    USER_ID=$($MYSQL "SELECT user_id from users WHERE first_name='$FIRST' AND last_name='$LAST' AND email='$MAIL';")
    #if no entry exists
    if [[ -z $USER_ID ]]
    then    
        USER_INFO_RESULT=$($MYSQL "INSERT INTO users(user_id, first_name, last_name, email, password_hash, phone_number, role) VALUES('$ID', '$FIRST', '$LAST', '$MAIL', '$PWD', '$PHN', '$ROLE'); SELECT LAST_INSERT_ID();")
        if [[ $USER_INFO_RESULT ]]
        then    
            echo "Inserted $FIRST $LAST into users table"
        fi
    fi
done < <(tail -n+2 users.csv) #process substitution chatGPT taught me this

while IFS="," read -r ID HOST NAME DESCRIP LOCAT_ID PRI CREATED_DATE UPDATE_DATE
do
    #escaping the name and description as they can cause SQL injection
    NAME_ESCAPED=${NAME//\'/\\\'}
    DESCRIP_ESCAPED=${DESCRIP//\'/\\\'}

    #check if entry with id already exists
    PROPERTY_ID=$($MYSQL "SELECT property_id FROM properties WHERE host_id='$HOST' AND location_id='$LOCAT_ID' AND name='$NAME_ESCAPED';")

    #if no entry exists
    if [[ -z $PROPERTY_ID ]]
    then
        PROPERTY_RESULTS=$($MYSQL "INSERT INTO properties(property_id, host_id, name, description, location_id, price_per_night) VALUES('$ID', '$HOST', '$NAME_ESCAPED', '$DESCRIP_ESCAPED', '$LOCAT_ID', '$PRI'); SELECT LAST_INSERT_ID();")
        if [[ $PROPERTY_RESULTS ]]
        then
            echo "Property: $NAME added to table"
        fi
    fi
done < <(tail -n+2 properties.csv)


while IFS="," read -r ID PROPERTY GUEST_ID START_D END_D T_PRICE STATUS CREATED

do

    #check if entries already exist
    BOOKING_ID=$($MYSQL "SELECT booking_id FROM bookings WHERE property_id='$PROPERTY' AND user_id='$GUEST_ID' AND start_date='$START_D';")
    if [[ -z $BOOKING_ID ]]
    then
        BOOKING_RESULT=$($MYSQL "INSERT INTO bookings(booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at) VALUES('$ID', '$PROPERTY', '$GUEST_ID', '$START_D', '$END_D', '$T_PRICE', '$STATUS', '$CREATED'); SELECT LAST_INSERT_ID();")
        if [[ $BOOKING_RESULT ]]
        then
            echo "Booking entered"
        fi
    fi
done < <( tail -n+2 bookings.csv)

while IFS="," read -r ID BOOKING AMNT PAY_D PAY_M
do
    #ensure no entry with data exists
    PAYMENT_ID=$($MYSQL "SELECT payment_id FROM payments WHERE booking_id='$BOOKING';")
    if [[ -z $PAYMENT_ID ]]
    then
        #insert the value
        PAYMENT_RESULT=$($MYSQL "INSERT INTO payments(payment_id, booking_id, amount, payment_date, payment_method) VALUES('$ID', '$BOOKING', '$AMNT', '$PAY_D', '$PAY_M'); SELECT LAST_INSERT_ID();")
        if [[ $PAYMENT_RESULT ]]
        then
            echo "Payment registered"
        fi
    fi
done < <(tail -n+2 payments.csv)

while IFS="," read -r ID PROP_ID USER_D RATE COMM CREATD
do
    COMM_ESCAPED=${COMM//\'/\\\'}

    REVIEW_ID=$($MYSQL "SELECT review_id FROM reviews WHERE property_id='$PROP_ID' AND user_id='$USER_D' AND comment='$COMM_ESCAPED';")

    if [[ -z $REVIEW_ID ]]
    then
        REVIEW_RESULT=$($MYSQL "INSERT INTO reviews(review_id, property_id, user_id, rating, comment, created_at) VALUES('$ID', '$PROP_ID', '$USER_D', '$RATE', '$COMM_ESCAPED', '$CREATD'); SELECT LAST_INSERT_ID();")
        if [[ $REVIEW_RESULT ]]
        then 
            echo "Comment Added"
        fi
    fi
done < <( tail -n+2 reviews.csv)

while IFS="," read -r ID SENDER RECIEPT MESSAGE SENT
do
    MESS_ESCAPED=${MESSAGE//\'/\\\'}
    #check for existing message id
    MESSAGE_ID=$($MYSQL "SELECT message_id FROM messages WHERE sender_id='$SENDER' AND recipient_id='$RECIEPT' AND message_body='$MESS_ESCAPED';")
    if [[ -z $MESSAGE_ID ]]
    then
        MESSAGE_RESULT=$($MYSQL "INSERT INTO messages(message_id, sender_id, recipient_id, message_body, sent_at) VALUES('$ID', '$SENDER', '$RECIEPT', '$MESS_ESCAPED', '$SENT'); SELECT LAST_INSERT_ID();")
        if [[ $MESSAGE_RESULT ]]
        then
            echo "Message added to database"
        fi
    fi

done < <( tail -n+2 messages.csv)