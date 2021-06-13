class Api::V1::FinalCustomersController < ActionController::API
  def create
    @company = Company.find_by!(token: params[:company_token])
    @final_customer = FinalCustomer.find_by(cpf: final_customer_params[:cpf])
    if @final_customer
      @company.company_final_customers.create!(final_customer: @final_customer)
    else
      @final_customer = @company.final_customers.create!(final_customer_params)
    end
    render json: @final_customer.as_json(except: [:id, :created_at, :updated_at]), status: 201
  rescue ActiveRecord::RecordInvalid
    render json: { message: 'Parâmetros Inválidos' }, status: 412
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Token Inválidos' }, status: 412
  end

  private
  
  def final_customer_params
    params.require(:final_customer).permit(:name, :cpf)
  end
end