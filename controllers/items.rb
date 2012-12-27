class Items < Application

  get "/new" do
    require_session
    title "New Item"
    erb :"items/form"
  end

  post "/new" do
    require_session
    
    item = current_user.stores[0].items.new({
      name: params[:name],
      item_id: params[:item_id],
      description: params[:description],
      bought_on: params[:bought_on],
      bought_at: params[:bought_at],
      bought_for: params[:bought_for].gsub("$", "").to_f,
      priced_for: params[:priced_for].gsub("$", "").to_f,
      in_store: params[:in_store],
      category: params[:category]
    })

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
        sold_for: params[:sold_for].gsub("$", "").to_f,
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

  post "/edit/:id" do
    require_session
    item = Item.find(params[:id])
    begin
      item.update_attributes!({
        name: params[:name],
        item_id: params[:item_id],
        description: params[:description],
        bought_on: params[:bought_on],
        bought_at: params[:bought_at],
        bought_for: params[:bought_for].gsub("$", "").to_f,
        priced_for: params[:priced_for].gsub("$", "").to_f,
        in_store: params[:in_store],
        category: params[:category]
      })
      flash[:success] = "Item Updated"
    rescue Exception => e
      flash[:error] = "There was an error deleting your item.";
    end
    redirect "/dashboard"
  end

end