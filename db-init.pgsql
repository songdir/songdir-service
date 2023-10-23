create table users(
  id serial primary key,
  first_name varchar(70),
  last_name varchar(70),
  username varchar(30) not null unique,
  email varchar(80) not null,
  password varchar(256) not null,
  document_number varchar(15),
  document_type varchar(3),
  created_at timestamp(0) without time zone,
  is_confirmed boolean default 'f',
  is_active boolean default 't'
);

create table roles(
  id serial primary key,
  name varchar(64) not null unique,
  is_active boolean default 't'
);

create table user_role(
  id serial primary key,
  role_id integer references roles(id),
  user_id integer references users(id)
);

create table permissions(
  id serial primary key,
  name varchar(64) not null unique,
  is_active boolean default 't'
);

create table role_permission(
  id serial primary key,
  role_id integer references roles(id),
  permission_id integer references permissions(id)
);

create table signup_confirmations (
  id uuid primary key,
  user_id integer references users(id),
  sent_to varchar(64) not null,
  is_confirmed boolean default 'f'
);

create table songs (
  id varchar(128) primary key,
  title varchar(96) not null,
  subtitle varchar(96) not null,
  artist varchar(64) not null,
  composer varchar(64),
  genre varchar(32) not null,
  album varchar(52) not null,
  key varchar(12) not null,
  tempo integer not null,
  creation_year integer not null,
  content text,
  content_mimetype varchar(96) not null,
  created_at timestamp(0) without time zone,
  updated_at timestamp(0) without time zone,
  user_id integer references users(id)
);

create table song_lists (
  id varchar(128) primary key,
  name varchar(128) not null,
  created_at timestamp(0) without time zone,
  user_id integer references users(id)
);

create table song_in_list (
  id serial primary key,
  position integer,
  song_id varchar(128) references songs(id),
  song_list_id varchar(128) references song_lists(id),
  created_at timestamp(0) without time zone
);
