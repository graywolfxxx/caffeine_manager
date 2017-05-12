#!/bin/bash

srvcurl='http://localhost:3000'
meth='GET'
args=''

### stats/coffee ###
uri='/stats/coffee'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/machine/1'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/machine/2'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/machine/3'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/machine/3000000000'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/user/1'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/coffee/user/100000'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"


### level ###
uri='/stats/level/user/1'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

uri='/stats/level/user/100000'
echo "$meth $srvcurl$uri$args"
curl -X $meth -o - -s -w "\nStatus: %{http_code}\n\n" "$srvcurl$uri$args"

