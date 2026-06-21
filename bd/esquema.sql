-- Creates, triggers, procedures e functions


CREATE TABLE cargo (
    id_cargo INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE lotacao (
    sigla VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE servidor (
    matricula INTEGER PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    rg VARCHAR(20) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    genero VARCHAR(20) NOT NULL,
    dt_nascimento DATE NOT NULL,
    dt_admissao DATE NOT NULL,
    estado_civil VARCHAR(30) NOT NULL,
    endereco VARCHAR(200) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    situacao_funcional VARCHAR(50) NOT NULL,

    id_cargo INTEGER NOT NULL,
    sigla_lotacao VARCHAR(20) NOT NULL,

    FOREIGN KEY (id_cargo)
        REFERENCES cargo(id_cargo),

    FOREIGN KEY (sigla_lotacao)
        REFERENCES lotacao(sigla)
);

CREATE TABLE professor (
    matricula INTEGER PRIMARY KEY,
    titulacao VARCHAR(100) NOT NULL,
    area_atuacao VARCHAR(100) NOT NULL,
    linha_pesquisa VARCHAR(200) NOT NULL,

    FOREIGN KEY (matricula)
        REFERENCES servidor(matricula)
        ON DELETE CASCADE
);

CREATE TABLE tecnico (
    matricula INTEGER PRIMARY KEY,
    escala VARCHAR(50) NOT NULL,
    turno VARCHAR(50) NOT NULL,

    FOREIGN KEY (matricula)
        REFERENCES servidor(matricula)
        ON DELETE CASCADE
);

CREATE TABLE disciplina (
    codigo INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    qtd_creditos INTEGER NOT NULL
);

CREATE TABLE professor_disciplina (
    matricula_professor INTEGER NOT NULL,
    codigo_disciplina INTEGER NOT NULL,

    PRIMARY KEY (
        matricula_professor,
        codigo_disciplina
    ),

    FOREIGN KEY (matricula_professor)
        REFERENCES professor(matricula)
        ON DELETE CASCADE,

    FOREIGN KEY (codigo_disciplina)
        REFERENCES disciplina(codigo)
        ON DELETE CASCADE
);

CREATE TABLE folha_pagamento (
    matricula INTEGER NOT NULL,
    competencia DATE NOT NULL,

    salario_base DECIMAL(10,2) NOT NULL,
    adicionais DECIMAL(10,2) DEFAULT 0,
    descontos DECIMAL(10,2) DEFAULT 0,
    encargos DECIMAL(10,2) DEFAULT 0,
    valor_bruto DECIMAL(10,2) NOT NULL,
    valor_liquido DECIMAL(10,2) NOT NULL,
    dados_bancarios VARCHAR(200) NOT NULL,

    PRIMARY KEY (matricula, competencia),

    FOREIGN KEY (matricula)
        REFERENCES servidor(matricula)
        ON DELETE CASCADE
);

-- 1. Índice para busca de servidores pelo nome
CREATE INDEX idx_servidor_nome ON servidor(nome);

-- 2. Índice para filtragem de servidores por lotação
CREATE INDEX idx_servidor_lotacao ON servidor(sigla_lotacao);

-- 3. Índice para buscas de folha de pagamento por data de competência
CREATE INDEX idx_folha_competencia ON folha_pagamento(competencia);

-- 4. Índice para busca de professores por área de atuação
CREATE INDEX idx_professor_area ON professor(area_atuacao);

-- 5. Índice para consultas frequentes de contato/login por e-mail
CREATE INDEX idx_servidor_email ON servidor(email);

-- Function 1: calcula a idade atual de um servidor a partir do nascimento
CREATE OR REPLACE FUNCTION fn_calcular_idade(p_matricula INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_nascimento DATE;
    v_idade      INTEGER;
BEGIN
    SELECT dt_nascimento
    INTO v_nascimento
    FROM servidor
    WHERE matricula = p_matricula;

    IF v_nascimento IS NULL THEN
        RAISE EXCEPTION 'Servidor % nao encontrado.', p_matricula;
    END IF;

    v_idade := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_nascimento));
    RETURN v_idade;
END;
$$ LANGUAGE plpgsql;


-- Function 2: total liquido ja pago a um servidor (soma das folhas)
CREATE OR REPLACE FUNCTION fn_total_liquido_servidor(p_matricula INTEGER)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT SUM(valor_liquido)
    INTO v_total
    FROM folha_pagamento
    WHERE matricula = p_matricula;

    -- COALESCE: se o servidor nao tiver folhas, retorna 0
    RETURN COALESCE(v_total, 0);
END;
$$ LANGUAGE plpgsql;


-- Function 3: total de creditos das disciplinas ministradas por um professor
CREATE OR REPLACE FUNCTION fn_creditos_professor(p_matricula INTEGER)
RETURNS INTEGER AS $$
DECLARE
    v_creditos INTEGER;
BEGIN
    SELECT SUM(d.qtd_creditos)
    INTO v_creditos
    FROM professor_disciplina pd
    JOIN disciplina d ON pd.codigo_disciplina = d.codigo
    WHERE pd.matricula_professor = p_matricula;

    RETURN COALESCE(v_creditos, 0);
END;
$$ LANGUAGE plpgsql;


-- =====================================================================
-- PROCEDURES (4) - executam acoes (chamadas com CALL)
-- =====================================================================

-- Procedure 1: inativar um servidor (regra do projeto: "inativar servidores")
CREATE OR REPLACE PROCEDURE sp_inativar_servidor(p_matricula INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nome VARCHAR(100);
BEGIN
    SELECT nome
    INTO v_nome
    FROM servidor
    WHERE matricula = p_matricula;

    IF v_nome IS NULL THEN
        RAISE EXCEPTION 'Servidor % nao encontrado.', p_matricula;
    END IF;

    UPDATE servidor
    SET situacao_funcional = 'Inativo'
    WHERE matricula = p_matricula;

    RAISE NOTICE 'Servidor % (%) inativado com sucesso.', p_matricula, v_nome;
END;
$$;


-- Procedure 2: transferir um servidor para outra lotacao (controle de lotacao)
CREATE OR REPLACE PROCEDURE sp_transferir_lotacao(
    p_matricula   INTEGER,
    p_nova_sigla  VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM servidor WHERE matricula = p_matricula) THEN
        RAISE EXCEPTION 'Servidor % nao encontrado.', p_matricula;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM lotacao WHERE sigla = p_nova_sigla) THEN
        RAISE EXCEPTION 'Lotacao % nao existe.', p_nova_sigla;
    END IF;

    UPDATE servidor
    SET sigla_lotacao = p_nova_sigla
    WHERE matricula = p_matricula;

    RAISE NOTICE 'Servidor % transferido para a lotacao %.', p_matricula, p_nova_sigla;
END;
$$;


-- Procedure 3: processar a folha de pagamento de um servidor
-- usada na funcionalidade 1
CREATE OR REPLACE PROCEDURE sp_processar_folha(
    p_matricula        INTEGER,
    p_competencia      DATE,
    p_salario_base     DECIMAL(10,2),
    p_adicionais       DECIMAL(10,2),
    p_descontos        DECIMAL(10,2),
    p_encargos         DECIMAL(10,2),
    p_dados_bancarios  VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_bruto   DECIMAL(10,2);    
    v_liquido DECIMAL(10,2);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM servidor WHERE matricula = p_matricula) THEN
        RAISE EXCEPTION 'Servidor % nao encontrado.', p_matricula;
    END IF;

    v_bruto   := p_salario_base + COALESCE(p_adicionais, 0);
    v_liquido := v_bruto - COALESCE(p_descontos, 0) - COALESCE(p_encargos, 0);

    INSERT INTO folha_pagamento (
        matricula, competencia, salario_base, adicionais,
        descontos, encargos, valor_bruto, valor_liquido, dados_bancarios
    ) VALUES (
        p_matricula, p_competencia, p_salario_base, COALESCE(p_adicionais, 0),
        COALESCE(p_descontos, 0), COALESCE(p_encargos, 0),
        v_bruto, v_liquido, p_dados_bancarios
    );

    RAISE NOTICE 'Folha de % processada. Bruto = %, Liquido = %',
        p_competencia, v_bruto, v_liquido;
END;
$$;


-- Procedure 4: recalcular TODAS as folhas de um servidor (com iteracao FOR LOOP)
-- Mesma ideia do Exemplo 2 dos slides (percorre varios registros em lote)
CREATE OR REPLACE PROCEDURE sp_recalcular_folhas_servidor(p_matricula INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_folha   RECORD;
    v_bruto   DECIMAL(10,2);
    v_liquido DECIMAL(10,2);
BEGIN
    FOR v_folha IN
        SELECT competencia, salario_base, adicionais, descontos, encargos
        FROM folha_pagamento
        WHERE matricula = p_matricula
    LOOP
        v_bruto   := v_folha.salario_base + COALESCE(v_folha.adicionais, 0);
        v_liquido := v_bruto - COALESCE(v_folha.descontos, 0) - COALESCE(v_folha.encargos, 0);

        UPDATE folha_pagamento
        SET valor_bruto   = v_bruto,
            valor_liquido = v_liquido
        WHERE matricula   = p_matricula
          AND competencia = v_folha.competencia;

        RAISE NOTICE 'Competencia % recalculada. Bruto = %, Liquido = %',
            v_folha.competencia, v_bruto, v_liquido;
    END LOOP;
END;
$$;


-- =====================================================================
-- TRIGGERS (3) - funcao RETURNS TRIGGER + CREATE TRIGGER
-- =====================================================================

-- ---------------------------------------------------------------------
-- Trigger 1: calcula automaticamente valor_bruto e valor_liquido
-- da folha sempre que uma linha for inserida ou atualizada.
-- garante que nao tera NULLs
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_calcular_valores_folha()
RETURNS TRIGGER AS $$
BEGIN
    NEW.adicionais := COALESCE(NEW.adicionais, 0);
    NEW.descontos  := COALESCE(NEW.descontos, 0);
    NEW.encargos   := COALESCE(NEW.encargos, 0);

    NEW.valor_bruto   := NEW.salario_base + NEW.adicionais;
    NEW.valor_liquido := NEW.valor_bruto - NEW.descontos - NEW.encargos;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calcular_valores_folha
BEFORE INSERT OR UPDATE ON folha_pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_valores_folha();


-- ---------------------------------------------------------------------
-- Trigger 2: valida os dados do servidor antes de inserir/atualizar
-- (garantir integridade)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_servidor()
RETURNS TRIGGER AS $$
BEGIN
    -- Admissao nao pode ser anterior ao nascimento
    IF NEW.dt_admissao < NEW.dt_nascimento THEN
        RAISE EXCEPTION 'Data de admissao (%) anterior a data de nascimento (%).',
            NEW.dt_admissao, NEW.dt_nascimento;
    END IF;

    -- Servidor precisa ter pelo menos 18 anos na admissao
    IF EXTRACT(YEAR FROM AGE(NEW.dt_admissao, NEW.dt_nascimento)) < 18 THEN
        RAISE EXCEPTION 'Servidor nao pode ser admitido com menos de 18 anos.';
    END IF;

    -- E-mail institucional precisa conter '@'
    IF POSITION('@' IN NEW.email) = 0 THEN
        RAISE EXCEPTION 'E-mail invalido: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_servidor
BEFORE INSERT OR UPDATE ON servidor
FOR EACH ROW
EXECUTE FUNCTION fn_validar_servidor();


-- ---------------------------------------------------------------------
-- Trigger 3: impede que os descontos sejam maiores que o valor bruto
-- da folha (garantir integridade dos dados)
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_validar_descontos_folha()
RETURNS TRIGGER AS $$
DECLARE
    v_bruto DECIMAL(10,2);
BEGIN
    
    v_bruto := NEW.salario_base + COALESCE(NEW.adicionais, 0);

    IF COALESCE(NEW.descontos, 0) > v_bruto THEN
        RAISE EXCEPTION 'Descontos (%) nao podem ser maiores que o valor bruto (%).',
            NEW.descontos, v_bruto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_descontos_folha
BEFORE INSERT OR UPDATE ON folha_pagamento
FOR EACH ROW
EXECUTE FUNCTION fn_validar_descontos_folha();