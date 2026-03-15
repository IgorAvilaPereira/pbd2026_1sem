# Trabalho 1 – Sistema de Manutenção com PostgreSQL + Flask + Mustache (5 pontos)

## Objetivo

Desenvolver funcionalidades no banco utilizando **Functions e Stored Procedures em PostgreSQL** e criar uma **aplicação web simples com Flask e Mustache Template** que utilize essas rotinas.

O sistema deve permitir **consultar informações e executar ações sobre os serviços de manutenção**.

---

# Parte 1 – Lógica no Banco de Dados (3 pontos)

## 1 — Função de prioridade do serviço (0,5)

Crie uma **function** que determine a **prioridade de um serviço** com base na quantidade de status registrados.

Regra:

| Quantidade de status | Prioridade |
| -------------------- | ---------- |
| 1                    | Baixa      |
| 2 a 3                | Média      |
| 4 ou mais            | Alta       |

Parâmetro:

```
id_servico
```

Retorno:

```
prioridade (texto)
```

---

## 2 — Função para calcular tempo de atendimento (0,5)

Crie uma **function** que calcule o **tempo de atendimento de um serviço finalizado**.

Cálculo:

```
finalizado - data_hora_cricao
```

A função deve retornar:

```
tempo_em_horas
```

Caso o serviço **não esteja finalizado**, retornar **NULL**.

---

## 3 — Ranking de técnicos (0,5)

Crie uma **function** que gere um **ranking de usuários responsáveis por serviços finalizados**.

Retorno esperado:

```
nome_usuario
quantidade_servicos_finalizados
```

Ordenado do maior para o menor.

---

## 4 — Procedure para reabrir serviço (0,5)

Crie uma **stored procedure** que permita **reabrir um serviço finalizado**.

A procedure deve:

1. Remover o valor do campo `finalizado`
2. Registrar automaticamente um novo status com o texto:

```
Serviço reaberto
```

---

## 5 — Procedure de registro inteligente de status (0,5)

Crie uma **stored procedure** que registre um **novo status** em um serviço.

Parâmetros:

```
servico_id
mensagem_status
```

Regra adicional:

Se a mensagem contiver a palavra **"resolvido"**, a procedure deve **finalizar automaticamente o serviço**.

---

## 6 — Função Dashboard do sistema (0,5)

Crie uma **function** que retorne informações para um **dashboard do sistema**.

Ela deve retornar:

```
total_servicos
servicos_abertos
servicos_finalizados
tempo_medio_atendimento_horas
```

O tempo médio deve considerar apenas **serviços finalizados**.

---

# Parte 2 – Aplicação Web com Flask + Mustache (2 pontos)

Criar uma aplicação **Flask** que utilize:

* **PostgreSQL**
* **Stored Procedures e Functions**
* **Mustache Templates**

A aplicação deve possuir **páginas HTML renderizadas no servidor**.

---

# Página 1 – Dashboard do Sistema (0,5)

Rota:

```
/
```

Deve exibir:

* total de serviços
* serviços abertos
* serviços finalizados
* tempo médio de atendimento

Esses dados devem vir da **função de dashboard criada no banco**.

---

# Página 2 – Ranking de técnicos (0,5)

Rota:

```
/ranking
```

A página deve mostrar uma **tabela com o ranking de técnicos**, contendo:

| Técnico | Serviços finalizados |

Os dados devem vir da **function de ranking**.

---

# Página 3 – Consulta de prioridade de serviço (0,5)

Rota:

```
/servico/<id>
```

A página deve exibir:

* título do serviço
* descrição
* prioridade calculada

A prioridade deve vir da **function criada na Parte 1**.

---

# Página 4 – Registrar status (0,5)

Criar um formulário HTML que permita registrar um novo status.

Campos:

```
servico_id
mensagem
```

Ao enviar o formulário, a aplicação deve chamar a **stored procedure de registro inteligente de status**.

---

# Estrutura mínima do projeto

```
trabalho/
│
├── app.py
├── db.py
├── requirements.txt
│
├── templates/
│   dashboard.mustache
│   ranking.mustache
│   servico.mustache
│   status.mustache
│
└── sql/
    schema.sql
    funcoes_procedures.sql
```

---

# Tecnologias obrigatórias

* **Python**
* **Flask**
* **PostgreSQL**
* **Mustache Templates**
* **psycopg2**

---

# Critérios de Avaliação

| Item                      | Pontos |
| ------------------------- | ------ |
| Functions corretas        | 1,5    |
| Procedures corretas       | 1,0    |
| Integração Flask + Banco  | 1,0    |
| Uso de Mustache Templates | 0,5    |
| Organização do projeto    | 1,0    |

Total: **5 pontos**
