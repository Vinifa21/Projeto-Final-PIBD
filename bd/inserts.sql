-- ==========================
-- CARGOS
-- ==========================

INSERT INTO cargo (id_cargo, nome) VALUES
(1, 'Professor Efetivo'),
(2, 'Técnico Administrativo'),
(3, 'Coordenador');

-- ==========================
-- LOTAÇÕES
-- ==========================

INSERT INTO lotacao (sigla, nome) VALUES
('DC', 'Departamento de Computação'),
('DM', 'Departamento de Matemática'),
('DeMA', 'Departamento de Engenharia de Materiais');

-- ==========================
-- SERVIDORES
-- ==========================

INSERT INTO servidor (
    matricula,
    cpf,
    rg,
    nome,
    genero,
    dt_nascimento,
    dt_admissao,
    estado_civil,
    endereco,
    telefone,
    email,
    situacao_funcional,
    id_cargo,
    sigla_lotacao
) VALUES
(
    1001,
    '123.456.789-01',
    'MG1234567',
    'João Silva',
    'Masculino',
    '1980-05-12',
    '2010-03-15',
    'Casado',
    'Rua A, 100',
    '(31)99999-1111',
    'joao@universidade.edu',
    'Ativo',
    1,
    'DC'
),
(
    1002,
    '987.654.321-02',
    'MG7654321',
    'Maria Oliveira',
    'Feminino',
    '1985-09-20',
    '2012-08-01',
    'Solteira',
    'Rua B, 200',
    '(31)99999-2222',
    'maria@universidade.edu',
    'Ativo',
    1,
    'DM'
),
(
    1003,
    '111.222.333-44',
    'MG9988776',
    'Carlos Pereira',
    'Masculino',
    '1990-01-10',
    '2018-02-05',
    'Casado',
    'Rua C, 300',
    '(31)99999-3333',
    'carlos@universidade.edu',
    'Ativo',
    2,
    'DeMA'
);

-- ==========================
-- PROFESSORES
-- ==========================

INSERT INTO professor (
    matricula,
    titulacao,
    area_atuacao,
    linha_pesquisa
) VALUES
(
    1001,
    'Doutorado',
    'Banco de Dados',
    'Sistemas de Informação'
),
(
    1002,
    'Mestrado',
    'Matemática Aplicada',
    'Otimização'
);

-- ==========================
-- TÉCNICOS
-- ==========================

INSERT INTO tecnico (
    matricula,
    escala,
    turno
) VALUES
(
    1003,
    '12x36',
    'Diurno'
);

-- ==========================
-- DISCIPLINAS
-- ==========================

INSERT INTO disciplina (
    codigo,
    nome,
    qtd_creditos
) VALUES
(101, 'Banco de Dados', 4),
(102, 'Estruturas de Dados', 4),
(201, 'Cálculo I', 6),
(202, 'Álgebra Linear', 4);

-- ==========================
-- PROFESSOR x DISCIPLINA
-- ==========================

INSERT INTO professor_disciplina (
    matricula_professor,
    codigo_disciplina
) VALUES
(1001, 101),
(1001, 102),
(1002, 201),
(1002, 202);

-- ==========================
-- FOLHAS DE PAGAMENTO
-- ==========================

INSERT INTO folha_pagamento (
    matricula,
    competencia,
    salario_base,
    adicionais,
    descontos,
    encargos,
    valor_bruto,
    valor_liquido,
    dados_bancarios
) VALUES
(
    1001,
    '2024-01-01',
    8000.00,
    500.00,
    300.00,
    800.00,
    8500.00,
    7400.00,
    'Banco do Brasil Ag:1234 C/C:56789-0'
),
(
    1001,
    '2024-02-01',
    8000.00,
    600.00,
    350.00,
    820.00,
    8600.00,
    7430.00,
    'Banco do Brasil Ag:1234 C/C:56789-0'
),
(
    1002,
    '2024-01-01',
    6500.00,
    400.00,
    250.00,
    650.00,
    6900.00,
    6000.00,
    'Caixa Ag:2222 C/C:11111-1'
),
(
    1003,
    '2024-01-01',
    3500.00,
    200.00,
    150.00,
    350.00,
    3700.00,
    3200.00,
    'Santander Ag:3333 C/C:22222-2'
);