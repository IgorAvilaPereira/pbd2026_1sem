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
    return query select * from servico where finalizado is null order by id;
end;

$$ LANGUAGE 'plpgsql';

alter table servico rename  data_hora_cricao TO data_hora_criacao;


with tb_criador AS (
    select servico.id, titulo, data_hora_criacao, finalizado, nome as criador, responsavel_id from servico inner join usuario on (servico.criador_id = usuario.id)
) SELECT tb_criador.id, tb_criador.titulo, criador, usuario.nome as responsavel from tb_criador inner join usuario on (tb_criador.responsavel_id = usuario.id);






