# Trabalho 2 – Sistema de Manutenção com Triggers + PostgreSQL + Flask (5 pontos)

## Objetivo

Estender o sistema de manutenção desenvolvido anteriormente, adicionando automações utilizando:

* Triggers PostgreSQL
* Trigger Functions
* Flask
* Jinja2
* PostgreSQL

O objetivo é automatizar regras de negócio diretamente no banco de dados e integrar essas funcionalidades à aplicação web.

---

# Requisito 1 – Trigger de Auditoria (1 ponto)

Criar mecanismos de auditoria automática utilizando triggers.

A aplicação deve registrar automaticamente operações realizadas no sistema.

Exemplo de tabela:

```sql id="e6nrq5"
CREATE TABLE auditoria (
    id SERIAL PRIMARY KEY,
    tabela TEXT,
    operacao TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

A trigger deve registrar automaticamente:

* inserções;
* alterações;
* exclusões.

O aluno poderá escolher quais tabelas serão auditadas.

---

# Requisito 2 – Trigger de Automatização de Serviços (1 ponto)

Criar triggers que automatizem regras relacionadas aos serviços.

Exemplos possíveis:

* atualizar campos automaticamente;
* preencher datas;
* alterar situação;
* gerar registros auxiliares;
* validar regras antes de salvar.

As regras implementadas devem ser diferentes das já utilizadas na lista de exercícios disponibilizada em aula.

---

# Requisito 3 – Trigger com Regras de Negócio Avançadas (1 ponto)

Implementar ao menos uma trigger contendo lógica mais elaborada envolvendo:

* múltiplas tabelas;
* uso de `NEW` e `OLD`;
* validações;
* contadores;
* bloqueios;
* consistência dos dados.

Exemplos possíveis:

* limitar quantidade de serviços abertos;
* impedir inconsistências;
* registrar histórico;
* controlar mudanças importantes do sistema.

A trigger deve possuir justificativa clara de negócio.

---

# Requisito 4 – Integração Flask + PostgreSQL (1 ponto)

A aplicação Flask deve possuir páginas HTML utilizando:

* Flask;
* Jinja2 Templates;
* psycopg2;
* PostgreSQL.

Implementar rotas para:

* listar informações;
* executar ações que disparem triggers;
* visualizar os efeitos das automações realizadas no banco.

---

# Requisito 5 – Demonstração e Organização do Projeto (1 ponto)

O trabalho deve conter:

* projeto Flask funcional;
* scripts SQL organizados;
* triggers separadas em arquivo próprio;
* banco populado para testes.

Também deverá existir uma breve documentação explicando:

* quais triggers foram criadas;
* qual problema cada trigger resolve;
* quais tabelas foram afetadas.

---

# Restrições

Não será permitido:

* ORM;
* SQLAlchemy ORM;
* regras implementadas apenas no Flask;
* reutilizar exatamente os mesmos exercícios da lista de triggers trabalhada em aula.

As regras devem possuir adaptações, extensões ou novas ideias.

---

# Tecnologias obrigatórias

* Python
* Flask
* PostgreSQL
* psycopg2
* Jinja2
* Trigger Functions
* Triggers PostgreSQL

---

# Critérios de avaliação

| Requisito                     | Pontos |
| ----------------------------- | ------ |
| Trigger de auditoria          | 1,0    |
| Automação com triggers        | 1,0    |
| Regras de negócio avançadas   | 1,0    |
| Integração Flask + PostgreSQL | 1,0    |
| Organização + documentação    | 1,0    |

# Total: 5,0 pontos
