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

## Part I: Investigate the existing schema
As a first step, investigate this schema and some of the sample data in the project’s
SQL workspace. Then, in my own words, outline three (3) or more specific things that could
be improved about this schema.

### The database is not well normalized...
bad_posts table:
* Both columns upvotes and downvotes violates the 1 st Normal Form on
storing a list of comma separated values on a single column.
* There is a violation of the 2 nd Normal Form also there is a transitive
dependencies between title and post topic.
* The bad_posts must be splitted,and new tables must be created, Users,
Posts, Topics, Votes, Comments, Post_Comments;
* Username must be replaced with user_id from bad_comments.

## Part II: Create the DDL for my new schema
Having done this initial investigation and assessment, my next goal is to dive deep
into the heart of the problem and create a new schema for Udiddit. My new
schema should at least reflect fixes to the shortcomings I pointed to in the
previous exercise. 
#### A few guidelines are provided
**1. Guideline #1:** here is a list of features and specifications that Udiddit needs in
order to support its website and administrative interface:

**A. Allow new users to register:**
i. Each username has to be unique
ii. Usernames can be composed of at most 25 characters
iii. Usernames can’t be empty
iv. We won’t worry about user passwords for this project

**B. Allow registered users to create new topics:**
i.Topic names have to be unique.
ii.The topic's name is at most 30 characters
iii.The topic's name can't be empty
iv.Topics can have an optional description of at most 500 characters.

**C. Allow registered users to create new posts on existing topics:**
i. Posts have a required title of at most 100 characters
ii. The title of a post can't be empty.
iii. Posts should contain either a URL or a text content, but not both.
iv.If a topic gets deleted, all the posts associated with it should be automatically deleted too.
v. If the user who created the post gets deleted, then the post will remain, but it will become dissociated from that user.

**D. Allow registered users to comment on existing posts:**
i. A comment's text content can't be empty.
ii. Contrary to the current linear comments, the new structure should allow comment threads at arbitrary levels.
iii.If a post gets deleted, all comments associated with it should be automatically deleted too.
iv. If the user who created the comment gets deleted, then the comment will remain, but it will become dissociated from that user.
v. If a comment gets deleted, then all its descendants in the thread structure should be automatically deleted too.

**E. Make sure that a given user can only vote once on a given post:**
**Hint:** Can store the (up/down) value of the vote as the values 1 and -1 respectively.
i. If the user who cast a vote gets deleted, then all their votes will remain, but will become dissociated from the user.
ii. If a post gets deleted, then all the votes for that post should be automatically deleted too.

**2. Guideline #2:** here is a list of queries that Udiddit needs in order to support its website and administrative interface. 
**Note:** There's no need to produce the DQL for those queries: they are only provided to guide the design of the new database schema.

a. List all users who haven't logged in in the last year.
b. List all users who haven't created any post.
c. Find a user by their username.
d. List all topics that don’t have any posts.
e. Find a topic by its name.
f. List the latest 20 posts for a given topic.
g. List the latest 20 posts made by a given user.
h. Find all posts that link to a specific URL, for moderation purposes.
i. List all the top-level comments (those that don’t have a parent comment) for a given post.
j. List all the direct children of a parent comment.
k. List the latest 20 comments made by a given user.
l. Compute the score of a post, defined as the difference between the number of upvotes and the number of downvotes

**3. Guideline #3:** Normalization and various constraints will be required as well as indexes in your new database schema. 
**Note:** All constraints and indexes must be named to make the schema cleaner.

**4. Guideline #4:** The new database schema will be composed of nine (9) tables that should have an auto-incrementing ID as their **primary key.**
