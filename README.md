# social-news-aggregator
Udiddit, a social news aggregation, web content rating, and discussion website, 
is currently using a risky and unreliable Postgres database schema to store the forum posts, 
discussions, and votes made by their users about different topics.

The schema allows posts to be created by registered users on certain topics, and
can include a URL or a text content. It also allows registered users to cast an upvote
(like) or downvote (dislike) for any forum post that has been created. In addition to
this, the schema also allows registered users to add comments on posts.

**Here is the DDL used to create the schema:**
```sql
CREATE TABLE bad_posts (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(50),
    username VARCHAR(50),
    title VARCHAR(150),
    url VARCHAR(4000) DEFAULT NULL,
    text_content TEXT DEFAULT NULL,
    upvotes TEXT,
    downvotes TEXT
);
CREATE TABLE bad_comments (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    post_id BIGINT,
    text_content TEXT
);
INSERT INTO "bad_posts" VALUES
    (1,'Synergized','Gus32','numquam quia laudantium non sed libero optio sit aliquid aut voluptatem',NULL,'Voluptate ut similique libero architecto accusantium inventore fuga. Maxime est consequatur repellendus commodi. Consequatur veniam debitis consequatur. Et eaque a. Magnam ea rerum eos modi. Accusamus aut impedit perferendis. Quasi est ipsum.','Judah.Okuneva94,Dasia98,Maurice_Dooley14,Dangelo_Lynch59,Brandi.Schaefer,Jayde.Kulas74,Katarina_Hudson,Ken.Murphy42','Lambert.Buckridge0,Joseph_Pouros82,Jesse_Yost')...
```
