BEGIN;
-- DDL
-- This table <PROFILES> stores the users data as in PostgreSql
-- user is a reserved word I rather use profile
CREATE TABLE "profiles" (
    "id" SERIAL,
    "username" VARCHAR(25) NOT NULL,
    CONSTRAINT "profile_pk" PRIMARY KEY ("id"),
    CONSTRAINT "unique user_name" UNIQUE("username"),
    CONSTRAINT "not_empty_username" CHECK(LENGTH("username") > 0)
);

-- For each sessions on the application the user information will be holded
-- Into this table. This way we'll be able to query the DB to
-- List all users who haven’t logged in the last year.
CREATE TABLE "profile_sessions" (
    "id" SERIAL,
    "profile_id" INTEGER,
    "session_date_time" TIMESTAMP,
    CONSTRAINT "profile_sessions_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL
);

-- This Index will prevent from taking long time queriyng for a specific user
CREATE INDEX IF NOT EXISTS "user_name_idx" ON "profiles" ("username" VARCHAR_PATTERN_OPS);

-- Each topic must be on a separated table so when
-- a new post is created topic ID can be used as Foreing key
CREATE TABLE "topics" (
    "id" SERIAL,
    "name" VARCHAR(30) NOT NULL,
    "description" VARCHAR(500),
    "profile_id" INTEGER,
    CONSTRAINT "unique_topic_name" UNIQUE("name"),
    CONSTRAINT "topic_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id"),
    CONSTRAINT "not_empty_topic_name" CHECK(LENGTH("name") > 0)
);

-- In case topic table gets heavier this index will make it quick
-- to query for each topic by it's name
CREATE INDEX IF NOT EXISTS "topic_name_idx" ON "topics" ("name" VARCHAR_PATTERN_OPS);

-- This table stores all posts by storing it's title and url also the date in which
-- the post was created along with the user who created it and the topic it belongs to.
CREATE TABLE "posts" (
    "id" SERIAL,
    "title" VARCHAR(100) NOT NULL,
    "url" TEXT,
    "created_at" TIMESTAMP,
    "topic_id" INTEGER,
    "profile_id" INTEGER,
    CONSTRAINT "posts_pk" PRIMARY KEY ("id"),
    CONSTRAINT "topics_fk" FOREIGN KEY ("topic_id") REFERENCES "topics"("id") ON DELETE CASCADE,
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "not_empty_post_title" CHECK(LENGTH("title") > 0)
);

-- This index will make it quick to search each topic by its title
-- It will also allow for pattern search
CREATE INDEX IF NOT EXISTS "post_title_idx" ON "posts" ("title" VARCHAR_PATTERN_OPS);

-- This table stores the user votes for each post
CREATE TABLE "post_likes" (
    "id" SERIAL,
    "profile_id" INTEGER NOT NULL,
    "post_id" INTEGER NOT NULL,
    "vote" SMALLINT,
    CONSTRAINT "post_likes_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "posts_fk" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
        CONSTRAINT "check_vote" CHECK(
            "vote" = 1
            OR "vote" = -1
        ),
        CONSTRAINT "unique_vote" UNIQUE("profile_id", "post_id")
);

-- This table stores all comments for each post and the comment owner.
CREATE TABLE "comments" (
    "id" SERIAL,
    "text_comment" TEXT NOT NULL,
    "created_at" TIMESTAMP,
    "profile_id" INTEGER,
    "post_id" INTEGER,
    CONSTRAINT "comments_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "posts_fk" FOREIGN KEY ("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
        CONSTRAINT "not_empty_comment_text" CHECK(LENGTH("text_comment") > 0)
);

-- This table stores the user votes for each comment in a specific post
CREATE TABLE "comment_likes" (
    "id" SERIAL,
    "profile_id" INTEGER,
    "comment_id" INTEGER,
    "vote" SMALLINT,
    CONSTRAINT "comments_likes_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "comments_fk" FOREIGN KEY ("comment_id") REFERENCES "comments"("id") ON DELETE CASCADE,
        CONSTRAINT "check_vote" CHECK(
            "vote" = 1
            OR "vote" = -1
        ),
        CONSTRAINT "comment_unique_vote" UNIQUE("profile_id", "comment_id")
);

-- This table will store comment threads for each comment
CREATE TABLE "comment_threads" (
    "id" SERIAL,
    "text_comment" TEXT NOT NULL,
    "created_at" TIMESTAMP,
    "profile_id" INTEGER,
    "comment_id" INTEGER,
    CONSTRAINT "comments_threads_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "comments_fk" FOREIGN KEY ("comment_id") REFERENCES "comments"("id") ON DELETE CASCADE,
        CONSTRAINT "not_empty_comment_thread_text" CHECK(LENGTH("text_comment") > 0)
);

-- This table will store votes for each comment thread
CREATE TABLE "comment_thread_likes" (
    "id" SERIAL,
    "profile_id" INTEGER,
    "comment_thread_id" INTEGER,
    "vote" SMALLINT,
    CONSTRAINT "comments_thread_pk" PRIMARY KEY ("id"),
    CONSTRAINT "profiles_fk" FOREIGN KEY ("profile_id") REFERENCES "profiles"("id") ON DELETE
    SET NULL,
        CONSTRAINT "comment_thread_fk" FOREIGN KEY ("comment_thread_id") REFERENCES "comment_threads"("id") ON DELETE CASCADE,
        CONSTRAINT "check_vote" CHECK(
            "vote" = 1
            OR "vote" = -1
        ),
        CONSTRAINT "comment_thread_unique_vote" UNIQUE("profile_id", "comment_thread_id")
);


--------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------

-- DML
-- INSERT INTO PROFILES
INSERT INTO "profiles" (username)
SELECT DISTINCT "username"
FROM "bad_posts"
WHERE "username" IS NOT NULL
    AND "username" != '';

-----------------------------------------------------------------------------
-- To make sure also the user who voted, commented and didn't post
-- any article also get registered, the next three insert queries will retrieve data from
-- both upvotes and downvotes columns using REGEXP_SPLIT_TO_TABLE function
-- to convert the comma separated usernames list into a table and then check some
-- constraints and insert data into profiles table. The same applies for bad_comments
-- table usernames.

INSERT INTO "profiles" (username)
SELECT u.usernames
FROM
    (SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(upvotes,
         ',') AS usernames
    FROM "bad_posts") u
WHERE u.usernames IS NOT NULL
        AND u.usernames != ''
        AND u.usernames NOT IN
    (SELECT DISTINCT username
    FROM "profiles");

-----------------------------------------------------------------------------
INSERT INTO "profiles" (username)
SELECT u.usernames
FROM
    (SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(downvotes,
         ',') AS usernames
    FROM "bad_posts") u
WHERE u.usernames IS NOT NULL
        AND u.usernames != ''
        AND u.usernames NOT IN
    (SELECT DISTINCT username
    FROM "profiles");
-----------------------------------------------------------------------------
INSERT INTO "profiles" (username)
SELECT DISTINCT username
    FROM "bad_comments" bc
WHERE bc.username IS NOT NULL
        AND bc.username != ''
        AND bc.username NOT IN
    (SELECT DISTINCT username
    FROM "profiles");
----------------------------------------------------------------------------
-- INSERT INTO TOPICS
INSERT INTO "topics" (name)
SELECT DISTINCT topic
FROM "bad_posts"
WHERE "topic" IS NOT NULL
    AND "topic" != '';
-----------------------------------------------------------------------------
-- INSERT INTO POSTS
INSERT INTO "posts" ( title,
         url,
         created_at,
         topic_id,
         profile_id ) SELECT
    CASE
    WHEN LENGTH(bp.title) > 100 THEN
    CONCAT(LEFT(bp.title, 95), '...')
    ELSE bp.title END,
    bp.url, CURRENT_TIMESTAMP, t.id, p.id
FROM "bad_posts" bp
INNER JOIN "profiles" p
    ON p.username = bp.username
INNER JOIN "topics" t
    ON t.name = bp.topic
WHERE title IS NOT NULL
        AND title != '';
---------------------------------------------------------------------------
-- INSERT INTO POST LIKES UPVOTES
WITH T1 AS
    (SELECT username,
        title,
         REGEXP_SPLIT_TO_TABLE(upvotes,
         ',') AS upvotes
    FROM "bad_posts"), T2 AS (
        SELECT pf.id, pf.username
        FROM "profiles" pf
    ), T3 AS (
        SELECT ps.id, ps.title AS title
        FROM "posts" ps
    )
INSERT INTO "post_likes" (profile_id, post_id, vote)
SELECT T2.id, T3.id, 1
FROM T1
INNER JOIN T2
ON T2.username=T1.upvotes
INNER JOIN T3
ON T3.title=T1.title
ORDER BY T1.username ASC;
--------------------------------------------------------------------------------
-- INSERT INTO POST LIKES DOWNVOTES
WITH T1 AS
    (SELECT username,
        title,
         REGEXP_SPLIT_TO_TABLE(downvotes,
         ',') AS downvotes
    FROM "bad_posts"), T2 AS (
        SELECT pf.id, pf.username
        FROM "profiles" pf
    ), T3 AS (
        SELECT ps.id, ps.title AS title
        FROM "posts" ps
    )
INSERT INTO "post_likes" (profile_id, post_id, vote)
SELECT T2.id, T3.id, -1
FROM T1
INNER JOIN T2
ON T2.username=T1.downvotes
INNER JOIN T3
ON T3.title=T1.title
ORDER BY T1.username ASC;
--------------------------------------------------------------------------------
-- INSERT INTO COMMENTS
INSERT INTO "comments" (text_comment, created_at, profile_id, post_id)
SELECT bc.text_content,
         NOW(),
         pf.id,
         ps.id
FROM "bad_comments" bc
INNER JOIN "profiles" pf
    ON bc.username=pf.username
INNER JOIN "posts" ps
    ON bc.post_id=ps.id
WHERE bc.text_content IS NOT NULL
        AND bc.text_content != ''
        AND bc.post_id IS NOT NULL;

COMMIT;