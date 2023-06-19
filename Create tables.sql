DROP TABLE IF EXISTS concert_band;
DROP TABLE IF EXISTS  user_genre;
DROP TABLE IF EXISTS review_tags;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS playlist_songs;
DROP TABLE IF EXISTS playlists;
DROP TABLE IF EXISTS hall_reviews;
DROP TABLE IF EXISTS song_reviews;
DROP TABLE IF EXISTS concert_reviews;
DROP TABLE IF EXISTS concert_videos;
DROP TABLE IF EXISTS concert_photos;
DROP TABLE IF EXISTS concert_archive;
DROP TABLE IF EXISTS user_annonce_concert;
DROP TABLE IF EXISTS user_participate_concerts;
DROP TABLE IF EXISTS songs;
DROP TABLE IF EXISTS concerts;
DROP TABLE IF EXISTS person_belongsTo_association;
DROP TABLE IF EXISTS friend;
DROP TABLE IF EXISTS follow;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'),
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    user_type VARCHAR(20) CHECK (user_type IN ('person', 'band', 'association', 'concert_hall')),
    name VARCHAR(255) NOT NULL,
    pseudo VARCHAR(255) UNIQUE NOT NULL CHECK (pseudo LIKE '@%' AND LENGTH(pseudo) >= 2),
    date_of_birth DATE CHECK ((user_type = 'person' AND date_of_birth IS NOT NULL) OR user_type != 'person'),
    family_name VARCHAR(255) CHECK ((user_type = 'person' AND family_name IS NOT NULL) OR user_type != 'person'),
    date_of_creation DATE CHECK ((user_type = 'association' AND date_of_creation IS NOT NULL) or (user_type = 'band' AND date_of_creation IS NOT NULL) OR (user_type = 'concert_hall' AND date_of_creation IS NOT NULL) or user_type = 'person'),
    account_creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT CHECK ((user_type = 'association' AND description IS NOT NULL) OR (user_type = 'concert_hall' AND description IS NOT NULL) OR user_type != 'band' OR user_type != 'person'),
    street_number INT CHECK ((user_type = 'concert_hall' AND street_number IS NOT NULL) OR user_type != 'concert_hall'),
    street_name VARCHAR(255) CHECK ((user_type = 'concert_hall' AND street_name IS NOT NULL) OR user_type != 'concert_hall'),
    postal_code VARCHAR(10) CHECK ((user_type = 'concert_hall' AND postal_code IS NOT NULL) OR user_type != 'concert_hall'),
    city VARCHAR(255) CHECK ((user_type = 'concert_hall' AND city IS NOT NULL) OR user_type != 'concert_hall'),
    country VARCHAR(255) CHECK ((user_type = 'concert_hall' AND country IS NOT NULL) OR user_type != 'concert_hall'),
    address_complement VARCHAR(255) CHECK ((user_type = 'concert_hall' AND address_complement IS NOT NULL) OR user_type != 'concert_hall'),
    capacity INT CHECK ((user_type = 'concert_hall' AND capacity IS NOT NULL) OR user_type != 'concert_hall')
);



CREATE TABLE follow (
    follower VARCHAR(255) NOT NULL REFERENCES users (email),
    followed VARCHAR(255) NOT NULL REFERENCES users (email),
    PRIMARY KEY (follower, followed)
);

CREATE TABLE friend (
    user1   VARCHAR(255) NOT NULL REFERENCES users (email),
    user2  VARCHAR(255) NOT NULL REFERENCES users (email),
    PRIMARY KEY (user1, user2)
);

CREATE TABLE person_belongsTo_association (
    person VARCHAR(255) REFERENCES users(email),
    association VARCHAR(255) REFERENCES users(email),
    PRIMARY KEY (person, association)
);

CREATE TABLE concerts (
    concert_id SERIAL PRIMARY KEY,
    concert_name VARCHAR(255) NOT NULL,
    organizer VARCHAR(255) NOT NULL REFERENCES users(email),
    location VARCHAR(255),
    price DECIMAL(10, 2),
    line_up TEXT,
    available_places INT,
    volunteers_needed INT,
    cause VARCHAR(255),
    outdoor BOOLEAN,
    children_allowed BOOLEAN,
    concert_date TIMESTAMP NOT NULL,
    concert_description TEXT
);

CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    band_id INT REFERENCES users(user_id),
    title TEXT NOT NULL,
    duration TIME,
    release_year INT,
    CHECK (release_year > 1900 AND release_year < EXTRACT(YEAR FROM CURRENT_DATE)+1)
);


CREATE TABLE user_participate_concerts (
    user_email VARCHAR(255) NOT NULL REFERENCES users(email),
    concert_id INT NOT NULL REFERENCES concerts(concert_id),
    is_interested BOOLEAN,
    is_participating BOOLEAN,
    CHECK (NOT (is_interested AND is_participating)),  -- an user cannot be interested and participating at the same time
    PRIMARY KEY (user_email, concert_id)
);

CREATE TABLE user_annonce_concert (
    user_email VARCHAR(255) NOT NULL REFERENCES users(email),
    concert_id INT NOT NULL REFERENCES concerts(concert_id),
    PRIMARY KEY(user_email, concert_id)
);

CREATE TABLE concert_archive (
    concert_id INT PRIMARY KEY REFERENCES concerts(concert_id),
    num_attendees INT
);

CREATE TABLE concert_photos (
    photo_id SERIAL PRIMARY KEY,
    concert_id INT NOT NULL REFERENCES concert_archive(concert_id),
    photo_url TEXT NOT NULL
);

CREATE TABLE concert_videos (
    video_id SERIAL PRIMARY KEY,
    concert_id INT NOT NULL REFERENCES concert_archive(concert_id),
    video_url TEXT NOT NULL
);

CREATE TABLE concert_reviews (
    review_id SERIAL PRIMARY KEY,
    concert_id INT NOT NULL REFERENCES concert_archive(concert_id),
    user_email VARCHAR(255) NOT NULL REFERENCES users(email),
    review_text TEXT,
    review_date TIMESTAMP NOT NULL,
    band_reviewed VARCHAR(255),
    rating INT CHECK (rating >= 1 AND rating <= 5)  -- ratings from 1 to 5
);


CREATE TABLE song_reviews (
    review_id SERIAL PRIMARY KEY,
    song_id INT NOT NULL REFERENCES songs(song_id),
    user_email VARCHAR(255) NOT NULL REFERENCES users(email),
    review_text TEXT,
    review_date TIMESTAMP NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5)  -- ratings from 1 to 5
);

CREATE TABLE hall_reviews (
    review_id SERIAL PRIMARY KEY,
    hall_id INT NOT NULL REFERENCES users(user_id),
    user_email VARCHAR(255) NOT NULL REFERENCES users(email),
    review_text TEXT,
    review_date TIMESTAMP NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5)  -- ratings from 1 to 5
);

CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    title TEXT NOT NULL
);

CREATE TABLE playlist_songs (
    playlist_id INT REFERENCES playlists(playlist_id),
    song_id INT REFERENCES songs(song_id),
    PRIMARY KEY (playlist_id, song_id)
);


CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(255) NOT NULL UNIQUE,
    parent_genre_id INT REFERENCES genres(genre_id)
);

CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    review_type VARCHAR(10) NOT NULL CHECK(review_type in('user', 'song', 'concert')),
    object_id INT NOT NULL,
    user_id INT NOT NULL REFERENCES users(user_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT
);


CREATE TABLE review_tags (
    review_id INT NOT NULL REFERENCES reviews(review_id),
    tag_id INT NOT NULL REFERENCES tags(tag_id),
    PRIMARY KEY(review_id, tag_id)
);

CREATE TABLE user_genre (
    user_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY(user_id, genre_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE concert_band (
    concert_id INT NOT NULL,
    band_id INT NOT NULL,
    PRIMARY KEY(concert_id, band_id),
    FOREIGN KEY(concert_id) REFERENCES concerts(concert_id),
    FOREIGN KEY(band_id) REFERENCES users(user_id)  -- Assuming bands are represented as users
);
