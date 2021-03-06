require 'rails_helper'

describe 'Orders API' do
  context 'POST api/v1/orders' do
    it 'and should create a new order for boleto and associate with company and final customer' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'boleto',
          adress: 'fulano_sicrano@gmail.com'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(201)
      expect(parsed_body['token']).to eq(Order.last.token)
      expect(parsed_body['status']).to eq('pendente')
      expect(parsed_body['original_price']).to eq('100.0')
      expect(parsed_body['final_price']).to eq('95.0')
      expect(parsed_body['choosen_payment']).to eq('boleto')
      expect(parsed_body['adress']).to eq('fulano_sicrano@gmail.com')
      expect(parsed_body['company']['token']).to eq(Company.last.token)
      expect(parsed_body['product']['token']).to eq(Product.last.token)
      expect(parsed_body['final_customer']['token']).to eq(FinalCustomer.last.token)
      expect(Order.last.order_histories.count).to eq(1)
    end

    it 'and should create a new order for card and associate with company and final customer' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      card = PaymentMethod.create!(name: 'PISA',
                                   billing_fee: 5,
                                   max_fee: 250,
                                   status: true,
                                   category: 2)
      CardAccount.create!(credit_code: '9876543210ABCDEfghij',
                          company: company,
                          payment_method: card)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'card',
          card_number: '9876543210123456',
          printed_name: 'Fulano Sicrano',
          verification_code: '000'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(201)
      expect(parsed_body['token']).to eq(Order.last.token)
      expect(parsed_body['status']).to eq('pendente')
      expect(parsed_body['original_price']).to eq('100.0')
      expect(parsed_body['final_price']).to eq('100.0')
      expect(parsed_body['choosen_payment']).to eq('card')
      expect(parsed_body['card_number']).to eq('9876543210123456')
      expect(parsed_body['verification_code']).to eq('000')
      expect(parsed_body['printed_name']).to eq('Fulano Sicrano')
      expect(parsed_body['company']['token']).to eq(Company.last.token)
      expect(parsed_body['product']['token']).to eq(Product.last.token)
      expect(parsed_body['final_customer']['token']).to eq(FinalCustomer.last.token)
      expect(Order.last.order_histories.count).to eq(1)
    end

    it 'and should create a new order for pix and associate with company and final customer' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      pix = PaymentMethod.create!(name: 'PIX Banco Roxinho',
                                  billing_fee: 1,
                                  max_fee: 250,
                                  status: true,
                                  category: 3)
      PixAccount.create!(pix_key: '12345abcde67890FGHIJ',
                         bank_code: '001',
                         company: company,
                         payment_method: pix)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'pix'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(201)
      expect(parsed_body['token']).to eq(Order.last.token)
      expect(parsed_body['status']).to eq('pendente')
      expect(parsed_body['original_price']).to eq('100.0')
      expect(parsed_body['final_price']).to eq('90.0')
      expect(parsed_body['choosen_payment']).to eq('pix')
      expect(parsed_body['company']['token']).to eq(Company.last.token)
      expect(parsed_body['product']['token']).to eq(Product.last.token)
      expect(parsed_body['final_customer']['token']).to eq(FinalCustomer.last.token)
      expect(Order.last.order_histories.count).to eq(1)
    end

    it 'and company not found' do
      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: '',
          product_token: SecureRandom.base58(20).to_s,
          final_customer_token: SecureRandom.base58(20).to_s,
          choosen_payment: 'boleto',
          adress: 'fulano_sicrano@gmail.com'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Token Inválido')
    end

    it 'and product not found' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: '',
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'boleto',
          adress: 'fulano_sicrano@gmail.com'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Token Inválido')
    end

    it 'and final_customer not found' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: '',
          choosen_payment: 'boleto',
          adress: 'fulano_sicrano@gmail.com'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Token Inválido')
    end

    it 'and choose_payment cannot be blank' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: '',
          adress: 'fulano_sicrano@gmail.com'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Método de Pagamento Inválido')
    end

    it 'and adress cannot be blank for boleto' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'boleto',
          adress: ''
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Parâmetros Inválidos')
    end

    it 'and card_number, printed_name, verification_code cannot be blank for card' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      Product.create!(name: 'Curso Ruby Básico',
                      price: '100',
                      pix_discount: 10,
                      card_discount: 0,
                      boleto_discount: 5,
                      company: company)
      card = PaymentMethod.create!(name: 'PISA',
                                   billing_fee: 5,
                                   max_fee: 250,
                                   status: true,
                                   category: 2)
      CardAccount.create!(credit_code: '9876543210ABCDEfghij',
                          company: company,
                          payment_method: card)

      post '/api/v1/orders', params:
      {
        order:
        {
          company_token: company.token.to_s,
          product_token: Product.last.token.to_s,
          final_customer_token: final_customer.token.to_s,
          choosen_payment: 'card',
          card_number: '',
          printed_name: '',
          verification_code: ''
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Parâmetros Inválidos')
    end

    it 'and params cannot be blank' do
      post '/api/v1/orders', params: {}

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Parâmetros Inválidos')
    end
  end

  context 'GET api/v1/orders/:id' do
    it 'it should get order by date' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      product2 = Product.create!(name: 'Curso HTML5',
                                 price: 75,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)
      Order.create!(original_price: 75.0,
                    final_price: 75.0,
                    choosen_payment: 'card',
                    card_number: '9876543210123456',
                    verification_code: '000',
                    printed_name: 'Fulano Sicrano',
                    company: company,
                    final_customer: final_customer,
                    product: product2,
                    created_at: 1.day.ago)

      get '/api/v1/orders/', params:
      {
        company: { token: Company.last.token },
        created_at: Date.current
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(200)
      expect(parsed_body[0]['token']).to eq(Order.first.token)
      expect(parsed_body[0]['status']).to eq('pendente')
      expect(parsed_body[0]['original_price']).to eq('100.0')
      expect(parsed_body[0]['final_price']).to eq('95.0')
      expect(parsed_body[0]['choosen_payment']).to eq('boleto')
      expect(parsed_body[0]['adress']).to eq('fulano_sicrano@gmail.com')
      expect(parsed_body[0]['company']['token']).to eq(Company.first.token)
      expect(parsed_body[0]['product']['token']).to eq(Product.first.token)
      expect(parsed_body[0]['final_customer']['token']).to eq(FinalCustomer.first.token)
    end

    it 'it should get order by payment type' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      product2 = Product.create!(name: 'Curso HTML5',
                                 price: 75,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)
      Order.create!(original_price: 75.0,
                    final_price: 75.0,
                    choosen_payment: 'card',
                    card_number: '9876543210123456',
                    verification_code: '000',
                    printed_name: 'Fulano Sicrano',
                    company: company,
                    final_customer: final_customer,
                    product: product2,
                    created_at: 1.day.ago)

      get '/api/v1/orders/', params:
      {
        company: { token: Company.last.token },
        choosen_payment: 'card'
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(200)
      expect(parsed_body[0]['token']).to eq(Order.last.token)
      expect(parsed_body[0]['status']).to eq('pendente')
      expect(parsed_body[0]['original_price']).to eq('75.0')
      expect(parsed_body[0]['final_price']).to eq('75.0')
      expect(parsed_body[0]['choosen_payment']).to eq('card')
      expect(parsed_body[0]['card_number']).to eq('9876543210123456')
      expect(parsed_body[0]['printed_name']).to eq('Fulano Sicrano')
      expect(parsed_body[0]['verification_code']).to eq('000')
      expect(parsed_body[0]['company']['token']).to eq(Company.first.token)
      expect(parsed_body[0]['product']['token']).to eq(Product.last.token)
      expect(parsed_body[0]['final_customer']['token']).to eq(FinalCustomer.first.token)
    end

    it 'it should get orders by date and payment type' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      product2 = Product.create!(name: 'Curso HTML5',
                                 price: 75,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)
      Order.create!(original_price: 75.0,
                    final_price: 67.5,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product2,
                    created_at: 1.day.ago)

      get '/api/v1/orders/', params:
      {
        company: { token: Company.last.token },
        created_at: Date.current,
        choosen_payment: 'boleto'

      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(200)
      expect(parsed_body[0]['token']).to eq(Order.first.token)
      expect(parsed_body[0]['status']).to eq('pendente')
      expect(parsed_body[0]['original_price']).to eq('100.0')
      expect(parsed_body[0]['final_price']).to eq('95.0')
      expect(parsed_body[0]['choosen_payment']).to eq('boleto')
      expect(parsed_body[0]['adress']).to eq('fulano_sicrano@gmail.com')
      expect(parsed_body[0]['company']['token']).to eq(Company.first.token)
      expect(parsed_body[0]['product']['token']).to eq(Product.first.token)
      expect(parsed_body[0]['final_customer']['token']).to eq(FinalCustomer.first.token)
      expect(parsed_body).to_not include(FinalCustomer.last.token)
    end

    it 'wrong or missing company token' do
      get '/api/v1/orders/', params:
      {
        company: { token: '' },
        created_at: Date.current,
        choosen_payment: 'boleto'
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(404)
      expect(response.body).to include('Token Inválido')
    end

    it 'and no results match' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)

      get '/api/v1/orders/', params:
      {
        company: { token: company.token },
        created_at: nil,
        choosen_payment: nil
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(200)
      expect(response.body).to include('Nenhum resultado encontrado')
    end
  end

  context 'PUT /api/v1/orders/:token' do
    it 'should update status' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)

      put "/api/v1/orders/#{Order.last.token}", params:
      {
        order: {
          status: 'aprovado',
          response_code: '05 - Cobrança efetivada com sucesso'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(200)
      expect(parsed_body['status']).to eq('aprovado')
      expect(parsed_body['choosen_payment']).to eq('boleto')
      expect(parsed_body['token']).to eq(Order.last.token)
      expect(parsed_body['original_price']).to eq('100.0')
      expect(parsed_body['final_price']).to eq('95.0')
      expect(parsed_body['adress']).to eq('fulano_sicrano@gmail.com')
      expect(parsed_body['company']['token']).to eq(Company.last.token)
      expect(parsed_body['product']['token']).to eq(Product.last.token)
      expect(parsed_body['final_customer']['token']).to eq(FinalCustomer.last.token)
      expect(parsed_body['order_histories'][1]['response_code']).to eq('05 - Cobrança efetivada com sucesso')
    end

    it 'and wrong or missing order token' do
      put '/api/v1/orders/123456', params:
      {
        order: {
          status: 'aprovado',
          response_code: '05 - Cobrança efetivada com sucesso'
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(404)
      expect(response.body).to include('Token Inválido')
    end

    it 'should update status' do
      company = Company.create!(email_domain: 'codeplay.com.br',
                                cnpj: '00000000000000',
                                name: 'Codeplay Cursos SA',
                                billing_adress: 'Rua banana, numero 00 - Bairro Laranja, 00000-000',
                                billing_email: 'financas@codeplay.com.br')
      final_customer = FinalCustomer.create!(name: 'Fulano Sicrano',
                                             cpf: '54321012345')
      CompanyFinalCustomer.create!(company: company,
                                   final_customer: final_customer)
      product1 = Product.create!(name: 'Curso Ruby Básico',
                                 price: 100,
                                 pix_discount: 10,
                                 card_discount: 0,
                                 boleto_discount: 5,
                                 company: company)
      boleto = PaymentMethod.create!(name: 'Boleto do Banco Laranja',
                                     billing_fee: 2.5,
                                     max_fee: 100.0,
                                     status: true,
                                     category: :boleto)
      BoletoAccount.create!(bank_code: 479,
                            agency_number: 1234,
                            bank_account: 123_456_789,
                            company: company,
                            payment_method: boleto)
      Order.create!(original_price: 100.0,
                    final_price: 95.0,
                    choosen_payment: 'boleto',
                    adress: 'fulano_sicrano@gmail.com',
                    company: company,
                    final_customer: final_customer,
                    product: product1)

      put "/api/v1/orders/#{Order.last.token}", params:
      {
        order: {
          status: '',
          response_code: ''
        }
      }

      expect(response.content_type).to include('application/json')
      expect(response).to have_http_status(412)
      expect(response.body).to include('Parâmetros Inválidos')
    end
  end
end
