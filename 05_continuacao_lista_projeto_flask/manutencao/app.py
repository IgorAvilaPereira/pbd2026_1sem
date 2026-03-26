# python3 -m venv .venv
# . .venv/bin/activate
# pip install Flask
from flask import Flask
# pip install "psycopg[binary]"
import psycopg
from flask import render_template
from flask import abort, redirect, url_for
from flask import request
from flask import jsonify
import json


app = Flask(__name__)


@app.route("/sugere_senha")
def sugere_senha():
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT geradorSenha()")
            senha = cur.fetchone()
            retorno = {"senha": senha}
            return json.dumps(retorno)
   

@app.route("/adicionar_usuario", methods=['POST'])
def adicionar_usuario():
    nome = request.form['nome']
    email = request.form['email']
    senha = request.form['senha']
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL cadastra_usuario(%s, %s, %s)", [nome, email, senha])
    return redirect(url_for('index'))

@app.route("/equipamento/adicionar_equipamento", methods=['POST'])
def adicionar_equipamento():
    descricao = request.form['descricao']
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL cadastrar_equipamento(%s)", [descricao])
    return redirect(url_for('listar_equipamento'))

@app.route("/equipamento/editar_equipamento", methods=['POST'])
def editar_equipamento():
    descricao = request.form['descricao']
    id = int(request.form['id'])

    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL atualizar_equipamento(%s, %s)", [id, descricao])
    return redirect(url_for('listar_equipamento'))



@app.route("/equipamento/tela_adicionar")
def equipamento_tela_adicionar():
    return render_template('/equipamento/tela_adicionar.html')


@app.route("/equipamento/tela_editar/<id>")
def equipamento_tela_editar(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("select * from equipamento where id = %s;", [id])
            return render_template('/equipamento/tela_editar.html', equipamento = cur.fetchone())

@app.route("/equipamento/remover/<id>")
def equipamento_remover(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL remover_equipamento(%s);", [id])
    return redirect(url_for('listar_equipamento'))


@app.route("/tela_adicionar")
def tela_adicionar():
    return render_template('tela_adicionar.html')

@app.route("/equipamento")
def listar_equipamento():
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("select * from equipamento where ativo is true;")
            return render_template('/equipamento/index.html', vetEquipamento=cur.fetchall())
   


@app.route("/servico")
def listar_servico():
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("with tb_criador AS (select servico.id, titulo, data_hora_criacao, finalizado, nome as criador, responsavel_id from servico inner join usuario on (servico.criador_id = usuario.id)) SELECT *, usuario.nome as responsavel from tb_criador inner join usuario on (tb_criador.responsavel_id = usuario.id);")
            # print(cur.fetchall())
            return render_template('/servico/index.html', vetServico=cur.fetchall())
   


@app.route("/")
def index():
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            # cur.execute("select * from busque_usuario_por_email(%s);", [email])
            # print(cur.fetchone())
            cur.execute("select * from usuario;")
            return render_template('index.html', vetUsuario=cur.fetchall())
    # return "<p>Hello, World!</p>"



# para executar
# flask --app app run