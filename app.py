import database

def processar_folha():
    print("\n" + "="*30)
    print(" Lançamento de Folha de Pagamento ")
    print("="*30)
    
    try:
        mat = int(input("Matrícula: "))
        comp = input("Competência (AAAA-MM-DD): ")
        base = float(input("Salário Base (R$): "))
        add = float(input("Adicionais (R$): "))
        desc = float(input("Descontos (R$): "))
        enc = float(input("Encargos (R$): "))
        banco = input("Dados Bancários: ")
        
        sucesso, msg = database.lancar_folha(mat, comp, base, add, desc, enc, banco)
        if sucesso:
            print(f"\n[SUCESSO] {msg}")
        else:
            print(f"\n[ERRO BANCO DE DADOS] {msg}")
    except ValueError:
        print("\n[ERRO] Por favor, digite valores numéricos válidos.")
    
    input("\nPressione ENTER para voltar ao menu principal...")



def menu_relatorio_folha():
    print("\n" + "="*40)
    print(" Relatório Gerencial por Competência ")
    print("="*40)
    
    comp = input("Digite a Competência (AAAA-MM-DD): ")
    
    
    dados = database.relatorio_gastos_por_competencia(comp)
    
    if not dados:
        print("\n[AVISO] Nenhum registro encontrado para esta competência.")
    else:
        
        print("\n" + "-" * 70)
        print(f"{'Matrícula':<12} | {'Nome do Servidor':<25} | {'Bruto (R$)':<10} | {'Líquido (R$)':<10}")
        print("-" * 70)
        
        # Itera sobre a lista de tuplas retornada pelo banco
        for linha in dados:
            mat = linha[0]
            nome = linha[1]
            bruto = linha[2]
            liquido = linha[3]
            print(f"{mat:<12} | {nome:<25} | {bruto:<10.2f} | {liquido:<10.2f}")
        
        print("-" * 70)
        
    input("\nPressione ENTER para voltar ao menu principal...")


def funcionalidade3():
    # para  funcionalidade do próximo 
    pass

def main():
    while True:
        print("\n" + "="*40)
        print(" SGBD - Gestão de Instituição de Ensino ")
        print("="*40)
        print("1. Processar Folha de Pagamento")
        print("2. Consulta de Folhas")
        print("3. Funcionalidade 3")
        print("4. Funcionalidade 4")
        print("0. Sair do Sistema")
        print("="*40)
        
        opcao = input("Escolha uma opção: ")
        
        if opcao == '1':
            processar_folha()
        elif opcao == '2':
            menu_relatorio_folha()
        elif opcao == '3':
            #chamar funcionalidade 3 aq
            pass
        elif opcao == '4':
            pass
        elif opcao == '0':
            print("\nEncerrando o sistema...")
            break
        else:
            print("\n[ERRO] Opção inválida. Tente novamente.")

if __name__ == "__main__":
    main()