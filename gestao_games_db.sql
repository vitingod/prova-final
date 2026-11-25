-- CREATE TABLE jogadores (
--     id_jogador SERIAL PRIMARY KEY,
--     nickname VARCHAR(50) NOT NULL UNIQUE,
--     email VARCHAR(100) NOT NULL UNIQUE,
--     senha VARCHAR(100) NOT NULL,
--     status VARCHAR(15) NOT NULL DEFAULT 'ativo',
--     CHECK (status IN ('ativo', 'inativo', 'banido'))
-- );

-- CREATE TABLE modalidades (
--     id_modalidade SERIAL PRIMARY KEY,
--     nome VARCHAR(60) NOT NULL UNIQUE,
--     categoria VARCHAR(40) NOT NULL,
--     descricao TEXT
-- );

-- CREATE TABLE partidas (
--     id_partida SERIAL PRIMARY KEY,
--     titulo VARCHAR(100) NOT NULL,
--     id_jogador INT NOT NULL,
--     id_modalidade INT NOT NULL,
--     data_agendada TIMESTAMP NOT NULL,
--     status VARCHAR(20) NOT NULL DEFAULT 'agendada',
--     data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     FOREIGN KEY (id_jogador) REFERENCES jogadores(id_jogador),
--     FOREIGN KEY (id_modalidade) REFERENCES modalidades(id_modalidade),
--     CHECK (status IN ('agendada', 'em andamento', 'finalizada', 'cancelada'))
-- );

-- CREATE TABLE historico_partidas (
--     id_historico SERIAL PRIMARY KEY,
--     id_partida INT NOT NULL,
--     acao VARCHAR(100) NOT NULL,
--     data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     FOREIGN KEY (id_partida) REFERENCES partidas(id_partida)
-- );

-- CREATE OR REPLACE FUNCTION fn_buscar_jogadores(termo_busca TEXT)
-- RETURNS TABLE (
--     id_jogador INT,
--     nickname VARCHAR(50),
--     email VARCHAR(100),
--     status VARCHAR(15)
-- )
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT j.id_jogador, j.nickname, j.email, j.status
--     FROM jogadores j
--     WHERE j.nickname ILIKE '%' || termo_busca || '%'
--        OR j.email ILIKE '%' || termo_busca || '%';
-- END;
-- $$;

-- CREATE OR REPLACE FUNCTION fn_validar_partida()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     situacao_jogador VARCHAR(15);
-- BEGIN
--     SELECT j.status
--     INTO situacao_jogador
--     FROM jogadores j
--     WHERE j.id_jogador = NEW.id_jogador;

--     IF situacao_jogador IS NULL THEN
--         RAISE EXCEPTION 'Jogador nao encontrado.';
--     END IF;

--     IF situacao_jogador <> 'ativo' THEN
--         RAISE EXCEPTION 'A partida deve estar vinculada a um jogador ativo.';
--     END IF;

--     NEW.data_criacao := CURRENT_TIMESTAMP;

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER trg_validar_partida
-- BEFORE INSERT ON partidas
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_validar_partida();

-- CREATE OR REPLACE FUNCTION fn_registrar_historico()
-- RETURNS TRIGGER
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     INSERT INTO historico_partidas (id_partida, acao)
--     VALUES (NEW.id_partida, 'Partida cadastrada');

--     RETURN NEW;
-- END;
-- $$;

-- CREATE TRIGGER trg_registrar_historico
-- AFTER INSERT ON partidas
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_registrar_historico();

-- CREATE OR REPLACE VIEW vw_painel_principal AS
-- SELECT
--     j.nickname,
--     p.titulo AS titulo_partida,
--     m.categoria AS modalidade,
--     p.data_agendada,
--     p.status
-- FROM partidas p
-- INNER JOIN jogadores j ON p.id_jogador = j.id_jogador
-- INNER JOIN modalidades m ON p.id_modalidade = m.id_modalidade;

-- CREATE OR REPLACE VIEW vw_cronograma_partidas AS
-- SELECT
--     p.id_partida,
--     p.titulo AS titulo_partida,
--     p.data_agendada,
--     p.status,
--     p.data_agendada::DATE - CURRENT_DATE AS dias_restantes,
--     j.nickname AS jogador_responsavel
-- FROM partidas p
-- INNER JOIN jogadores j ON p.id_jogador = j.id_jogador
-- ORDER BY p.data_agendada ASC;

-- INSERT INTO jogadores (nickname, email, senha, status) VALUES
-- ('VitinPlay', 'vitinplay@email.com', 'senha123', 'ativo'),
-- ('NinjaFox', 'ninjafox@email.com', 'abc123', 'ativo'),
-- ('LunaGame', 'lunagame@email.com', 'game456', 'ativo');

-- INSERT INTO modalidades (nome, categoria, descricao) VALUES
-- ('Valorant', 'FPS', 'Jogo de tiro em equipe'),
-- ('League of Legends', 'MOBA', 'Jogo de estrategia em equipe'),
-- ('Rocket League', 'Esporte', 'Futebol com carros');

-- INSERT INTO partidas (titulo, id_jogador, id_modalidade, data_agendada, status)
-- SELECT
--     dados.titulo,
--     j.id_jogador,
--     m.id_modalidade,
--     dados.data_agendada,
--     'agendada'
-- FROM (VALUES
--     ('VitinPlay x NinjaFox', 'VitinPlay', 'Valorant', CURRENT_TIMESTAMP + INTERVAL '2 days'),
--     ('Desafio da Luna', 'LunaGame', 'League of Legends', CURRENT_TIMESTAMP + INTERVAL '5 days'),
--     ('Torneio Rocket', 'NinjaFox', 'Rocket League', CURRENT_TIMESTAMP + INTERVAL '8 days')
-- ) AS dados(titulo, nickname, modalidade, data_agendada)
-- INNER JOIN jogadores j ON j.nickname = dados.nickname
-- INNER JOIN modalidades m ON m.nome = dados.modalidade;
