import psycopg2

def obter_conexao():
    """
    ajustar o 'user' e 'password' se necessário
    """
    return psycopg2.connect(
        host="localhost",
        database="faculdade",
        user="vini21", 
        password="1234" 
    )

def lancar_folha(matricula, competencia, salario_base, adicionais, descontos, encargos, dados_bancarios):
    """
    Chama a procedure sp_processar_folha no banco de dados.
    """
    conn = obter_conexao()
    cursor = conn.cursor()
    try:
        # Executa procedure criada na etapa 2
        cursor.execute("""
            CALL sp_processar_folha(%s, %s, %s, %s, %s, %s, %s);
        """, (matricula, competencia, salario_base, adicionais, descontos, encargos, dados_bancarios))
        
        # Confirma a transação
        conn.commit()
        return True, "Folha processada com sucesso!"
    except Exception as e:
        # Em caso de erro:
        conn.rollback()
        return False, f"Erro ao processar: {e}"
    finally:
        cursor.close()
        conn.close()

def relatorio_gastos_por_competencia(competencia):
    """
    Busca os dados consolidados da folha para uma competência específica.
    """
    conn = obter_conexao()
    cursor = conn.cursor()
    
    
    cursor.execute("""
        SELECT s.matricula, s.nome, f.valor_bruto, f.valor_liquido 
        FROM folha_pagamento f
        JOIN servidor s ON f.matricula = s.matricula
        WHERE f.competencia = %s;
    """, (competencia,))
    
    resultados = cursor.fetchall()
    cursor.close()
    conn.close()
    return resultados