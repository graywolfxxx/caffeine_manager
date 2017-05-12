#!/bin/bash

srvcurl=$1
args=''

### USER ###
meth='PUT'
uri='/user/request'
echo "$meth $srvcurl$uri$args"
curl -X $meth -H "Content-Type: application/json" -d '{"login":"user1", "password":"password1", "email":"email1@email.com"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

meth='GET'
args='?login=user1&password=password1&email=email1@email.com'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"
args=''

### MACHINE ###
meth='POST'
uri='/machine'
echo "$meth $srvcurl$uri$args"
curl -X $meth -H "Content-Type: application/json" -d '{"name":"office1", "caffeine":"124"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"
echo "$meth $srvcurl$uri$args"
curl -X $meth -H "Content-Type: application/json" -d '{"name":"office2", "caffeine":"205"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"
echo "$meth $srvcurl$uri$args"
curl -X $meth -H "Content-Type: application/json" -d '{"name":"office3", "caffeine":"197"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

meth='PUT'
echo "$meth $srvcurl$uri$args"
curl -X $meth -H "Content-Type: application/json" -d '{"name":"office1", "caffeine":"124"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

### BUYING COFFEE ###
meth='PUT'
uri='/coffee/buy/1/1'
echo "$meth $srvcurl$uri$args  - with incorrect timestamp"
curl -X $meth -H "Content-Type: application/json" -d '{"timestamp":1494582110}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

echo "$meth $srvcurl$uri$args  - with correct timestamp"
curl -X $meth -H "Content-Type: application/json" -d '{"timestamp":"2017-05-12T10:45:11"}' -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/coffee/buy/1/2'
echo "$meth $srvcurl$uri$args  - w/o timestamp"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

meth='GET'
uri='/coffee/buy/1/3'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

