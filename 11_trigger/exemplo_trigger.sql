-- Log de venda de ingresso em tabela log.
-- https://www.postgresql.org/docs/current/plpgsql-trigger.html

drop trigger registra_log_venda_ingresso_trigger on ingresso;
drop trigger registra_log_venda_ingresso_trigger2 on ingresso;
drop function registra_log_venda_ingresso;

create or replace function registra_log_venda_ingresso() RETURNS trigger as $$
DECLARE
	filme_nome text;
BEGIN
	IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
		select filme.titulo from filme join sessao on sessao.filme_id = filme.id into filme_nome;
		INSERT INTO log(texto) VALUES(TG_WHEN||': Telespectador de CPF:'||NEW.cpf||' adquiriu um ingresso para a sessao:'||NEW.sessao_id||' do filme '||filme_nome||'-> Qual operação disparou esta trigger? '||TG_OP);
	ELSE
		INSERT INTO log(texto) VALUES(TG_OP||' - '||TG_TABLE_NAME);
	END IF;
	RETURN NEW;
END;
$$ language 'plpgsql';


create trigger registra_log_venda_ingresso_trigger 
after insert or update on ingresso for each row execute procedure registra_log_venda_ingresso(); 


create trigger registra_log_venda_ingresso_trigger2 
before delete on ingresso for each row execute procedure registra_log_venda_ingresso(); 

INSERT INTO ingresso(cpf, sessao_id, valor, poltrona_id) VALUES ('01763917037', 3, 1.99, 6);

update ingresso set valor = 2.99;

delete from ingresso where cpf = '01763917037';


select * from log;
