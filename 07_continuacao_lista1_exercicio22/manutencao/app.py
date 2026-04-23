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



@app.route("/alterar_usuario", methods=['POST'])
def usuario_alterar():
    id = int(request.form['id'])
    nome = request.form['nome']
    email = request.form['email']
    radio_senha = request.form['radio_senha']
    senha = request.form['senha']
    if (radio_senha == "true"):
        with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
            with conn.cursor() as cur:
                cur.execute("UPDATE usuario SET nome = %s, email = %s where id = %s", [nome, email, id])
    else:
        with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
            with conn.cursor() as cur:
                cur.execute("UPDATE usuario SET nome = %s, email = %s, senha = %s where id = %s", [nome, email, senha, id])
    return redirect(url_for('index'))


@app.route("/equipamento/tela_adicionar")
def equipamento_tela_adicionar():
    return render_template('/equipamento/tela_adicionar.html')

@app.route("/servico/finalizar/<id>")
def finalizar(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("update servico set finalizado = current_timestamp where id = %s;", [id])
    return redirect(url_for('listar_servico'))


@app.route("/servico/adicionar_status", methods=['POST'])
def adicionar_status():
    situacao = request.form['situacao']
    dono_status = request.form['dono_status']
    servico_id = int(request.form['servico_id'])
    criador_id = int(dono_status.split('-')[1]) if dono_status.split('-')[0] == "criador" else None
    responsavel_id = int(dono_status.split('-')[1]) if dono_status.split('-')[0] == "responsavel" else None
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("INSERT INTO status (situacao, servico_id, criador_id, responsavel_id) values (%s,%s,%s,%s);", [situacao, servico_id, criador_id, responsavel_id])
    return redirect(url_for('listar_servico'))

@app.route("/servico/visualizar_status/<id>")
def servico_listar_status(id):
    vetStatus = []
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("select * from status where servico_id = %s;", [id])
            vetStatus = cur.fetchall()
    return render_template('/servico/visualizar_status.html', vetStatus = vetStatus)


@app.route("/servico/adicionar", methods=['POST'])
def adicionar_servico():
    titulo = request.form['titulo']
    descricao = request.form['descricao']
    criador_id = int(request.form['criador_id'])
    responsavel_id = int(request.form['responsavel_id'])
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("INSERT INTO servico (titulo, descricao, criador_id, responsavel_id) values (%s,%s,%s,%s);", [titulo, descricao, criador_id, responsavel_id])
    return redirect(url_for('listar_servico'))


@app.route("/servico/editar", methods=['POST'])
def editar_servico():
    titulo = request.form['titulo']
    descricao = request.form['descricao']
    criador_id = int(request.form['criador_id'])
    responsavel_id = int(request.form['responsavel_id'])
    servico_id = int(request.form['servico_id'])

    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("UPDATE servico SET titulo = %s, descricao = %s, criador_id = %s, responsavel_id = %s where id = %s", [titulo, descricao, criador_id, responsavel_id, servico_id])
    return redirect(url_for('listar_servico'))


@app.route("/servico/tela_adicionar_status/<id>")
def servico_tela_adicionar_status(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:            
            cur.execute("select * from servico where id = %s;", [id])
            servico = cur.fetchone()
            cur.execute("select * from usuario where id = %s;", [servico[5]])
            criador = cur.fetchone()
            cur.execute("select * from usuario where id = %s;", [servico[6]])
            responsavel = cur.fetchone()
    return render_template('/servico/tela_adicionar_status.html',servico_id = servico[0], criador=criador, responsavel=responsavel)

@app.route("/servico/tela_adicionar")
def servico_tela_adicionar():
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur: 
            cur.execute("select * from usuario;")
            vetUsuario = cur.fetchall()
    return render_template('/servico/tela_adicionar.html',vetCriador=vetUsuario, vetResponsavel=vetUsuario)

@app.route("/servico/tela_editar/<id>")
def servico_tela_editar(id):    
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur: 
            cur.execute("select * from usuario;")
            vetUsuario = cur.fetchall()
            cur.execute("select * from servico where id = %s;", [int(id)])
            servico = cur.fetchone()            
    return render_template('/servico/tela_editar.html',vetCriador=vetUsuario, vetResponsavel=vetUsuario, servico = servico)



@app.route("/equipamento/tela_editar/<id>")
def equipamento_tela_editar(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("select * from equipamento where id = %s;", [id])
            return render_template('/equipamento/tela_editar.html', equipamento = cur.fetchone())
        

@app.route("/usuario/tela_alterar/<id>")
def usuario_tela_alterar(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("select * from usuario where id = %s;", [id])
            return render_template('/tela_alterar.html', usuario = cur.fetchone())

@app.route("/equipamento/remover/<id>")
def equipamento_remover(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("CALL remover_equipamento(%s);", [id])
    return redirect(url_for('listar_equipamento'))


@app.route("/usuario/remover/<id>")
def usuario_remover(id):
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute("UPDATE usuario SET ativo = FALSE where id = %s;", [id])
    return redirect(url_for('index'))

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
            cur.execute("select * from usuario where ativo is true;")
            return render_template('index.html', vetUsuario=cur.fetchall())
    # return "<p>Hello, World!</p>"

@app.route("/dashboard")
def dashboard():
    sql = "select extract(year from finalizado) as ano, count(*) as qtde from servico where finalizado is not null group by extract(year from finalizado);"
    labels = []
    data = []    
    with psycopg.connect("dbname=manutencao host=localhost port=5432 user=postgres password=postgres") as conn:
        with conn.cursor() as cur:
            cur.execute(sql)
            vetResult = cur.fetchall()
            for result in vetResult:
                labels.append(result[0])
                data.append(result[1])                
    return render_template('teste.html', labels=labels, data=data)
"""
16/04 - pendencias
adicionar servico -> ok
finalizar servico -> pendente +ou- (por quem?)
visualizar status -> ok
editar servico -> ok
cadastrar status -> ok +ou- (por quem? - qual criador e responsável atual?)
login
upload de arquivo
trocar tela inicial por servico listar
log
dashboard - indicadores graficos -> ok (1 feito)
"""

# para executar
# flask --app app run