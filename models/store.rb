class Store

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :address, type: String
  field :rent, type: Float
  field :commission, type: Float
  field :credit_card_fee, type: Float

  has_many :items
  belongs_to :account
  
  def total_sales_this_month
    self.items.sold_this_month.sum(:sold_for)
  end
  
  def num_sales_this_month
    self.items.sold_this_month.length
  end

  def total_sales_for_month year, month
    self.items.sold_in_month.sum(:sold_for)
  end

  def num_sales_for_month year, month
    self.items.sold_in_month.length
  end

  def net_sales_this_month
    self.items.sold_this_month.inject(0) do |sum, sale|
      sum + sale.net_profit
    end
  end

end