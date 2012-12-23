class Application < Sinatra::Base

  before do
    add_js "application"
    add_css "screen"
  end

  get '/' do
    redirect '/'
  end

  get '/login' do
    title "Login"
    erb :"login"
  end

  post '/login/?' do
    user = Account.where({ email: params[:email] }).first
    if !user.nil? && user.authenticates?(params[:password])
      session[:user_id] = user[:_id]
      redirect "/dashboard"
    else 
      flash[:error] = "There was an error check your email and password."
      redirect '/login'
    end
  end

  get '/signup' do
    erb :"signup"
  end

  post '/signup' do
    account = Account.new({
      password: params[:password],
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email]
    })

    store = account.stores.new({
      name: params[:store][:name],
      rent: params[:store][:rent],
      commission: params[:store][:commission].to_f/100,
      credit_card_fee: params[:store][:credit_card_fee].to_f/100
    })
    
    if store.valid? && account.valid?
      store.save()
      account.save()
    else
      flash[:error] = "Invalid Input"
      redirect "/signup"
    end

    if account.persisted? && store.persisted?
      flash[:success] = "Account created, You may now login."
      redirect "/login"
    else
      flash[:error] = "There was a problem creating your account."
      redirect "/signup"
    end

  end

  get '/logout' do
    session.clear
    erb :'logout'
  end

  get '/dashboard' do
    require_session
    title "This Month"

    @store = current_user.stores[0]
    net_sales = @store.net_sales_this_month
    gross_sales = @store.total_sales_this_month

    # Item List
    @unsold_items = @store.items.where(sold: false)
    @sold_this_month = @store.items.sold_this_month
    
    # Metrics
    @profit_this_month = net_sales.round(2) - @store.rent
    @items_sold = @store.num_sales_this_month
    @gross_sales = gross_sales
    
    # Estimated Profit
    days_in_month = Time.days_in_month(Date.today.month, Date.today.year)
    days_passed_this_month = Date.today.day
    days_left_in_month = days_in_month - Date.today.day
    profit_per_day_so_far = days_passed_this_month / net_sales
    @estimated_profit = (profit_per_day_so_far * days_left_in_month) + net_sales - @store.rent
    
    erb :index
  end

end