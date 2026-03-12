# python3 -m venv .venv
# . .venv/bin/activate
# pip install Flask
from flask import Flask
# pip install "psycopg[binary]"
import psycopg
from flask import render_template
from flask import abort, redirect, url_for
from flask import request

app = Flask(__name__)

@app.route("/adicionar_usuario", methods=['POST'])
def adicionar_usuario():
    nome = request.form['nome']
    email = request.form['email']
    senha = request.form['senha']
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL cadastra_usuario(%s, %s, %s)", [nome, email, senha])
    return redirect(url_for('index'))


@app.route("/tela_adicionar")
def tela_adicionar():
    return render_template('tela_adicionar.html')


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