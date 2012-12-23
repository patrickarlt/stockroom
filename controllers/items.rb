class Items < Application

  get "/new" do
    require_session
    title "New Item"
    erb :"items/form"
  end

  post "/new" do
    require_session
    item = current_user.stores[0].items.new params
    #redirect "/session/new" + (params[:page] ? "?page=#{Rack::Utils.escape params[:page]}" : "")

    if item.valid?
      item.save()
    else 
      flash[:error] = "Item Details Missing"
      redirect "/items/new"
    end
    
    if item.persisted?  
      flash[:success] = "Item Added"
      redirect "/dashboard"
    else
      flash[:error] = "Error Saving Item"
      redirect "/items/new"
    end
  end

  get "/delete/:id" do
    item = Item.find(params[:id])
    item.destroy
    if(item.destroyed?)
      flash[:success] = "Item deleted successfully!";
    else 
      flash[:error] = "There was an error deleting your item.";
    end
    redirect "/dashboard"
  end

  post "/sell/:id" do
    require_session
    item = Item.find(params[:id])
    begin
      item.update_attributes({
        sold_for: params[:sold_for],
        sold_on: params[:sold_on],
        sold: true
      })
      flash[:success] = "Item marked as sold!";
    rescue Exception => e
      flash[:error] = "There was an error deleting your item.";
    end
    redirect "/dashboard"
  end

  get "/edit/:id" do
    require_session
    title "Edit Item"
    @item = Item.find(params[:id])
    erb :"items/form"
  end

end