# Lista de Exercícios — Triggers (PostgreSQL)

Considere o banco de dados **manutenção** apresentado em aula (`usuario`, `equipamento`, `servico`, `status`).

Crie as **funções trigger** e as **triggers** necessárias para automatizar as regras abaixo.

---

# Parte 1 — Triggers básicas (`BEFORE INSERT`)

## 1. Validar email automaticamente

Crie uma trigger para impedir inserção de usuários cujo email não contenha `@`.

**Tabela:** `usuario`

**Dica:** usar `RAISE EXCEPTION`.

---

## 2. Criptografar senha automaticamente

Crie uma trigger para que toda senha inserida em `usuario` seja automaticamente convertida para `md5()`.

**Tabela:** `usuario`

---

## 3. Converter nome do usuário para maiúsculas

Ao inserir um usuário, transformar automaticamente `nome` em caixa alta.

**Tabela:** `usuario`

---

## 4. Remover espaços extras do email

Antes de inserir usuário, aplicar `TRIM()` no campo `email`.

**Tabela:** `usuario`

---

## 5. Impedir senha vazia

Criar trigger que bloqueie cadastro se `senha = ''`.

**Tabela:** `usuario`

---

# Parte 2 — Triggers de atualização (`BEFORE UPDATE`)

## 6. Criptografar nova senha automaticamente

Sempre que a senha for alterada, aplicar `md5()`.

**Tabela:** `usuario`

---

## 7. Manter nome em maiúsculas

Sempre que o nome do usuário for alterado, manter em maiúsculas.

---

## 8. Impedir alteração do email para valor inválido

Bloquear `UPDATE` se o novo email não possuir `@`.

---

## 9. Impedir alteração do id

Bloquear qualquer tentativa de alterar a chave primária `id`.

---

# Parte 3 — Triggers em serviços

## 10. Definir responsável automaticamente

Ao inserir um novo serviço, se `responsavel_id` for `NULL`, definir igual ao `criador_id`.

**Tabela:** `servico`

---

## 11. Preencher data de criação automaticamente

Caso `data_hora_criacao` venha nula, preencher com `CURRENT_TIMESTAMP`.

---

## 12. Colocar título em maiúsculas

Transformar `titulo` automaticamente para maiúsculas.

---

## 13. Colocar descrição em maiúsculas

Transformar `descricao` automaticamente para maiúsculas.

---

## 14. Impedir serviço sem título

Bloquear inserção se `titulo` estiver vazio.

---

## 15. Impedir criador inexistente

Validar se `criador_id` existe na tabela `usuario`.

---

---

# Parte 4 — Trigger em status

## 16. Registrar horário automaticamente

Se `data_hora` estiver nulo, preencher automaticamente.

**Tabela:** `status`

---

## 17. Converter situação para maiúsculas

Sempre armazenar `situacao` em letras maiúsculas.

---

## 18. Impedir status vazio

Bloquear inserção de status com texto vazio.

---

## 19. Atualizar serviço como finalizado

Se o novo status inserido contiver a palavra `"FINALIZADO"`, atualizar:

```sql
servico.finalizado = CURRENT_TIMESTAMP
```

---

## 20. Reabrir serviço automaticamente

Se inserir um status contendo `"REABERTO"`, definir:

```sql
servico.finalizado = NULL
```

---

# Parte 5 — Auditoria (`AFTER INSERT`, `AFTER UPDATE`, `AFTER DELETE`)

Primeiro crie uma tabela:

```sql
CREATE TABLE auditoria (
    id serial primary key,
    tabela text,
    operacao text,
    data_hora timestamp default current_timestamp
);
```

---

## 21. Registrar inserções em `usuario`

Toda vez que inserir um usuário, gravar auditoria.

---

## 22. Registrar alterações em `usuario`

Toda vez que atualizar usuário, registrar auditoria.

---

## 23. Registrar remoções em `usuario`

Toda vez que excluir usuário, registrar auditoria.

---

## 24. Registrar inserções em `servico`

Salvar auditoria automaticamente.

---

## 25. Registrar alterações de responsável

Se `responsavel_id` mudar, registrar auditoria.

---

# Parte 6 — Exercícios mais interessantes

## 26. Criar status inicial automaticamente

Ao inserir um novo serviço, criar automaticamente um status:

```text
SERVIÇO ABERTO
```

---

## 27. Contar quantos serviços cada usuário criou

Criar coluna:

```sql
ALTER TABLE usuario ADD COLUMN total_servicos integer default 0;
```

Criar trigger para incrementar automaticamente ao criar novo serviço.

---

## 28. Diminuir contador ao excluir serviço

Ao apagar um serviço, decrementar `total_servicos`.

---

## 29. Impedir exclusão de usuário com serviços cadastrados

Bloquear `DELETE` se usuário for criador ou responsável por algum serviço.

---

## 30. Impedir exclusão de equipamento ativo

Bloquear remoção se:

```sql
ativo = true
```

---

# Desafios

## 31. Histórico de senhas

Criar tabela:

```sql
historico_senha(
    id,
    usuario_id,
    senha_antiga,
    data_hora
)
```

Salvar senha antiga toda vez que a senha mudar.

---

## 32. Histórico de responsáveis

Criar tabela para registrar toda troca de responsável em `servico`.

---

## 33. Log completo de mudanças em serviços

Salvar:

* valor antigo
* valor novo
* usuário responsável
* data

---

## 34. Impedir mais de 5 serviços abertos por usuário

Antes de inserir serviço, verificar quantidade.

---

## 35. Finalizar serviço automaticamente

Se um status contiver:

```text
RESOLVIDO
```

Atualizar automaticamente:

```sql
servico.finalizado = CURRENT_TIMESTAMP;
```

---

Esses exercícios cobrem:

* `BEFORE INSERT`
* `BEFORE UPDATE`
* `AFTER INSERT`
* `AFTER UPDATE`
* `AFTER DELETE`
* uso de `NEW`
* uso de `OLD`
* `RAISE EXCEPTION`
* automação entre tabelas
* auditoria
* regras de negócio com triggers

