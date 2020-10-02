DROP KEYSPACE IF EXISTS musicdb;

CREATE KEYSPACE IF NOT EXISTS musicdb WITH replication = {'class':'SimpleStrategy','replication_factor':3};

USE musicdb;

CREATE TABLE IF NOT EXISTS performer (
  name VARCHAR,
  type VARCHAR,
  country VARCHAR,
  style VARCHAR,
  founded INT,
  born INT,
  died INT,
  PRIMARY KEY (name)
);

CREATE TABLE IF NOT EXISTS performers_by_style (
  style VARCHAR,
  name VARCHAR,
  PRIMARY KEY (style, name)
);

CREATE TABLE IF NOT EXISTS album (
  title VARCHAR,
  year INT,
  performer VARCHAR,
  genre VARCHAR,
  tracks MAP<INT,VARCHAR>,
  PRIMARY KEY ((title, year))
);

CREATE TABLE IF NOT EXISTS albums_by_performer (
  performer VARCHAR,
  year INT,
  title VARCHAR,
  genre VARCHAR,
  PRIMARY KEY (performer, year, title)
) WITH CLUSTERING ORDER BY (year DESC, title ASC);

CREATE TABLE IF NOT EXISTS albums_by_genre (
  genre VARCHAR,
  performer VARCHAR,
  year INT,
  title VARCHAR,
  PRIMARY KEY (genre, performer, year, title)
) WITH CLUSTERING ORDER BY (performer ASC, year DESC, title ASC);


CREATE TABLE IF NOT EXISTS albums_by_track (
  track_title VARCHAR,
  performer VARCHAR,
  year INT,
  album_title VARCHAR,
  PRIMARY KEY (track_title, performer, year, album_title)
) WITH CLUSTERING ORDER BY (performer ASC, year DESC, album_title ASC);

CREATE TABLE IF NOT EXISTS tracks_by_album (
  album_title VARCHAR,
  year INT,
  performer VARCHAR STATIC,
  genre VARCHAR STATIC,
  number INT,
  track_title VARCHAR,
  PRIMARY KEY ((album_title, year), number)
);
