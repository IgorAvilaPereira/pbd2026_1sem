DROP DATABASE IF EXISTS atividade1_070526;

CREATE DATABASE atividade1_070526;

\c atividade1_070526;

CREATE TABLE aluno (
 id SERIAL PRIMARY KEY ,
 nome TEXT NOT NULL ,
 ativo BOOLEAN DEFAULT TRUE
);
INSERT INTO aluno (nome, ativo) values
('igor', true),
('betito', true),
('marcio', true);

 CREATE TABLE disciplina (
 id SERIAL PRIMARY KEY ,
 nome TEXT NOT NULL
) ;
INSERT INTO disciplina (nome) VALUES
('PBD'), ('PMBD'), ('PPP');

 CREATE TABLE matricula (
 id SERIAL PRIMARY KEY ,
 aluno_id INTEGER REFERENCES aluno ( id ) ,
 disciplina_id INTEGER REFERENCES disciplina ( id ) ,
nota NUMERIC (4 ,2) ,
 frequencia INTEGER ,
aprovado BOOLEAN
 ) ;
 
 INSERT INTO matricula (aluno_id, disciplina_id, nota, frequencia) VALUES
 (1, 1, 7, 70),
 (1, 2, 7, 75),
 (2, 1, 10, 100),
 (2, 2, 8.5, 75),
 (3, 1, 6, 100),
 (3, 2, 9.5, 80);
 
  INSERT INTO matricula (aluno_id, disciplina_id, nota, frequencia) VALUES (2, 3, 10, 100);
  
   INSERT INTO matricula (aluno_id, disciplina_id, nota, frequencia) VALUES
 (1, 3, 5, 70),
 (2, 3, 5, 75);
 
CREATE OR REPLACE FUNCTION avaliar_aluno(p_aluno_id integer) RETURNS BOOLEAN AS 
$$
DECLARE 
    nro_matriculas  integer := 0;
BEGIN
    SELECT COUNT(*) FROM matricula where aluno_id = p_aluno_id INTO nro_matriculas;
    IF (nro_matriculas = 0) THEN
        RETURN FALSE;
    END IF;
    
    UPDATE matricula SET aprovado = CASE WHEN nota >= 7 AND frequencia >= 75 THEN TRUE ELSE FALSE END WHERE aluno_id = p_aluno_id;
    
    RETURN TRUE; 
 
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE function aluno_exemplar(p_aluno_id integer) RETURNS BOOLEAN AS
$$
DECLARE 
    qtde_matriculas_notas_lancadas integer := 0;
    media_final integer := 0;
BEGIN
-- qtde reprovacoes
    select count(*) from matricula where nota is not null and aluno_id = p_aluno_id AND (nota < 7 or frequencia < 75) INTO qtde_matriculas_notas_lancadas;
    IF (qtde_matriculas_notas_lancadas > 0) THEN
        RETURN FALSE;
    END IF;
--  qtde aprovacoes
    select count(*) from matricula where nota is not null and aluno_id = p_aluno_id AND (nota >= 7 and frequencia >= 75) INTO qtde_matriculas_notas_lancadas;
    IF (qtde_matriculas_notas_lancadas < 3) THEN
        RETURN FALSE;
    END IF;
--  da media
    select avg(nota) from matricula where aluno_id = p_aluno_id INTO media_final;
    
    IF (media_final >= 8.5) THEN
        RETURN TRUE;
    END IF;
    
    RETURN FALSE;        
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION ranking_alunos() RETURNS TABLE (nome text, media numeric, quantidade integer) AS
$$
BEGIN
    RETURN QUERY select aluno.nome, avg(nota), count(*)::integer from matricula join aluno on (matricula.aluno_id = aluno.id)  where nota is not null group by aluno_id, aluno.nome having count(*) >= 3 order by avg(nota) desc, count(*) desc;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION disciplinas_criticas() RETURNS TABLE (disciplina text, taxa_reprovacao numeric) AS
$$
DECLARE
    p_taxa_reprovacao numeric := 0;
    p_reprovados numeric := 0;
    p_total numeric := 0;
    p_disciplina RECORD;
BEGIN
    -- tabela temporaria que armazena as disciplinas criticas seguindo o que foi definido na assinatura do stored procedure
    CREATE TEMPORARY TABLE IF NOT EXISTS disciplinas_criticas(
        disciplina text,
        taxa_reprovacao numeric
    ) ON COMMIT DROP;

-- para cada disciplina - calculamos a taxa de reprovacao
    FOR p_disciplina IN SELECT * FROM disciplina LOOP
       
         select count(*) from matricula where nota is not null AND (nota < 7 or frequencia < 75) and disciplina_id = p_disciplina.id INTO p_reprovados;
         
         select count(*) from matricula where disciplina_id = p_disciplina.id into p_total;
         
        p_taxa_reprovacao = (p_reprovados/p_total) * 100;
        
        -- se a taxa obdecer o criterio que define como disciplina critica - criamos um insert
        IF (p_taxa_reprovacao > 50) then
            INSERT INTO disciplinas_criticas(disciplina, taxa_reprovacao) VALUES (p_disciplina.nome, p_taxa_reprovacao::numeric(10,2));
       
        END IF; 
        
  END LOOP;  
  -- ao final retornamos todas as tuplas cadastradas.  Logo, as disciplinas criticas
    RETURN QUERY select * FROM disciplinas_criticas;
END;
$$ LANGUAGE 'plpgsql';
 
 
 
