package App::MultiUser::DB::Migration::000InitialSchema;
use strict;
use warnings;
use Moose;
use App::MultiUser;
use App::MultiUser::DB::Migration;

sub version { "0.001" };

#{{{ PG
#List of entity tables
add_step pg => <<EOT;
CREATE TABLE entity_table(
  entity_table_id SERIAL NOT NULL PRIMARY KEY,
  table_name           TEXT   NOT NULL UNIQUE
)
EOT

#List of entities
add_step pg => <<EOT;
CREATE TABLE entity(
  entity_id       SERIAL  NOT NULL PRIMARY KEY,
  entity_table_id INTEGER NOT NULL REFERENCES entity_table( entity_table_id ),
  object_id       INTEGER,
  UNIQUE( entity_table_id, object_id )
)
EOT

#Version tracking
add_step pg => <<EOT;
CREATE TABLE unit_version(
  unit_version_id  SERIAL NOT NULL PRIMARY KEY,
  item        TEXT   NOT NULL UNIQUE,
  unit_version     TEXT   NOT NULL
)
EOT
add_step pg => <<EOT;
INSERT INTO unit_version( item, unit_version ) VALUES( 'App::MultiUser', '0.001' );
EOT

#Properties for entities
add_step pg => <<EOT;
CREATE TABLE property (
  property_id SERIAL  NOT NULL PRIMARY KEY,
  entity_id   INTEGER NOT NULL REFERENCES entity( entity_id ),
  name        TEXT    NOT NULL,
  value       TEXT    DEFAULT NULL,
  UNIQUE( entity_id, name )
)
EOT

#Roles
add_step pg => <<EOT;
CREATE TABLE role (
  role_id   SERIAL  NOT NULL PRIMARY KEY,
  entity_id INTEGER NOT NULL REFERENCES entity( entity_id ),
  name      TEXT    NOT NULL UNIQUE
)
EOT
add_step pg => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'role' );
EOT

#Tracks role memberships
add_step pg => <<EOT;
CREATE TABLE role_membership (
  membership_id SERIAL  NOT NULL PRIMARY KEY,
  parent_id     INTEGER NOT NULL REFERENCES role( role_id ),
  member_id     INTEGER NOT NULL REFERENCES role( role_id ),
  UNIQUE( parent_id, member_id )
)
EOT

#Table for users
add_step pg => <<EOT;
CREATE TABLE account (
  account_id SERIAL  NOT NULL PRIMARY KEY,
  entity_id  INTEGER NOT NULL REFERENCES entity( entity_id ),
  role_id    INTEGER NOT NULL UNIQUE REFERENCES role( role_id )
)
EOT
add_step pg => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'account' );
EOT

#Table for right types
add_step pg => <<EOT;
CREATE TABLE privilege (
  privilege_id SERIAL  NOT NULL PRIMARY KEY,
  entity_id    INTEGER NOT NULL REFERENCES entity( entity_id ),
  name         TEXT    NOT NULL UNIQUE
)
EOT
add_step pg => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'privilege' );
EOT

#Privliges that grant other privileges
add_step pg => <<EOT;
CREATE TABLE privilege_chain (
  privilege_chain_id SERIAL NOT NULL PRIMARY KEY,
  parent_id INTEGER REFERENCES privilege( privilege_id ),
  member_id INTEGER REFERENCES privilege( privilege_id ),
  UNIQUE( parent_id, member_id )
)
EOT

#Table for granted permissions
add_step pg => <<EOT;
CREATE TABLE permission (
  permission_id SERIAL  NOT NULL PRIMARY KEY,
  privilege_id  INTEGER REFERENCES privilege( privilege_id ) NOT NULL,
  role_id       INTEGER REFERENCES role( role_id ) NOT NULL,
  entity_id     INTEGER REFERENCES entity( entity_id ) DEFAULT NULL
)
EOT
#}}}
#{{{ SQLite
#List of entity tables
add_step sqlite => <<EOT;
CREATE TABLE entity_table(
entity_table_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
table_name           TEXT   NOT NULL UNIQUE
)
EOT

#List of entities
add_step sqlite => <<EOT;
CREATE TABLE entity(
entity_id       INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
entity_table_id INTEGER NOT NULL REFERENCES entity_table( entity_table_id ),
object_id       INTEGER,
UNIQUE( entity_table_id, object_id )
)
EOT

#Version tracking
add_step sqlite => <<EOT;
CREATE TABLE unit_version(
unit_version_id  INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
item        TEXT   NOT NULL UNIQUE,
unit_version     TEXT   NOT NULL
)
EOT
add_step sqlite => <<EOT;
INSERT INTO unit_version( item, unit_version ) VALUES( 'App::MultiUser', '0.001' );
EOT

#Properties for entities
add_step sqlite => <<EOT;
CREATE TABLE property (
property_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
entity_id   INTEGER NOT NULL REFERENCES entity( entity_id ),
name        TEXT    NOT NULL,
value       TEXT    DEFAULT NULL,
UNIQUE( entity_id, name )
)
EOT

#Roles
add_step sqlite => <<EOT;
CREATE TABLE role (
role_id   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
entity_id INTEGER NOT NULL REFERENCES entity( entity_id ),
name      TEXT    NOT NULL UNIQUE
)
EOT
add_step sqlite => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'role' );
EOT

#Tracks role memberships
add_step sqlite => <<EOT;
CREATE TABLE role_membership (
membership_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
parent_id     INTEGER NOT NULL REFERENCES role( role_id ),
member_id     INTEGER NOT NULL REFERENCES role( role_id ),
UNIQUE( parent_id, member_id )
)
EOT

#Table for users
add_step sqlite => <<EOT;
CREATE TABLE account (
account_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
entity_id  INTEGER NOT NULL REFERENCES entity( entity_id ),
role_id    INTEGER NOT NULL UNIQUE REFERENCES role( role_id )
)
EOT
add_step sqlite => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'account' );
EOT

#Table for right types
add_step sqlite => <<EOT;
CREATE TABLE privilege (
privilege_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
entity_id    INTEGER NOT NULL REFERENCES entity( entity_id ),
name         TEXT    NOT NULL UNIQUE
)
EOT
add_step sqlite => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'privilege' );
EOT

#Privliges that grant other privileges
add_step sqlite => <<EOT;
CREATE TABLE privilege_chain (
privilege_chain_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
parent_id INTEGER REFERENCES privilege( privilege_id ),
member_id INTEGER REFERENCES privilege( privilege_id ),
UNIQUE( parent_id, member_id )
)
EOT

#Table for granted permissions
add_step sqlite => <<EOT;
CREATE TABLE permission (
permission_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
privilege_id  INTEGER REFERENCES privilege( privilege_id ) NOT NULL,
role_id       INTEGER REFERENCES role( role_id ) NOT NULL,
entity_id     INTEGER REFERENCES entity( entity_id ) DEFAULT NULL
)
EOT
#}}}
#{{{ MySQL
#List of entity tables
add_step mysql => <<EOT;
CREATE TABLE entity_table(
entity_table_id INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY,
table_name           VARCHAR(255)   NOT NULL UNIQUE
) ENGINE=InnoDB
EOT

#List of entities
add_step mysql => <<EOT;
CREATE TABLE entity(
entity_id       INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
entity_table_id INTEGER NOT NULL, FOREIGN KEY ( entity_table_id ) REFERENCES entity_table( entity_table_id ),
object_id       INTEGER,
UNIQUE( entity_table_id, object_id )
) ENGINE=InnoDB
EOT

#Version tracking
add_step mysql => <<EOT;
CREATE TABLE unit_version(
unit_version_id  INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY,
item        VARCHAR(255)   NOT NULL UNIQUE,
unit_version     TEXT   NOT NULL
) ENGINE=InnoDB
EOT
add_step mysql => <<EOT;
INSERT INTO unit_version( item, unit_version ) VALUES( 'App::MultiUser', '0.001' );
EOT

#Properties for entities
add_step mysql => <<EOT;
CREATE TABLE property (
property_id INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
entity_id   INTEGER NOT NULL, FOREIGN KEY ( entity_id ) REFERENCES entity( entity_id ),
name        VARCHAR(255)    NOT NULL,
value       TEXT    DEFAULT NULL,
UNIQUE( entity_id, name )
) ENGINE=InnoDB
EOT

#Roles
add_step mysql => <<EOT;
CREATE TABLE role (
role_id   INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
entity_id INTEGER NOT NULL, FOREIGN KEY ( entity_id ) REFERENCES entity( entity_id ),
name      VARCHAR(255)    NOT NULL UNIQUE
) ENGINE=InnoDB
EOT
add_step mysql => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'role' );
EOT

#Tracks role memberships
add_step mysql => <<EOT;
CREATE TABLE role_membership (
membership_id INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
parent_id     INTEGER NOT NULL, FOREIGN KEY ( parent_id ) REFERENCES role( role_id ),
member_id     INTEGER NOT NULL, FOREIGN KEY ( member_id ) REFERENCES role( role_id ),
UNIQUE( parent_id, member_id )
) ENGINE=InnoDB
EOT

#Table for users
add_step mysql => <<EOT;
CREATE TABLE account (
account_id INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
entity_id  INTEGER NOT NULL, FOREIGN KEY ( entity_id ) REFERENCES entity( entity_id ),
role_id    INTEGER NOT NULL UNIQUE, FOREIGN KEY ( role_id ) REFERENCES role( role_id )
) ENGINE=InnoDB
EOT
add_step mysql => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'account' );
EOT

#Table for right types
add_step mysql => <<EOT;
CREATE TABLE privilege (
privilege_id INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
entity_id    INTEGER NOT NULL, FOREIGN KEY ( entity_id ) REFERENCES entity( entity_id ),
name         VARCHAR(255)    NOT NULL UNIQUE
) ENGINE=InnoDB
EOT
add_step mysql => <<EOT;
INSERT INTO entity_table( table_name ) VALUES( 'privilege' );
EOT

#Privliges that grant other privileges
add_step mysql => <<EOT;
CREATE TABLE privilege_chain (
privilege_chain_id INTEGER AUTO_INCREMENT NOT NULL PRIMARY KEY,
parent_id INTEGER, FOREIGN KEY ( parent_id ) REFERENCES privilege( privilege_id ),
member_id INTEGER, FOREIGN KEY ( member_id ) REFERENCES privilege( privilege_id ),
UNIQUE( parent_id, member_id )
) ENGINE=InnoDB
EOT

#Table for granted permissions
add_step mysql => <<EOT;
CREATE TABLE permission (
permission_id INTEGER AUTO_INCREMENT  NOT NULL PRIMARY KEY,
privilege_id  INTEGER NOT NULL, FOREIGN KEY ( privilege_id ) REFERENCES privilege( privilege_id ),
role_id       INTEGER NOT NULL, FOREIGN KEY ( role_id ) REFERENCES role( role_id ),
entity_id     INTEGER DEFAULT NULL, FOREIGN KEY ( entity_id ) REFERENCES entity( entity_id )
) ENGINE=InnoDB
EOT
#}}}

1;

__END__
