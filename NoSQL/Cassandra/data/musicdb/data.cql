USE musicdb;

COPY performer (name, type, country, style, founded, born, died)
FROM 'home/data/musicdb/performer.csv' WITH HEADER = 'true';

COPY performers_by_style (style, name)
FROM 'home/data/musicdb/performers_by_style.csv' WITH HEADER = 'true';

COPY album (title, year, performer, genre, tracks)
FROM 'home/data/musicdb/album.csv' WITH HEADER = 'true';

COPY albums_by_performer (performer, year, title, genre)
FROM 'home/data/musicdb/albums_by_performer.csv' WITH HEADER = 'true';

COPY albums_by_genre (genre, performer, year, title)
FROM 'home/data/musicdb/albums_by_genre.csv' WITH HEADER = 'true';

COPY albums_by_track (track_title, performer, year, album_title)
FROM 'home/data/musicdb/albums_by_track.csv' WITH HEADER = 'true';

COPY tracks_by_album (album_title, year, performer, genre, number, track_title)
FROM 'home/data/musicdb/tracks_by_album.csv' WITH HEADER = 'true';
