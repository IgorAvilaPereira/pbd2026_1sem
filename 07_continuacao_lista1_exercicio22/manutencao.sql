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


CREATE OR REPLACE PROCEDURE cadastra_usuario(p_nome text, p_email text) AS
$$
DECLARE
    p_senha character varying(200) := geradorSenha();
BEGIN
    RAISE NOTICE '%', p_senha;
    INSERT INTO usuario (nome, email, senha) values
(p_nome, p_email, md5(p_senha));
END;
$$ LANGUAGE 'plpgsql';

CALL cadastra_usuario ('luciano', 'luciano.vargas@riogrande.ifrs.edu.br');
-- njjjlxbwkicsfaewpflkwskyvpguqivk => luciano

CREATE OR REPLACE PROCEDURE cadastra_usuario(p_nome text, p_email text, p_senha character varying(200)) AS
$$
BEGIN
    RAISE NOTICE '%', p_senha;
    INSERT INTO usuario (nome, email, senha) values
(p_nome, p_email, md5(p_senha));
END;
$$ LANGUAGE 'plpgsql';

CALL cadastra_usuario ('bage', 'luis.henrique@riogrande.ifrs.edu.br', '123');

DROP FUNCTION list_usuarios();
CREATE OR REPLACE FUNCTION list_usuarios() RETURNS TABLE (
    p_id integer,
    p_email character varying(200),
    p_nome character varying(200),
    p_senha character varying(200)
) AS
$$
BEGIN
    RETURN QUERY select id, email, nome, senha from usuario; 
END;
$$ LANGUAGE 'plpgsql';

-- select * from list_usuarios();
-- select p_nome from list_usuarios();

CREATE OR REPLACE FUNCTION busque_usuario_por_email(parametro_email character varying(200)) RETURNS TABLE (
    p_id integer,
    p_email character varying(200),
    p_nome character varying(200),
    p_senha character varying(200)
) AS
$$
BEGIN
    RETURN QUERY select id, email, nome, senha from usuario where email = trim(parametro_email); 
END;
$$ LANGUAGE 'plpgsql'; 

-- select * from busque_usuario_por_email('igor.pereira@riogrande.ifrs.edu.br');
 


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


CREATE OR REPLACE FUNCTION retorna_usuario_nome(p_id integer) RETURNS TEXT as
$$
DECLARE
    p_nome TEXT := NULL;
BEGIN
    SELECT nome FROM usuario where id = p_id INTO p_nome;
    RETURN p_nome;
    
END;
$$ LANGUAGE 'plpgsql';

DROP FUNCTION alterar_senha;

CREATE OR REPLACE FUNCTION alterar_senha(p_email character varying(200), p_nova_senha character varying(200)) RETURNS BOOLEAN AS
$$
BEGIN
    BEGIN
        UPDATE usuario SET senha = md5(p_nova_senha) WHERE email = p_email; 
        RETURN TRUE;
    EXCEPTION
        WHEN OTHERS THEN RAISE NOTICE 'Deu xabum!';
        RETURN FALSE;
    END; 
END;
$$ LANGUAGE 'plpgsql';

-- Equipamento

-- 6
CREATE OR REPLACE PROCEDURE cadastrar_equipamento(p_descricao text) AS 
$$
BEGIN
    INSERT INTO equipamento (descricao) VALUES (p_descricao);
END;
$$ LANGUAGE 'plpgsql';

-- 7
CREATE OR REPLACE FUNCTION listar_equipamentos() RETURNS TABLE (
    p_id integer,
    p_descricao text
) AS
$$
BEGIN
    RETURN QUERY SELECT * FROM equipamento;
END;
$$ LANGUAGE 'plpgsql';


-- 8
CREATE OR REPLACE FUNCTION listar_equipamentos_default(p1 integer DEFAULT 0) RETURNS TABLE (
    p_id integer,
    p_descricao text
) AS
$$
BEGIN
    IF (p1 = 0) THEN 
        RETURN QUERY SELECT * FROM equipamento;
    ELSE
        RETURN QUERY SELECT * FROM equipamento where id = p1;
    END IF;
END;
$$ LANGUAGE 'plpgsql';

-- 9
CREATE OR REPLACE PROCEDURE atualizar_equipamento(p_id integer, p_descricao text) AS
$$
BEGIN
    UPDATE equipamento SET descricao = p_descricao where id = p_id;    
END;
$$ LANGUAGE 'plpgsql';

-- 10
ALTER TABLE equipamento ADD COLUMN ativo boolean default true;

CREATE OR REPLACE PROCEDURE remover_equipamento(p_id integer) AS
$$
BEGIN
    IF (EXISTS (SELECT * FROM equipamento where id = p_id)) THEN
        UPDATE equipamento SET ativo = FALSE where id = p_id;    
    ELSE
        RAISE NOTICE 'N EXISTE';
    END IF;
END;
$$ LANGUAGE 'plpgsql';


-- 11
ALTER TABLE usuario ADD COLUMN ativo boolean default true;

CREATE OR REPLACE FUNCTION novo_servico(p_titulo text, p_descricao text, p_criador_id INTEGER, p_responsavel_id integer default 0) RETURNS BOOLEAN AS
$$ 
BEGIN
    IF (p_responsavel_id != 0) THEN
        IF (EXISTS(select * from usuario where id = p_responsavel_id)) THEN
            IF (EXISTS(select * from usuario where id = p_criador_id)) THEN
                INSERT INTO servico (titulo, descricao, criador_id, responsavel_id) VALUES (p_titulo, p_descricao, p_criador_id, p_responsavel_id);
                RETURN TRUE;
            ELSE 
                RAISE NOTICE 'id criador invalido';
                RETURN FALSE;
            END IF;
        ELSE
            RAISE NOTICE 'id reponsavel invalido';
            RETURN FALSE;
        END IF;
    ELSE 
        p_responsavel_id := p_criador_id;
        IF (EXISTS(select * from usuario where id = p_responsavel_id)) THEN
            IF (EXISTS(select * from usuario where id = p_criador_id)) THEN
                INSERT INTO servico (titulo, descricao, criador_id, responsavel_id) VALUES (p_titulo, p_descricao, p_criador_id, p_responsavel_id);
               RETURN TRUE;
            ELSE 
                RAISE NOTICE 'id criador invalido';
                RETURN FALSE;
            END IF;
        ELSE
            RAISE NOTICE 'id reponsavel invalido';
            RETURN FALSE;
        END IF;
     END IF;
     RETURN FALSE;   
END;
$$ LANGUAGE 'plpgsql';

-- 12

-- 13
CREATE OR REPLACE FUNCTION listar_servicos_nao_finalizados() RETURNS TABLE (p_id integer, p_descricao text) AS
$$
begin
    return query select id, descricao from servico where finalizado is null order by id;
end;

$$ LANGUAGE 'plpgsql';

alter table servico rename  data_hora_cricao TO data_hora_criacao;


with tb_criador AS (
    select servico.id, titulo, data_hora_criacao, descricao, finalizado, nome as criador, responsavel_id from servico inner join usuario on (servico.criador_id = usuario.id)
) SELECT tb_criador.id, tb_criador.titulo, tb_criador.descricao,  tb_criador.data_hora_criacao, tb_criador.finalizado, criador, usuario.nome as responsavel from tb_criador inner join usuario on (tb_criador.responsavel_id = usuario.id);

-- 14 
CREATE OR REPLACE FUNCTION listar_servicos_finalizados() RETURNS TABLE (p_id integer, p_descricao text) AS
$$
begin
    return query select id, descricao from servico where finalizado is not null order by id;
end;

$$ LANGUAGE 'plpgsql';

-- 15
CREATE OR REPLACE FUNCTION obter_servico_id(integer) RETURNS TABLE(p_id integer, p_descricao text, p_data_hora_criacao timestamp) AS 
$$
begin
    return query select id, descricao, data_hora_criacao from servico where id = $1;
end;
$$ language 'plpgsql';

-- 19:33 primeira pergunta - nata corrigindo um caracter
DROP PROCEDURE alterar_responsavel;

CREATE OR REPLACE PROCEDURE alterar_responsavel(p_novo_responsavel_id integer, p_servico_id integer) AS 
$$
begin
    if (exists(select * from usuario where id = p_novo_responsavel_id)) then
    update servico set responsavel_id = p_novo_responsavel_id where id = p_servico_id;
    else
        raise notice 'deu xabum responsavel % n existe', p_novo_responsavel_id;
    end if;    
end;
$$ LANGUAGE 'plpgsql';

-- 20
CREATE OR REPLACE FUNCTION qtde_servico() RETURNS integer AS
$$
DECLARE
    qtde integer := 0;
BEGIN
    SELECT COUNT(*) FROM servico INTO qtde;
    RETURN qtde;
END;
$$ LANGUAGE 'plpgsql';

-- 21. Crie uma stored procedure para registrar um novo status para um serviço.

CREATE OR REPLACE FUNCTION registrar_novo_status_criador(p_situacao text, p_servico_id integer, p_criador_id integer) RETURNS BOOLEAN AS
$$
begin
    IF (EXISTS(SELECT * FROM servico WHERE id = p_servico_id)) THEN
        IF(EXISTS(SELECT * FROM servico where id = p_servico_id and criador_id = p_criador_id)) THEN   
            INSERT INTO status (situacao, servico_id, criador_id) VALUES (p_situacao, p_servico_id, p_criador_id);
            RETURN TRUE;
        ELSE
            RAISE NOTICE 'Este servico n tem este criador';
        END IF;
    END IF;
    RETURN FALSE;
end;
$$ LANGUAGE 'plpgsql';

-- 22
CREATE OR REPLACE FUNCTION registrar_novo_status_responsavel(p_situacao text, p_servico_id integer, p_responsavel_id integer) RETURNS BOOLEAN AS
$$
begin
    IF (EXISTS(SELECT * FROM servico WHERE id = p_servico_id)) THEN
         IF(EXISTS(SELECT * FROM servico where id = p_servico_id and responsavel_id = p_responsavel_id)) THEN 
        INSERT INTO status (situacao, servico_id, responsavel_id) VALUES (p_situacao, p_servico_id,p_responsavel_id);
        RETURN TRUE;
         ELSE
            RAISE NOTICE 'Este servico n tem este reponsavel';
        END IF;
    END IF;
    RETURN FALSE;
end;
$$ LANGUAGE 'plpgsql';

ALTER TABLE status ADD COLUMN responsavel_id INTEGER references usuario(id);

ALTER TABLE status ADD COLUMN criador_id INTEGER references usuario(id);

-- 23
CREATE OR REPLACE FUNCTION listar_status(integer) RETURNS TABLE(p_status text) AS
$$
BEGIN
    RETURN QUERY SELECT situacao FROM status where servico_id = $1;
END;
$$ LANGUAGE 'plpgsql';

-- 24
CREATE OR REPLACE FUNCTION listar_ultimo_status(integer) RETURNS text AS 
$$
DECLARE
    status_retorno text;
BEGIN
    SELECT situacao FROM status WHERE servico_id = $1 ORDER BY data_hora DESC LIMIT 1 INTO status_retorno;
    RETURN status_retorno;
END;
$$ LANGUAGE 'plpgsql';


-- 25
DROP FUNCTION listar_servicos_por_usuario;
CREATE OR REPLACE FUNCTION listar_servicos_por_usuario(integer) RETURNS TABLE (p_id integer, p_descricao text, p_titulo text, p_data_hora_criacao timestamp, p_finalizado timestamp, p_responsavel_nome character varying(200)) AS
$$
BEGIN
    RETURN QUERY select servico.id, servico.descricao, servico.titulo, servico.data_hora_criacao, servico.finalizado, usuario.nome as responsavel_nome FROM servico INNER JOIN usuario ON (servico.responsavel_id = usuario.id) where criador_id = $1;
END;
$$ LANGUAGE 'plpgsql';

-- 26
CREATE OR REPLACE FUNCTION qtde_servicos_por_criador() RETURNS TABLE (p_id integer, p_nome character varying(200), p_qtde integer) AS 
$$
BEGIN
    RETURN QUERY SELECT usuario.id, usuario.nome,  count(servico.criador_id)::integer as qtde from usuario inner join servico on (usuario.id = servico.criador_id) group by usuario.id, criador_id,usuario.nome;
END;
$$ LANGUAGE 'plpgsql';

-- 27
CREATE OR REPLACE FUNCTION listar_servicos_por_data(date) RETURNS TABLE (p_id integer, p_descricao text, p_titulo text, p_data_hora_criacao timestamp, p_finalizado timestamp, p_responsavel_id integer, p_criador_id integer) AS
$$
BEGIN
   RETURN QUERY SELECT id, descricao, titulo, data_hora_criacao, finalizado, responsavel_id, criador_id from servico where data_hora_criacao::date = $1 ORDER BY id;
END;
$$ LANGUAGE 'plpgsql';

select * from listar_servicos_por_data('2026-03-26');

-- 28
CREATE OR REPLACE FUNCTION qtde_servicos_aberto() RETURNS integer 
AS
$$
DECLARE
    qtde integer := 0;
BEGIN
    select count(*)::integer from servico where finalizado is null into qtde;
    RETURN qtde;
END;
$$ LANGUAGE 'plpgsql';

-- 29
CREATE OR REPLACE FUNCTION qtde_servicos_finalizados() RETURNS integer 
AS
$$
DECLARE
    qtde integer := 0;
BEGIN
    select count(*)::integer from servico where finalizado is not null into qtde;
    RETURN qtde;
END;
$$ LANGUAGE 'plpgsql';

-- 30
CREATE OR REPLACE FUNCTION listar_servicos_nome_criador_nome_responsavel() RETURNS TABLE 
(p_id integer, p_titulo text, p_descricao text, p_data_hora_criacao timestamp, p_finalizado timestamp, p_criador character varying(200), p_responsavel character varying(200)) AS
$$
BEGIN
    RETURN QUERY with tb_criador AS (
        select servico.id, titulo, data_hora_criacao, descricao, finalizado, nome as criador, responsavel_id from servico inner join usuario on (servico.criador_id = usuario.id)
    ) SELECT tb_criador.id, tb_criador.titulo, tb_criador.descricao,  tb_criador.data_hora_criacao, tb_criador.finalizado, criador, usuario.nome as responsavel from tb_criador inner join usuario on (tb_criador.responsavel_id = usuario.id);
END;
$$ LANGUAGE 'plpgsql';

select * from listar_servicos_nome_criador_nome_responsavel();



