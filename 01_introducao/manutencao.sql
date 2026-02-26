DROP DATABASE IF EXISTS manutencao;

CREATE DATABASE manutencao;

\c manutencao;

CREATE OR REPLACE FUNCTION validaEmail(email character varying(200)) RETURNS boolean AS
$$
--DECLARE
BEGIN
    -- PRINT de debug
    RAISE NOTICE '%', email;
    
    IF (POSITION('@' IN email) != 0) THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION geradorSenha() RETURNS text AS
$$
DECLARE
    i integer := 0;
    alfabeto text[] := ARRAY['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
    senha text := '';
BEGIN
    WHILE(i < 32) loop
        senha :=  senha || alfabeto[cast(random()*25 + 1 as integer)];
--        RAISE NOTICE '%', senha;
        i := i + 1;
    end loop;      
    return trim(senha);
END;
$$ LANGUAGE 'plpgsql';

CREATE TABLE usuario (
    id serial primary key,
    email character varying(200) unique check(validaEmail(email) is TRUE),
    nome character varying(200) not null,
    senha character varying(200) not null
);

INSERT INTO usuario (nome, email, senha) values
('IGOR PEREIRA', 'igor.pereira@riogrande.ifrs.edu.br', md5('123'));
--
--INSERT INTO usuario (nome, email, senha) values
--('JAAZIEL FERNANDES RODRIGUES MALTA', 'jaaziel', md5('123'));

CREATE TABLE equipamento (
    id serial primary key,
    descricao text not null
);
INSERT INTO equipamento (descricao) VALUES 
('PROJETOR MULTIMIDIA');

CREATE TABLE servico (
    id serial primary key,
    descricao text not null,
    titulo text not null,
    data_hora_cricao timestamp default current_timestamp,
    finalizado timestamp,
    criador_id integer references usuario (id),
    responsavel_id integer references usuario (id)
);
INSERT INTO servico (titulo, descricao, criador_id, responsavel_id) VALUES
('PROJETOR NÃO LIGA', 'PROJETOR NÃO LIGA DEVIDO A ALGUMA COISA', 1, 1);

CREATE TABLE status (
    id serial primary key,
    servico_id integer references servico (id),
    situacao text not null,
    data_hora timestamp default current_timestamp
);

INSERT INTO status (situacao, servico_id) VALUES
('TENTEI RESOLVER E NÃO DEU! Sorry!', 1);








