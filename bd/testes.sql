-- testes


EXPLAIN SELECT matricula, nome, cpf, email, situacao_funcional 
FROM servidor 
WHERE nome = 'João Silva';
EXPLAIN SELECT matricula, nome, cpf, email, situacao_funcional 
FROM servidor 
WHERE nome = 'João Silva';
EXPLAIN SELECT SUM(valor_bruto) AS total_gasto_janeiro
FROM folha_pagamento
WHERE competencia = '2024-01-01';
EXPLAIN SELECT s.matricula, s.nome, p.titulacao, p.linha_pesquisa
FROM professor p
JOIN servidor s ON p.matricula = s.matricula
WHERE p.area_atuacao = 'Banco de Dados';
EXPLAIN SELECT matricula, nome, situacao_funcional
FROM servidor
WHERE email = 'maria@universidade.edu';

SELECT fn_calcular_idade(1001);
SELECT fn_total_liquido_servidor(1001);
SELECT fn_creditos_professor(1001);

CALL sp_inativar_servidor(1003);
CALL sp_transferir_lotacao(1001, 'DM');
CALL sp_processar_folha(1002, '2024-03-01', 6500, 400, 250, 650, 'Caixa Ag:2222 C/C:11111-1');
CALL sp_recalcular_folhas_servidor(1001);

-- T1: insere folha sem informar bruto/liquido; o trigger calcula:
INSERT INTO folha_pagamento (matricula, competencia, salario_base, adicionais,
    descontos, encargos, valor_bruto, valor_liquido, dados_bancarios)
VALUES (1002, '2024-04-01', 6500, 400, 250, 650, 0, 0, 'Caixa Ag:2222 C/C:11111-1');
SELECT valor_bruto, valor_liquido FROM folha_pagamento
WHERE matricula = 1002 AND competencia = '2024-04-01';   -- 6900 / 6000

UPDATE servidor SET email = 'semarroba@bolas.com' WHERE matricula = 1001;

INSERT INTO folha_pagamento (matricula, competencia, salario_base, adicionais,
    descontos, encargos, valor_bruto, valor_liquido, dados_bancarios)
VALUES (1002, '2024-05-01', 6500, 400, 2000, 650, 0, 0, 'Caixa Ag:2222 C/C:11111-1');