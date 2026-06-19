# Meu Jardim 🌿

O aplicativo Meu Jardim foi desenvolvido para solucionar a dificuldade comum de manter uma rotina consistente de cuidados com suas plantas. O sistema funciona como um gerenciador pessoal, permitindo que o usuário cadastre cada espécie presente em sua residência, definindo um intervalo específico de dias para a rega de cada uma. Além de armazenar essas informações, o app gerencia o ciclo de vida das plantas, permitindo o acompanhamento do histórico de regas realizadas e o cálculo automático de quando a próxima hidratação será necessária. Para garantir a segurança e a personalização, o sistema exige uma autenticação via login e senha, assegurando que cada usuário acesse apenas o seu próprio jardim.
Internamente, o app utiliza um banco de dados NoSQL (Hive) para garantir um desempenho rápido e eficiente na persistência das informações, mesmo quando o dispositivo está offline. Com uma interface intuitiva, o usuário pode realizar todas as operações de CRUD, mantendo o controle total sobre a adição, edição, remoção e monitoramento de suas plantas, garantindo que nenhum exemplar fique sem a devida atenção necessária para o seu crescimento saudável.

## Funcionalidades

- Cadastro e Autenticação de usuários.
- Gestão (CRUD) de plantas (Nome, Espécie, Frequência de Rega).
- Registro de histórico de regas.
- Monitor de Saúde: Identificação automática de plantas com regas atrasadas.

## Tecnologias Utilizadas

- **Flutter**: Framework de interface.
- **Hive**: Banco de dados NoSQL para persistência local.
- **Shared Preferences**: Gerenciamento de sessão de usuário.

## Como Rodar o Projeto

1. Clone este repositório: `git clone https://github.com/BarbaraMercez/meu_jardim.git`
2. Acesse a pasta do projeto.
3. Certifique-se de ter o Flutter (versão 3.x ou superior) instalado.
4. Execute `flutter pub get` para instalar as dependências.
5. Para rodar no navegador (Web), execute:
   ```bash
   flutter run -d chrome
   ```
