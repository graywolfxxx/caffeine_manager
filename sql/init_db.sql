CREATE DATABASE IF NOT EXISTS caffeine;

USE caffeine;

CREATE TABLE IF NOT EXISTS Caffeine_User (
    id            int unsigned NOT NULL AUTO_INCREMENT,
    login         varchar(100) NOT NULL,
    password      varchar(100) NOT NULL,
    email         varchar(100) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY ux_login (login),
    UNIQUE KEY ux_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS Caffeine_Machine (
    id            int unsigned NOT NULL AUTO_INCREMENT,
    name          varchar(100),
    caffeine      int unsigned NOT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS Caffeine_Link_UserMachine (
    user_id       int unsigned NOT NULL,
    machine_id    int unsigned NOT NULL,
    `timestamp`   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_user_timestamp (user_id, `timestamp`),
    KEY idx_machine_timestamp (machine_id, `timestamp`),
    KEY idx_timestamp (`timestamp`),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES Caffeine_User (id) ON DELETE CASCADE,
    CONSTRAINT fk_machine FOREIGN KEY (machine_id) REFERENCES Caffeine_Machine (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

