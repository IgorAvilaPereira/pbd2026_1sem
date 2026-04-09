# 🧠 1. CASE (lógica condicional mais elegante que IF)

```sql
CREATE OR REPLACE FUNCTION classificarServico(p_id int)
RETURNS text AS $$
DECLARE
v_status text;
BEGIN
SELECT 
CASE 
    WHEN finalizado IS NOT NULL THEN 'FINALIZADO'
    WHEN finalizado IS NULL THEN 'ABERTO'
END
INTO v_status
FROM servico
WHERE id = p_id;

RETURN v_status;
END;
$$ LANGUAGE plpgsql;
```

👉 Mostra alternativa mais limpa ao `IF`

---

# 🔁 2. WHILE (loop controlado)

```sql
CREATE OR REPLACE FUNCTION contarAteDez()
RETURNS void AS $$
DECLARE
i int := 1;
BEGIN
WHILE i <= 10 LOOP
    RAISE NOTICE 'Valor: %', i;
    i := i + 1;
END LOOP;
END;
$$ LANGUAGE plpgsql;
```

👉 Diferente do `FOR`, aqui o aluno controla tudo

---

# 📦 3. ARRAY (estrutura pouco explorada)

```sql
CREATE OR REPLACE FUNCTION exemploArray()
RETURNS void AS $$
DECLARE
nomes text[] := ARRAY['Ana','Bruno','Carlos'];
i int;
BEGIN
FOR i IN 1..array_length(nomes,1) LOOP
    RAISE NOTICE 'Nome: %', nomes[i];
END LOOP;
END;
$$ LANGUAGE plpgsql;
```

👉 Excelente para mostrar estruturas além de tabelas

---

# 🧩 4. RECORD vs ROWTYPE

### RECORD (genérico)

```sql
DECLARE
r record;
```

### ROWTYPE (tipado)

```sql
CREATE OR REPLACE FUNCTION exemploRowType()
RETURNS text AS $$
DECLARE
u usuario%ROWTYPE;
BEGIN
SELECT * INTO u FROM usuario WHERE id = 1;

RETURN u.nome;
END;
$$ LANGUAGE plpgsql;
```

👉 Diferença MUITO cobrada em prova

---

# 📊 5. RETURN NEXT (retorno linha a linha)

```sql
CREATE OR REPLACE FUNCTION listarUsuariosLoop()
RETURNS TABLE(id int, nome text) AS $$
DECLARE
r record;
BEGIN
FOR r IN SELECT id, nome FROM usuario LOOP
    id := r.id;
    nome := r.nome;
    RETURN NEXT;
END LOOP;
END;
$$ LANGUAGE plpgsql;
```

👉 Alternativa ao `RETURN QUERY`

---

# ⚡ 6. EXECUTE (SQL dinâmico)

```sql
CREATE OR REPLACE FUNCTION buscarTabela(p_tabela text)
RETURNS SETOF record AS $$
BEGIN
RETURN QUERY EXECUTE 'SELECT * FROM ' || p_tabela;
END;
$$ LANGUAGE plpgsql;
```

👉 Muito importante (e perigoso → falar de SQL Injection)

---

# 🧱 7. VIEW (não apareceu na lista)

```sql
CREATE OR REPLACE VIEW vw_servicos_abertos AS
SELECT id, titulo
FROM servico
WHERE finalizado IS NULL;
```

👉 Ensina:

* abstração
* reutilização
* segurança

---

# ⏱️ 8. Uso de datas (interval, age, now)

```sql
CREATE OR REPLACE FUNCTION tempoServico(p_id int)
RETURNS interval AS $$
DECLARE
v_tempo interval;
BEGIN
SELECT now() - data_hora_criacao
INTO v_tempo
FROM servico
WHERE id = p_id;

RETURN v_tempo;
END;
$$ LANGUAGE plpgsql;
```

👉 Muito útil em sistemas reais

---

# 🧮 9. COALESCE (evitar NULL)

```sql
SELECT COALESCE(finalizado, now())
FROM servico;
```

👉 Conceito simples, mas essencial

---

# 🔎 10. EXISTS (melhor que COUNT em muitos casos)

```sql
CREATE OR REPLACE FUNCTION existeUsuario(p_email text)
RETURNS boolean AS $$
BEGIN
RETURN EXISTS (
    SELECT 1 FROM usuario WHERE email = p_email
);
END;
$$ LANGUAGE plpgsql;
```

👉 Performance + semântica correta

---

# 🧠 11. SUBQUERY + lógica mais complexa

```sql
CREATE OR REPLACE FUNCTION usuarioMaisAtivo()
RETURNS int AS $$
DECLARE
v_id int;
BEGIN
SELECT criador_id INTO v_id
FROM servico
GROUP BY criador_id
ORDER BY COUNT(*) DESC
LIMIT 1;

RETURN v_id;
END;
$$ LANGUAGE plpgsql;
```

👉 Introduz análise de dados

---

# 📚 12. CTE (WITH) — MUITO importante

```sql
CREATE OR REPLACE FUNCTION rankingUsuarios()
RETURNS TABLE(usuario int, total int) AS $$
BEGIN
RETURN QUERY
WITH contagem AS (
    SELECT criador_id, COUNT(*) as total
    FROM servico
    GROUP BY criador_id
)
SELECT criador_id, total
FROM contagem
ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql;
```

👉 Organização de consultas complexas

---

# 🧪 13. ASSERT (validação)

```sql
CREATE OR REPLACE FUNCTION validarId(p_id int)
RETURNS void AS $$
BEGIN
ASSERT p_id > 0, 'ID inválido';
END;
$$ LANGUAGE plpgsql;
```

👉 Pouco usado, mas ótimo didaticamente

---

# 🧷 14. CONSTANT

```sql
DECLARE
pi CONSTANT numeric := 3.14;
```

👉 Mostra imutabilidade

---

# 🔄 15. DEFAULT em parâmetros

```sql
CREATE OR REPLACE FUNCTION exemploDefault(p_nome text DEFAULT 'Anonimo')
RETURNS text AS $$
BEGIN
RETURN p_nome;
END;
$$ LANGUAGE plpgsql;
```

👉 Muito útil em APIs

---

# 📌 16. OUT parameters (forma alternativa de retorno)

```sql
CREATE OR REPLACE FUNCTION dadosUsuario(p_id int, OUT nome text, OUT email text)
AS $$
BEGIN
SELECT u.nome, u.email
INTO nome, email
FROM usuario u
WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;
```

👉 Alternativa ao RETURNS TABLE

---

# 🎯 17. DISTINCT ON (PostgreSQL específico)

```sql
SELECT DISTINCT ON (servico_id) servico_id, situacao
FROM status
ORDER BY servico_id, data_hora DESC;
```

👉 Muito poderoso e pouco ensinado

---

# 🧩 18. JSON (muito atual e não apareceu)

```sql
CREATE OR REPLACE FUNCTION usuarioJson(p_id int)
RETURNS json AS $$
DECLARE
v_json json;
BEGIN
SELECT row_to_json(u)
INTO v_json
FROM usuario u
WHERE id = p_id;

RETURN v_json;
END;
$$ LANGUAGE plpgsql;
```

👉 Integração com APIs modernas

---

# 🚀 19. RETURN QUERY + JOIN + JSON

```sql
CREATE OR REPLACE FUNCTION servicosJson()
RETURNS SETOF json AS $$
BEGIN
RETURN QUERY
SELECT row_to_json(t)
FROM (
    SELECT s.id, s.titulo, u.nome
    FROM servico s
    JOIN usuario u ON s.criador_id = u.id
) t;
END;
$$ LANGUAGE plpgsql;
```

Boa pergunta — e sim: **poderia (e normalmente deveria) usar `jsonb` em vez de `json`** 👍

Mas tem alguns detalhes importantes que valem ouro em aula 👇

---

# 🆚 20. `json` vs `jsonb`

### ✔ `json`

* Armazena como texto
* Preserva formatação original
* Mais leve para inserção simples

### ✔ `jsonb`

* Armazena em formato binário
* Permite indexação (GIN)
* Muito mais eficiente para consulta/manipulação

👉 Em sistemas reais: **quase sempre use `jsonb`**

---

# 🔄 Ajustando tua função

### Antes:

```sql
RETURNS SETOF json
```

### Melhor:

```sql
RETURNS SETOF jsonb
```

---

# ✅ Versão corrigida

```sql id="y7k6nn"
CREATE OR REPLACE FUNCTION servicosJson()
RETURNS SETOF jsonb AS $$
BEGIN
RETURN QUERY
SELECT to_jsonb(t)
FROM (
    SELECT s.id, s.titulo, u.nome
    FROM servico s
    JOIN usuario u ON s.criador_id = u.id
) t;
END;
$$ LANGUAGE plpgsql;
```

---

# ⚡ Melhor ainda (mais moderno)

Nem precisa subquery:

```sql id="3vte93"
CREATE OR REPLACE FUNCTION servicosJson()
RETURNS SETOF jsonb AS $$
BEGIN
RETURN QUERY
SELECT jsonb_build_object(
    'id', s.id,
    'titulo', s.titulo,
    'criador', u.nome
)
FROM servico s
JOIN usuario u ON s.criador_id = u.id;
END;
$$ LANGUAGE plpgsql;
```

---

# 🔍 Quando **não** usar `jsonb`?

Casos raros:

* precisa manter exatamente o JSON original (formatação/ordem)
* armazenamento bruto sem processamento

---

# 🎯 Regra prática (boa pra prova)

👉 Se a pergunta for:

> “Qual usar no PostgreSQL?”

Resposta esperada:

> **jsonb**, pois permite indexação e melhor performance

---

# 💡 Dica de ouro pra aula

Se quiser elevar o nível, mostra isso:

```sql
CREATE INDEX idx_json ON tabela USING GIN (campo_jsonb);
```




