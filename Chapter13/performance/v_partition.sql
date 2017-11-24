CREATE TABLE client_picture (
id int primary key,
client_id int references client(id),
picture bytea NOT NULL
);