# 📘 Lista – Stored Procedures / Functions (PLpgSQL)

---

## 🔹 1) Cadastrar usuário com validação

<!-- ```sql
CREATE OR REPLACE PROCEDURE cadastrar_usuario(
    p_nome varchar,
    p_email varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_senha text;
BEGIN
    IF NOT validaEmail(p_email) THEN
        RAISE EXCEPTION 'Email inválido!';
    END IF;

    v_senha := geradorSenha();

    INSERT INTO usuario(nome, email, senha)
    VALUES (p_nome, p_email, md5(v_senha));

    RAISE NOTICE 'Usuário cadastrado. Senha gerada: %', v_senha;
END;
$$;--> ```

---

## 🔹 2) Total de usuários

<!-- ```sql
CREATE OR REPLACE FUNCTION total_usuarios()
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_total integer;
BEGIN
    SELECT COUNT(*) INTO v_total FROM usuario;
    RETURN v_total;
END;
$$;--> ```

---

## 🔹 3) Alterar senha

<!-- ```sql
CREATE OR REPLACE PROCEDURE alterar_senha(
    p_usuario_id integer,
    p_nova_senha text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id = p_usuario_id) THEN
        RAISE EXCEPTION 'Usuário não encontrado!';
    END IF;

    UPDATE usuario
    SET senha = md5(p_nova_senha)
    WHERE id = p_usuario_id;
END;
$$;--> ```

---

## 🔹 4) Buscar usuário por email

<!-- ```sql
CREATE OR REPLACE FUNCTION buscar_usuario_email(p_email varchar)
RETURNS usuario
LANGUAGE plpgsql
AS $$
DECLARE
    v_usuario usuario;
BEGIN
    SELECT * INTO v_usuario
    FROM usuario
    WHERE email = p_email;

    RETURN v_usuario;
END;
$$;--> ```

---

## 🔹 5) Cadastrar equipamento

<!-- ```sql
CREATE OR REPLACE PROCEDURE cadastrar_equipamento(p_descricao text)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_descricao IS NULL OR trim(p_descricao) = '' THEN
        RAISE EXCEPTION 'Descrição inválida!';
    END IF;

    INSERT INTO equipamento(descricao)
    VALUES (p_descricao);
END;
$$;--> ```

---

## 🔹 6) Abrir serviço

<!-- ```sql
CREATE OR REPLACE PROCEDURE abrir_servico(
    p_titulo text,
    p_descricao text,
    p_criador_id integer,
    p_responsavel_id integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_servico_id integer;
BEGIN
    INSERT INTO servico(titulo, descricao, criador_id, responsavel_id)
    VALUES (p_titulo, p_descricao, p_criador_id, p_responsavel_id)
    RETURNING id INTO v_servico_id;

    INSERT INTO status(servico_id, situacao)
    VALUES (v_servico_id, 'ABERTO');
END;
$$;--> ```

---

## 🔹 7) Adicionar status

<!-- ```sql
CREATE OR REPLACE PROCEDURE adicionar_status(
    p_servico_id integer,
    p_situacao text
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM servico WHERE id = p_servico_id) THEN
        RAISE EXCEPTION 'Serviço não encontrado!';
    END IF;

    INSERT INTO status(servico_id, situacao)
    VALUES (p_servico_id, p_situacao);
END;
$$;--> ```

---

## 🔹 8) Finalizar serviço

<!-- ```sql
CREATE OR REPLACE PROCEDURE finalizar_servico(p_servico_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE servico
    SET finalizado = current_timestamp
    WHERE id = p_servico_id;

    INSERT INTO status(servico_id, situacao)
    VALUES (p_servico_id, 'FINALIZADO');
END;
$$;--> ```

---

## 🔹 9) Total serviços por usuário

<!-- ```sql
CREATE OR REPLACE FUNCTION total_servicos_usuario(p_usuario_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_total integer;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM servico
    WHERE criador_id = p_usuario_id;

    RETURN v_total;
END;
$$;--> ```

---

## 🔹 10) Serviços não finalizados

<!-- ```sql
CREATE OR REPLACE FUNCTION servicos_abertos()
RETURNS TABLE (
    id integer,
    titulo text,
    descricao text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT id, titulo, descricao
    FROM servico
    WHERE finalizado IS NULL;
END;
$$;--> ```

---

## 🔹 11) Reabrir serviço

<!-- ```sql
CREATE OR REPLACE PROCEDURE reabrir_servico(p_servico_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE servico
    SET finalizado = NULL
    WHERE id = p_servico_id;

    INSERT INTO status(servico_id, situacao)
    VALUES (p_servico_id, 'REABERTO');
END;
$$;--> ```

---

## 🔹 12) Verificar se serviço está finalizado

<!-- ```sql
CREATE OR REPLACE FUNCTION servico_finalizado(p_servico_id integer)
RETURNS boolean
LANGUAGE plpgsql
AS $$
DECLARE
    v_finalizado timestamp;
BEGIN
    SELECT finalizado INTO v_finalizado
    FROM servico
    WHERE id = p_servico_id;

    RETURN v_finalizado IS NOT NULL;
END;
$$;--> ```

---

## 🔹 13) Alterar responsável

<!-- ```sql
CREATE OR REPLACE PROCEDURE alterar_responsavel(
    p_servico_id integer,
    p_novo_responsavel integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE servico
    SET responsavel_id = p_novo_responsavel
    WHERE id = p_servico_id;
END;
$$;--> ```

---

## 🔹 14) Listar status de um serviço

<!-- ```sql
CREATE OR REPLACE FUNCTION listar_status_servico(p_servico_id integer)
RETURNS TABLE (
    situacao text,
    data_hora timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT situacao, data_hora
    FROM status
    WHERE servico_id = p_servico_id
    ORDER BY data_hora;
END;
$$;--> ```

---

## 🔹 15) Excluir serviço (com controle)

<!-- ```sql
CREATE OR REPLACE PROCEDURE excluir_servico(p_servico_id integer)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM status
    WHERE servico_id = p_servico_id;

    DELETE FROM servico
    WHERE id = p_servico_id;
END;
$$;--> ```

---

## 🔹 16) Tempo em dias do serviço

<!-- ```sql
CREATE OR REPLACE FUNCTION dias_servico(p_servico_id integer)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
    v_inicio timestamp;
    v_fim timestamp;
BEGIN
    SELECT data_hora_cricao, COALESCE(finalizado, current_timestamp)
    INTO v_inicio, v_fim
    FROM servico
    WHERE id = p_servico_id;

    RETURN v_fim::date - v_inicio::date;
END;
$$;--> ```

---

## 🔹 17) Resetar senha

<!-- ```sql
CREATE OR REPLACE FUNCTION resetar_senha(p_usuario_id integer)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
    v_nova_senha text;
BEGIN
    v_nova_senha := geradorSenha();

    UPDATE usuario
    SET senha = md5(v_nova_senha)
    WHERE id = p_usuario_id;

    RETURN v_nova_senha;
END;
$$;--> ```

---

## 🔹 18) Inserção com tratamento de erro

<!-- ```sql
CREATE OR REPLACE PROCEDURE inserir_usuario_tratado(
    p_nome varchar,
    p_email varchar,
    p_senha text
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO usuario(nome, email, senha)
    VALUES (p_nome, p_email, md5(p_senha));

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Email já cadastrado!';
END;
$$;--> ```

---

## 🔹 19) Ranking usuários por serviços criados

<!-- ```sql
CREATE OR REPLACE FUNCTION ranking_usuarios()
RETURNS TABLE (
    nome varchar,
    total integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT u.nome, COUNT(s.id)
    FROM usuario u
    LEFT JOIN servico s ON s.criador_id = u.id
    GROUP BY u.nome
    ORDER BY COUNT(s.id) DESC;
END;
$$;--> ```

---

## 🔹 20) Encerrar serviços antigos

<!-- ```sql
CREATE OR REPLACE PROCEDURE encerrar_servicos_antigos(p_dias integer)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE servico
    SET finalizado = current_timestamp
    WHERE finalizado IS NULL
    AND data_hora_cricao <= current_timestamp - (p_dias || ' days')::interval;

    INSERT INTO status(servico_id, situacao)
    SELECT id, 'ENCERRADO POR SISTEMA'
    FROM servico
    WHERE finalizado = current_timestamp;
END;
$$;--> ```

