# Caffeine Manager


## Task
The Caffeine Manager allows its users to manage and monitor their caffeine intoxication and helps them to administer their caffeine level. 

Every POST/PUT request accepts json object with keys described below.

Every request returns json object with
<ul>
    <li>status 200 with described keys on success</li>
    <li>status 4xx with optional json error object with mandatory keys
        <ul>
            <li>error_code</li>
            <li>error_text</li>
         </ul>
    </li>
</ul>

`PUT /user/request`
<ul>
    <li>arg keys
        <ul>
            <li>login - mandatory, unique</li>
            <li>password - mandatory</li>
            <li>email - mandatory, unique</li>
         </ul>
    </li>
    <li>result keys
        <ul>
            <li>id</li>
         </ul>
    </li>
</ul>

`POST /machine`
<ul>
    <li>registry machine
        <ul>
            <liname></li>
            <li>caffeine - mg per cup</li>
         </ul>
    </li>
    <li>returns
        <ul>
            <li>id</li>
         </ul>
    </li>
</ul>

`GET /coffee/buy/:user-id/:machine-id`
<ul>
    <li>registry coffee bought by user at current time</li>
</ul>

`PUT /coffee/buy/:user-id/:machine`
<ul>
    <li>similar to GET but use given timestamp</li>
    <li>args
        <ul>
            <li>timestamp - iso-8601 timestamp</li>
         </ul>
    </li>
</ul>

`GET /stats/coffee`
`GET /stats/coffee/machine/:id`
`GET /stats/coffee/user/:id`
<ul>
    <li>return history of user transactions per user/machine/ or global</li>
    <li>list of objects with
        <ul>
            <li>machine - object with name and id keys</li>
            <li>user - object with login and id keys</li>
            <li>timestamp</li>
         </ul>
    </li>
</ul>

`GET /stats/level/user/:id`
<ul>
    <li>return caffeine level history of user</li>
    <li>let’s assume that caffeine level
        <ul>
            <li>increases linearly from 0 to 100% in first hour</li>
            <li>is reduced afterwards by half every 5 hour</li>
         </ul>
    </li>
    <li>return list of levels for past 24 hour using 1h resolution</li>
</ul>


## How to deploy

<ol>
    <li>Install perl 5.10.1 or higher</li>
    <li>Install and run MySQL</li>
    <li>Install Mojolicious
        wget -O - https://cpanmin.us | perl - -M https://cpan.metacpan.org -n Mojolicious
    </li>
    <li>Create the project's directory:
        mkdir -p -m 0775 /home/caffeine_manager/
    </li>
    <li>Clone repository to this new dir
        git clone "https://github.com/graywolfxxx/caffeine_manager" /home/caffeine_manager/
    </li>
    <li>Init DB
        mysql < sql/init_db.sql
    </li>
    <li>Run application using Morbo development server
        morbo script/caffeine
    </li>
    <li>Run console scripts to work with application and get some test results
        ./bin/test_adding.sh
        ./bin/test_stat.sh
    </li>
</ol>
