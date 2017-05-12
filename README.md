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

### Deploy

1. Install perl 5.10.1 or higher

2. Install and run MySQL

3. Install Mojolicious
    ```bash
    wget -O - https://cpanmin.us | perl - -M https://cpan.metacpan.org -n Mojolicious
    ```

4. Create the project's directory:
    ```bash
    mkdir -p -m 0775 /home/caffeine_manager/
    cd /home/caffeine_manager/
    ```

5. Clone repository to this new dir
    ```bash
    git clone "https://github.com/graywolfxxx/caffeine_manager" ./
    ```

6. Init DB
    ```bash
    mysql < sql/init_db.sql
    ```

### Run application using Morbo development server

1. Run application
    ```bash
    morbo script/caffeine
    ```

2. Run console scripts to work with application and get some test results
    ```bash
    ./bin/test_adding.sh
    ./bin/test_stat.sh
    ```

### Run application using Apache2

1. Install Apache2

2. Add to /etc/hosts of your server following string
    ```bash
    127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 caffeine.com
    ```

3. Open for edit config file of Apache /etc/httpd/conf/httpd.conf. Set or change following:
    ```bash
    Listen 80
    
    # load modules if they haven't been loaded yet in /etc/httpd/conf/httpd.conf
    LoadModule env_module modules/mod_env.so
    LoadModule cgi_module modules/mod_cgi.so

    ServerName 127.0.0.1:80

    # In the end of the config file add virtual host caffeine.com
    NameVirtualHost *:80

    <VirtualHost *:80>
        ServerAdmin root@localhost
        ServerName caffeine.com

        DocumentRoot /home/caffeine_manager
        Options FollowSymLinks
        IndexIgnore *

        RewriteEngine on

        RewriteCond %{DOCUMENT_ROOT}/public/%{REQUEST_URI} -f
        RewriteRule ^(.*)$ /public/$1 [L,NS]

        RewriteCond %{DOCUMENT_ROOT}/public/%{REQUEST_URI} !-f
        RewriteRule ^(.*)$ /script/caffeine/$1 [L,NS,H=cgi-script]

        SetEnv MOJO_MODE "production"
        <Directory "/home/caffeine_manager/script/">
            AllowOverride None
            Options ExecCGI
            Order allow,deny
            Allow from all
        </Directory>

        ErrorLog  logs/caffeine_manager.com-error_log
        CustomLog logs/caffeine_manager.com-access_log common
    </VirtualHost>
    ```

4. Reload Apache
    ```bash
    /etc/init.d/httpd stop
    /etc/init.d/httpd start
    ```
    or
    ```bash
    /etc/init.d/httpd reload
    ```

5. Run console scripts to work with application and get some test results
    ```bash
    ./bin/apache_test_adding.sh
    ./bin/apache_test_stat.sh
    ```
