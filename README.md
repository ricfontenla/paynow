# README

## PROJETO PAYNOW - TREINADEV 06

### Sobre o projeto
Uma escola de programação, a CodePlay, decidiu lançar uma plataforma de cursos online de
programação. Você já está trabalhando nesse projeto e agora vamos começar uma nova etapa:
uma ferramenta de pagamentos capaz de configurar os meios de pagamentos e registrar as
cobranças referentes a cada venda de curso na CodePlay. O objetivo deste projeto é construir
o mínimo produto viável (MVP) dessa plataforma de pagamentos.
Na plataforma de pagamentos temos dois perfis de usuários: os administradores da plataforma
e os donos de negócios que querem vender seus produtos por meio da plataforma, como as
pessoas da CodePlay, por exemplo. Os administradores devem cadastrar os meios de
pagamento disponíveis, como boletos bancários, cartões de crédito, PIX etc, especificando
detalhes de cada formato. Administradores também podem consultar os clientes da plataforma,
consultar e avaliar solicitações de reembolso, bloquear compras por suspeita de fraudes etc.
Já os donos de negócios devem ser capazes de cadastrar suas empresas e ativar uma conta
escolhendo quais meios de pagamento serão utilizados. Devem ser cadastrados também os
planos disponíveis para venda, incluindo seus valores e condições de desconto de acordo com
o meio de pagamento. E a cada nova venda realizada, devem ser armazenados dados do
cliente, do produto selecionado e do meio de pagamento escolhido. Um recibo deve ser emitido
para cada pagamento e esse recibo deve ser acessível para os clientes finais, alunos da
CodePlay no nosso contexto.

### Configurações
* Ruby 3.0.1
* Rails 6.1.3.2
* Testes:
  - Rspec
  - Capybara
  - Shoulda Matchers

### Como iniciar o projeto 
* Clone o projeto para sua máquina, e dentro da pasta do projeto, rode o comando ```bin/setup``` em seu terminal
* Você pode utilizar o comando ```rails s``` para ver a aplicação funcionando localmente no endereço ```http://localhost:3000```


### Testes
* Para executar os testes, utilize o comando ```rspec```

## Informações deste projeto
### Administradores
* Administradores não possuem página de registro e devem ser registrados pelo console e **precisam** possuir um e-mail com o dominio @paynow.com.br.
* Login de administradores deve ser feito acessando new_admin_session_path: ```http://localhost:3000/admins/sign_in```

### Usuários
* Usuários possuem roles de ```customer_admin``` ou ```user``` e não podem ser registrar com emails dos dominios: **Google**, **Yahoo**, **Hotmail** e **Paynow**
# Populando o banco de dados
* Para popular o banco com informaçoes pré definidas, use o comando ```rails db:seed```
* Administrador gerado: email: ```ademir@paynow.com.br```, senha: ```123456```
* Usuario administrador de empresa cliente gerado: email: ```john_doe@codeplay.com.br```, senha: ```123456```
* Usuario funcionario de empresa cliente gerado: email: ```john_doe2@codeplay.com.br```, password: ```123456```

## API
### Registro de cliente final
#### __post '/api/v1/final_customers'__
* o endpoint para criação e associação de um cliente final e uma empresa cliente PayNow, espera receber os seguintes parâmetros:
```
{
	'final_customer':
	{
		'name': 'Nome do cliente',
		'cpf': 'Apenas números e com 11 caractéres'
	},
	'company_token': 'Token alfanumérido da empresa já cadastrada'
}
```
#### Possíveis Respostas
* HTTP Status: 201 - Cliente registrado com sucesso
Exemplo:
```
{
	name: "Fulano Sicrano",
	cpf: "98765432101",
	token: "txrzoRCiGngB8Fr6zgKB"
}
```
* HTTP Status: 412 - Parâmetros inválidos para criação de cliente (parametros em branco ou não respeitando as validações)
Exemplo:
```
{
	message: 'Parâmetros Inválidos'
}
```
* HTTP Status: 412 - Token Inválido (da empresa)
Exemplo:
```
{
	message: 'Token Inválido'
}
```
#### __post '/api/v1/orders'__
* o endpoint para criação e associação de um cliente final e uma empresa cliente PayNow, espera receber os seguintes parâmetros:
* Para Boletos:
```
{
  order: 
  {
    company_token: Token da empresa cliente, 
    product_token: Token do produto a ser vendido, 
    final_customer_token: Token do cliente final,
    choosen_payment: "boleto",
    adress: Endereço a ser enviado o boleto
  }
}
```
* Para Cartão:
```
{
  order: 
  {
    company_token: Token da empresa cliente, 
    product_token: Token do produto a ser vendido, 
    final_customer_token: Token do cliente final,
    choosen_payment: "card",
    card_number: Numero do cartão, com 16 dígitos, apenas numeros
    printed_name: Nume impresso no cartão,
    verification_code: Código de segurança, com 3 digitos, apenas numeros
  }
}
```
* Para PIX:
```
{
  order: 
  {
    company_token: Token da empresa cliente, 
    product_token: Token do produto a ser vendido, 
    final_customer_token: Token do cliente final,
    choosen_payment: "pix",
  }
}
```
#### Possíveis Respostas
* HTTP Status: 201 - Compra registrada com sucesso
Exemplo boleto:
```
{
	token: "dwx5UBuwxZgqaN9hawgo", 
	status: "pendente", 
	original_price: "100.0",
	final_price: "95.0", 
	choosen_payment: "boleto", 
	adress": "fulano_sicrano@gmail.com", 
	company: { token: "y3vxtTPta2ykM64o2PL9" },
	product: { token: "o49aXMmnTVrET2GEFHfM" },
	final_customer: { token: "CAjaMeHyKD3P74jWyE9E }
}
```
Exemplo cartão:
```
{
	token: "N3zs82YGaX6hyeXfFxVP",
	status: "pendente", 
	original_price: "100.0", 
	final_price: "100.0", 
	choosen_payment: "card", 
	card_number: "9876543210123456", 
	printed_name: "Fulano Sicrano", 
	verification_code: "000", 
	company: { token: "LP4s3FwvntrGfm6UokkL" }, 
	product: { token: "1JawCh5m2qiYEkn5ucav" },
	final_customer: { token: "tZ5qW2jR78ZQpKwUextV" }
}
```
Exemplo PIX:
```
{
	token: "GtLsEJpmFYkRfSXWTu2r",
	status: "pendente", 
	original_price: "100.0", 
	final_price: "90.0", 
	choosen_payment: "pix", 
	company: { token: "uZGAM86JoyHmBv3WdnSg" },
	product: { token: "mPZEmrARA7fgLAL3LzPr" },
	final_customer: { token: "3nbAU317qitpUaXMEgEm"}
}
```
* HTTP Status: 412 - Parâmetros inválidos para criação da compra (parametros em branco ou não respeitando validações)
Exemplo:
```
{
	message: 'Parâmetros Inválidos'
}
```
* HTTP Status: 412 - Token Inválido (da empresa, cliente ou produto)
Exemplo:
```
{
	message: 'Token Inválido'
}
```