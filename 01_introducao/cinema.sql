DROP DATABASE IF EXISTS cinema;

CREATE DATABASE cinema;

\c cinema;

CREATE TABLE filme (
    id serial primary key,
    titulo text not null,
    duracao integer check (duracao > 0),
    classificacao_etaria character varying(2) check (classificacao_etaria in ('L','10', '12', '14', '16', '18')),
    sinopse text
);
INSERT INTO filme (titulo, duracao, classificacao_etaria, sinopse) VALUES
('SUPERMAN', 130, 'L', 'superman do james gun');

CREATE TABLE direcao (
    id serial primary key,
    nome text not null
);
INSERT INTO direcao (nome) VALUES
('JAMES GUN');

CREATE TABLE genero (
    id serial primary key,
    nome character varying(100) not null
);
INSERT INTO genero (nome) VALUES
('AVENTURA'),
('DRAMA'),
('TERROR'),
('AÇÃO');

CREATE TABLE filme_direcao (
    filme_id integer references filme (id),
    direcao_id integer references direcao (id),
    primary key (filme_id, direcao_id)
);
INSERT INTO filme_direcao (filme_id, direcao_id) VALUES
(1,1);

CREATE TABLE filme_genero (
    filme_id integer references filme (id),
    genero_id integer references genero (id),
    primary key (filme_id, genero_id)
);
INSERT INTO filme_genero (filme_id, genero_id) VALUES
(1, 1),
(1, 4);

CREATE TABLE sala (
    id serial primary key,
    ocupacao integer check (ocupacao > 0)
);
INSERT INTO sala (ocupacao) VALUES 
(100),
(50);

CREATE TABLE sessao (
    id serial primary key,
    filme_id integer references filme (id),
    sala_id integer references sala (id),
    data date default current_date,
    hora_inicio time default current_time,
    hora_fim time default current_time
); 
INSERT INTO sessao (filme_id, sala_id) VALUES
(1,1);

CREATE TABLE poltrona (
    id serial primary key,
    fileira character(1) not null,
    posicao integer check (posicao > 0),
    tipo character varying(100) check (tipo = 'luxo' or tipo = 'simples'),
    sala_id integer references sala (id)
);
INSERT INTO poltrona (fileira, posicao, tipo, sala_id) VALUES
('A', 1, 'simples', 1),
('A', 2, 'simples', 1),
('A', 3, 'simples', 1),
('A', 4, 'luxo', 1),
('A', 5, 'simples', 1);

CREATE TABLE ingresso (
    id serial primary key,
    cpf character(11) not null,
    sessao_id integer references sessao (id),
    valor numeric(8,2) check (valor >= 0),
    poltrona_id integer references poltrona (id)
);
INSERT INTO ingresso (cpf, sessao_id, valor, poltrona_id) VALUES
('17658586072', 1, 1.99, 1);

