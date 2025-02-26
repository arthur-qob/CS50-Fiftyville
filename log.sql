-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Find crime scene description
SELECT id, description
FROM crime_scene_reports
WHERE day = 28 AND month = 7 AND street LIKE '%Humphrey%';

-- Look for interviews' transcript that fits the description of the theft. Keyword: bakery.
SELECT id, transcript
FROM interviews
WHERE day = 28 AND month = 7 AND transcript LIKE '%bakery%';

-- Look fot the name, time and license plate of people who left the bakery in that window of time.
SELECT bakery_security_logs.hour, bakery_security_logs.minute, people.name, bakery_security_logs.license_plate, bakery_security_logs.activity
FROM bakery_security_logs
JOIN people ON people.license_plate = bakery_security_logs.license_plate
WHERE day = 28 AND month = 7 AND hour = 10 AND minute >= 15 AND minute <= 25;

-- Look for names of people who made transactions of the type 'withdraw' earlier that day in Legget Street.
SELECT people.name, atm_transactions.transaction_type, atm_transactions.atm_location
FROM people
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE atm_transactions.day = 28 AND atm_transactions.month = 7
AND atm_transactions.transaction_type = 'withdraw' AND atm_transactions.atm_location LIKE '%Legget%';

-- Look for phone calls that lasted less than a minute, the caller and receiver's name and phone number.

-- Add new columns into phone_calls to find the names of the caller and reciever of each call

-- ALTER TABLE phone_calls
-- ADD caller_name text;

-- ALTER TABLE phone_calls
-- ADD receiver_name text;

UPDATE phone_calls
SET caller_name = people.name
FROM people
WHERE phone_calls.caller = people.phone_number;

UPDATE phone_calls
SET receiver_name = people.name
FROM people
WHERE phone_calls.receiver = people.phone_number;

SELECT caller, caller_name, receiver, receiver_name
FROM phone_calls
WHERE day = 28 AND month = 7 AND duration < 60;

-- Look for the earliest flight the next day

-- ALTER TABLE flights
-- ADD origin_city text;

-- ALTER TABLE flights
-- ADD destination_city text;

UPDATE flights
SET origin_city = airports.city
FROM airports
WHERE flights.origin_airport_id = airports.id;

UPDATE flights
SET destination_city = airports.city
FROM airports
WHERE flights.destination_airport_id = airports.id;

SELECT id, hour, minute, origin_city, destination_city
FROM flights
WHERE day = 29 AND month = 7
ORDER BY hour ASC
LIMIT 1;

-- Look for the names, license_plates and phone number from people that went to New York City on the next day (07/29).

SELECT name, phone_number, license_plate, flights.origin_city, flights.destination_city
FROM people
JOIN flights ON flights.id = passengers.flight_id
JOIN passengers ON passengers.passport_number = people.passport_number
WHERE flights.id = 36
ORDER BY flights.hour ASC;

-- Cross reference the names that appeared in all the previous searches

SELECT name
FROM people
WHERE name IN
(SELECT people.name
FROM bakery_security_logs
JOIN people ON people.license_plate = bakery_security_logs.license_plate
WHERE day = 28 AND month = 7 AND hour = 10 AND minute >= 15 AND minute <= 25)
AND name IN
(SELECT name
FROM people
JOIN atm_transactions ON atm_transactions.account_number = bank_accounts.account_number
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE atm_transactions.day = 28 AND atm_transactions.month = 7
AND atm_transactions.transaction_type = 'withdraw' AND atm_transactions.atm_location LIKE '%Legget%')
AND name IN
(SELECT caller_name
FROM phone_calls
WHERE day = 28 AND month = 7 AND duration < 60)
AND name IN
(SELECT name
FROM people
JOIN flights ON flights.id = passengers.flight_id
JOIN passengers ON passengers.passport_number = people.passport_number
WHERE flights.id = 36
ORDER BY flights.hour ASC);

-- One and only suspect/thief: Bruce.