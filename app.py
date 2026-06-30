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
    print("\n" + "="*40)
    print(" Servidores em uma Lotação ")
    print("="*40)

    lotacao = input("Digite a sigla da lotação: ")

    dados = database.servidores_por_lotacao(lotacao)

    if not dados:
        print("\n[AVISO] Nenhum servidor encontrado nessa lotação.")
    else:
        print("\n" + "-" * 125)
        print(f"{'Matrícula':<10} | {'Nome':<25} | {'Tipo':<10} | {'E-mail':<30} | {'Telefone':<15} | {'Situação':<10}")
        print("-" * 125)

        for matricula, nome, email, telefone, situacao, tipo in dados:
            print(f"{matricula:<10} | {nome:<25} | {tipo:<10} | {email:<30} | {telefone:<15} | {situacao:<10}")

        print("-" * 125)

    input("\nPressione ENTER para voltar ao menu principal...")

def liquido_por_departamento():
    print("\n" + "="*60)
    print(" Líquido por Servidor e Departamento (por competência) ")
    print("="*60)

    comp = input("Digite a Competência (AAAA-MM-DD): ")

    dados = database.liquido_por_departamento(comp)

    if not dados:
        print("\n[AVISO] Nenhuma folha encontrada para esta competência.")
    else:
        print("\n" + "-" * 75)
        print(f"{'Servidor':<25} | {'Departamento':<35} | {'Líquido (R$)':<12}")
        print("-" * 75)

        for nome, departamento, liquido in dados:
            print(f"{nome:<25} | {departamento:<35} | {liquido:<12.2f}")

        print("-" * 75)

    input("\nPressione ENTER para voltar ao menu principal...")

def servidores_por_cargo_menu():

    print("\n" + "="*40)
    print(" Servidores por Cargo ")
    print("="*40)

    cargo = int(input("Digite o ID do cargo: "))


    dados = database.servidores_por_cargo(cargo)


    if not dados:
        print("\n[AVISO] Nenhum servidor encontrado para esse cargo.")

    else:

        print("\n" + "-"*60)
        print(
            f"{'Matrícula':<12} | {'Nome':<30} | {'Cargo'}"
        )

        print("-"*60)

        for matricula, nome, cargo_nome in dados:

            print(
                f"{matricula:<12} | {nome:<30} | {cargo_nome}"
            )

        print("-"*60)


    input("\nPressione ENTER para voltar ao menu...")

def main():
    while True:
        print("\n" + "="*40)
        print(" SGBD - Gestão de Instituição de Ensino ")
        print("="*40)
        print("1. Processar Folha de Pagamento")
        print("2. Consulta de Folhas")
        print("3. Ver Servidores por Lotacao")
        print("4. Liquido por Departamento (competencia)")
        print("5. Servidores por Cargo")
        print("0. Sair do Sistema")
        print("="*40)
        
        opcao = input("Escolha uma opção: ")
        
        if opcao == '1':
            processar_folha()
        elif opcao == '2':
            menu_relatorio_folha()
        elif opcao == '3':
            funcionalidade3()
            
        elif opcao == '4':
            liquido_por_departamento()
        elif opcao == '5':
            servidores_por_cargo_menu()
        elif opcao == '0':
            print("\nEncerrando o sistema...")
            break
        else:
            print("\n[ERRO] Opção inválida. Tente novamente.")

if __name__ == "__main__":
    main()