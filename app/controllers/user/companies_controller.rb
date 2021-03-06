class User::CompaniesController < User::UserController
  before_action :authenticate_user!
  before_action :is_customer_admin?, only: %i[edit update generate_token]
  before_action :associated?, only: %i[new create]
  before_action :has_company?, only: %i[show edit update]
  before_action :set_company, only: %i[show edit update generate_token my_payment_methods]

  def show; end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    set_email_domain(@company)
    if @company.save
      current_user.customer_admin!
      set_company_id_for_user
      redirect_to user_company_path(@company.token)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @company.update(update_company_params)
      flash[:notice] = t('.success')
      redirect_to user_company_path(@company.token)
    else
      render :edit
    end
  end

  def generate_token
    @company.token = create_unique_token
    if @company.save
      flash[:notice] = t('.success')
    else
      flash[:alert] = t('.fail')
    end
    redirect_to user_company_path(@company.token)
  end

  def my_payment_methods; end

  private

  def company_params
    params.require(:company).permit(:name, :cnpj, :billing_adress, :billing_email)
  end

  def update_company_params
    params.require(:company).permit(:billing_adress, :billing_email)
  end

  def set_company
    @company = Company.find_by(token: params[:token])
  end

  def set_email_domain(company)
    company.email_domain = current_user.email.split('@').last
  end

  def set_company_id_for_user
    current_user.company = @company
    current_user.save
  end

  def associated?
    redirect_to root_path if current_user.company
  end

  def has_company?
    redirect_to root_path unless current_user.company
  end

  def create_unique_token
    new_token = SecureRandom.base58(20)
    duplicity = Company.where(token: new_token)
    create_unique_token if duplicity.any?
    new_token
  end
end
