-- cherche user
select *
from users
where pseudo like '@j%';

--chercher concert
select *
from concerts
where concert_name like '%Concert%';

--chercher chanson
select *
from songs
where song_name like '%song%';

-- les playlist d'un user
SELECT playlists.title
FROM playlists
    JOIN users ON playlists.user_id = users.user_id
WHERE users.pseudo ='@jean';


--toutes les songs d'une playlist
SELECT songs.title
FROM songs
    JOIN playlist_songs ON songs.song_id = playlist_songs.song_id
WHERE playlist_songs.playlist_id = 3;

-- Les personnes suivies
SELECT u2.pseudo AS followed
FROM follow f
    JOIN users u1 ON f.follower = u1.user_id
    JOIN users u2 ON f.followed = u2.user_id
WHERE u1.pseudo = '@jean';

-- Les abonnés
SELECT u2.pseudo AS follower
FROM follow f
    JOIN users u1 ON f.followed = u1.user_id
    JOIN users u2 ON f.follower = u2.user_id
WHERE u1.pseudo = '@jean';

-- Les amis
SELECT
    CASE 
    WHEN u1.pseudo = '@jean' THEN u2.pseudo 
    ELSE u1.pseudo 
  END AS friend
FROM friend f
    JOIN users u1 ON f.user1 = u1.user_id
    JOIN users u2 ON f.user2 = u2.user_id
WHERE u1.pseudo = '@jean' OR u2.pseudo = '@jean';



--tous les genre et les parents d'une chanson
WITH RECURSIVE genre_hierarchy AS
    (
        SELECT genre_id, genre_name, parent_genre_id
    FROM genres
    WHERE genre_id IN (SELECT genre_id
    FROM song_genres
    WHERE song_id = 2)
UNION ALL
    SELECT g.genre_id, g.genre_name, g.parent_genre_id
    FROM genres g
        INNER JOIN genre_hierarchy gh ON g.genre_id = gh.parent_genre_id
)
SELECT *
FROM genre_hierarchy;

-- les genre et super genre d'un groupe:
WITH RECURSIVE genre_hierarchy AS
    (
        SELECT genre_id, genre_name, parent_genre_id
    FROM genres
    WHERE genre_id IN (SELECT genre_id
    FROM user_genre
    WHERE user_id = (SELECT user_id
    FROM users
    WHERE pseudo = '[BAND_PSEUDO]'))
UNION ALL
    SELECT g.genre_id, g.genre_name, g.parent_genre_id
    FROM genres g
        INNER JOIN genre_hierarchy gh ON g.genre_id = gh.parent_genre_id
)
SELECT *
FROM genre_hierarchy;


--songs d'un genre et les sous genre
WITH RECURSIVE genre_hierarchy AS
    (
        SELECT genre_id, genre_name, parent_genre_id
    FROM genres
    WHERE genre_name = 'Rock'
UNION ALL

    SELECT g.genre_id, g.genre_name, g.parent_genre_id
    FROM genres g
        INNER JOIN genre_hierarchy gh ON gh.genre_id = g.parent_genre_id
)
SELECT s.*
FROM songs s
    JOIN song_genres sg ON s.song_id = sg.song_id
    JOIN genre_hierarchy gh ON sg.genre_id = gh.genre_id;


--bands d'un genre et sous genres
WITH RECURSIVE genre_hierarchy AS
    (
        SELECT genre_id, genre_name, parent_genre_id
    FROM genres
    WHERE genre_name = 'Rock'

UNION ALL

    SELECT g.genre_id, g.genre_name, g.parent_genre_id
    FROM genres g
        INNER JOIN genre_hierarchy gh ON gh.genre_id = g.parent_genre_id
)
SELECT u.*
FROM users u
    JOIN user_genre ug ON u.user_id = ug.user_id
    JOIN genre_hierarchy gh ON ug.genre_id = gh.genre_id
WHERE u.user_type = 'band';


-- les followers réciproques:
SELECT u.pseudo AS follower_followed
FROM users u
    JOIN follow f1 ON f1.follower = u.email
    JOIN follow f2 ON f2.followed = u.email
WHERE f1.followed = (SELECT email
    FROM users
    WHERE pseudo = '@jean') AND f2.follower = (SELECT email
    FROM users
    WHERE pseudo = '@jean');

--les followed d'un coté uniquement
SELECT u.pseudo AS followed
FROM users u
    JOIN follow f1 ON f1.followed = u.email
    LEFT JOIN follow f2 ON f2.follower = u.email AND f2.followed = (SELECT email
        FROM users
        WHERE pseudo = '@jean')
WHERE f1.follower = (SELECT email
    FROM users
    WHERE pseudo = '@jean') AND f2.follower IS NULL;

--amis de mes amis:
WITH
    direct_friends
    AS
    (
        SELECT
            CASE
            WHEN f.user1 = (SELECT email
            FROM users
            WHERE pseudo = 'your_pseudo') THEN f.user2
            ELSE f.user1
        END AS email
        FROM
            friend f
        WHERE 
        f.user1 = (SELECT email
            FROM users
            WHERE pseudo = '@jean') OR
            f.user2 = (SELECT email
            FROM users
            WHERE pseudo = '@jean')
    )
SELECT u.pseudo
FROM users u
WHERE u.email IN (
    SELECT
        CASE
            WHEN f.user1 = df.email THEN f.user2
            ELSE f.user1
        END
    FROM
        friend f
        JOIN
        direct_friends df ON f.user1 = df.email OR f.user2 = df.email
)
    AND u.email NOT IN (
    SELECT email
    FROM direct_friends
)
    AND u.email != (SELECT email
    FROM users
    WHERE pseudo = '@jean');

--note moyenne d'une chanson
SELECT
    object_id as Song_id,
    AVG(rating) AS average_rating
FROM
    reviews
WHERE 
    object_id = 2 and review_typr='song'
GROUP BY 
    object_id;


--liste des concert que user est interessé par
SELECT 
    c.*
FROM 
    concerts c
JOIN 
    user_participate_concerts upc ON c.concert_id = upc.concert_id
WHERE 
    upc.is_interested = true AND 
    upc.user_email = (SELECT email FROM users WHERE pseudo = '@jean');


--idem, participation
SELECT 
    c.*
FROM 
    concerts c
JOIN 
    user_participate_concerts upc ON c.concert_id = upc.concert_id
WHERE 
    upc.is_participating = true AND 
    upc.user_email = (SELECT email FROM users WHERE pseudo = '@jean');


--liste des reviews d'une band
SELECT 
    *
FROM 
    reviews 
WHERE 
   review_type='user' and object_id = (select user_id from users where user_type='band' and pseudo='@lesmoustiques');


--liste des reviews d'une song
SELECT 
    *
FROM 
    reviews 
WHERE 
   review_type='song' and object_id = (select song_id from songs where title='Song 2');


-- recherche par tag
SELECT 
    comment AS content,
    'review' AS type
FROM 
    reviews
WHERE 
    review_id IN (
        SELECT 
            review_id 
        FROM 
            review_tags 
        WHERE 
            tag_id = (
                SELECT 
                    tag_id 
                FROM 
                    tags 
                WHERE 
                    tag_name = 'Innovative'
            )
    ) or comment like '%#innovative%'
UNION
SELECT 
    pseudo AS content,
    'user' AS type
FROM 
    users
WHERE 
    pseudo LIKE '%Innovative%'
UNION
SELECT 
    concert_name AS content,
    'concert' AS type
FROM 
    concerts
WHERE 
    concert_name LIKE '%Innovative%';