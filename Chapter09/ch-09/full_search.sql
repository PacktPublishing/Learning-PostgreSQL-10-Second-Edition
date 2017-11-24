SELECT 'A wise man always has something to say, whereas a fool always needs to say something'::tsvector;
SELECT to_tsvector('english', 'A wise man always has something to say, whereas a fool always needs to say something');
SELECT 'A wise man always has something to say, whereas a fool always needs to say something'::tsvector @@ 'wise'::tsquery;
SELECT to_tsquery('english', 'wise & man');
SELECT to_tsvector('A wise man always has something to say, whereas a fool always needs to say something') @@ to_tsquery('wise <-> man');

SELECT 'elephants'::tsvector @@ 'elephant';
SELECT to_tsvector('english', 'elephants') @@ to_tsquery('english', 'elephant');
SELECT to_tsvector('simple', 'elephants') @@ to_tsquery('simple', 'elephant');
SELECT setweight(to_tsvector('english', 'elephants'),'A') || setweight(to_tsvector('english', 'dolphin'),'B');

SELECT ts_rank_cd (setweight(to_tsvector('english','elephants'),'A') || setweight(to_tsvector('english', 'dolphin'),'B'),'eleph' );
SELECT ts_rank_cd (setweight(to_tsvector('english','elephants'),'A') || setweight(to_tsvector('english', 'dolphin'),'B'),'dolphin' );