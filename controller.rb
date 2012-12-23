class Application < Sinatra::Base

  before do
    add_js "application"
    add_css "screen"
  end

  get '/' do
    if logged_in?
      redirect '/dashboard'
    else
      redirect '/login'
    end
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
    title "Dashboard"

    @store = current_user.stores[0]
    net_sales = @store.net_sales_this_month
    gross_sales = @store.total_sales_this_month || 0

    # Item List
    @unsold_items = @store.items.where(sold: false)
    @sold_this_month = @store.items.sold_this_month
    
    # Metrics
    @profit_this_month = net_sales.round(2) - @store.rent
    @items_sold = @store.num_sales_this_month
    @gross_sales = gross_sales
    
    # Estimated Profit
    binding.pry
    profit_per_day_so_far = (net_sales.zero?) ? 0 : Date.today.day / net_sales
    @estimated_profit = (profit_per_day_so_far * days_left_this_month) + net_sales - @store.rent
    
    erb :index
  end

  get "/history" do
    require_session
    title "Sales History"
    @store = current_user.stores[0]
    months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].reverse!
    @history = []
    [2013, 2012].each do |year|
      summary = {
        year: year,
        months: []
      }
      months.each do |month|
        summary[:months].push({
          month: Date::MONTHNAMES[month],
          num: month,
          profit: @store.profit_for_month(year, month),
          total_sales: @store.total_sales_for_month(year, month),
          num_sales: @store.num_sales_for_month(year, month)
        })
      end
      @history.push(summary)
    end
    erb :"history/index"
  end

  get "/history/:year/:month" do
    require_session
    title "Sales History"

    @store = current_user.stores[0]
    net_sales = @store.net_sales_for_month(params[:year].to_i, params[:month].to_i)
    gross_sales = @store.total_sales_for_month(params[:year].to_i, params[:month].to_i)

    @sold_this_month = @store.items.sold_in_month(params[:year].to_i, params[:month].to_i)
    
    # Metrics
    @profit_this_month = net_sales.round(2) - @store.rent
    @items_sold = @store.num_sales_this_month
    @gross_sales = gross_sales
    erb :"history/view"
  end

end