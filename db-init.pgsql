create table users(
    user_id serial primary key,
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
    role_id serial primary key,
    name varchar(64) not null unique,
    is_active boolean default 't'
);

create table user_role(
    user_role_id serial primary key,
    role_id integer references roles(role_id),
    user_id integer references users(user_id)
);

create table permissions(
    permission_id serial primary key,
    name varchar(64) not null unique,
    is_active boolean default 't'
);

create table role_permission(
    role_permission_id serial primary key,
    role_id integer references roles(role_id),
    permission_id integer references permissions(permission_id)
);

create table signup_confirmations (
    signup_confirmation_id uuid primary key,
    user_id integer references users(user_id),
    sent_to varchar(64) not null,
    is_confirmed boolean default 'f'
);

create table songs (
    song_id varchar(128) primary key,
    title varchar(96) not null,
    subtitle varchar(96) not null,
    artist varchar(64) not null,
    composer varchar(64),
    genre varchar(32) not null,
    key varchar(12) not null,
    tempo integer not null,
    creation_year integer not null,
    created_by varchar(32) references users(username),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);

create table resources (
    resource_id varchar(128) primary key,
    name varchar(96) not null,
    url varchar(4096),
    content varchar(13000),
    mimetype varchar(128),
    created_at timestamp(0) without time zone,
    created_by varchar(32) references users(username),
    song_id varchar(128) references songs(song_id)
);

create table song_lists (
    song_list_id varchar(128) primary key,
    name varchar(128) not null,
    created_at timestamp(0) without time zone,
    created_by varchar(32) references users(username)
);

create table song_in_list (
    song_in_list_id serial primary key,
    position integer,
    song_id varchar(128) references songs(song_id),
    song_list_id varchar(128) references song_lists(song_list_id),
    created_at timestamp(0) without time zone
);
