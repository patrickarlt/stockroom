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
    self.items.sold_in_month(year, month).sum(:sold_for)
  end

  def num_sales_for_month year, month
    self.items.sold_in_month(year, month).length
  end

  def net_sales_this_month
    self.items.sold_this_month.inject(0) do |sum, sale|
      sum + sale.net_profit
    end
  end
  
  def net_sales_for_month year, month
    self.items.sold_in_month(year, month).inject(0) do |sum, sale|
      sum + sale.net_profit
    end
  end

  def profit_this_month
    self.net_sales_this_month - self.rent
  end

  def profit_for_month year, month
    self.net_sales_for_month(year, month) - self.rent
  end

  def estimated_check_this_month
    sales_minus_fees = self.items.sold_this_month.inject(0) do |sum, sale|
      sum + (sale.sold_for - sale.fees)
    end
    sales_minus_fees - self.rent
  end

  def estimated_check_for_month year, month
    sales_minus_fees = self.items.sold_in_month(year, month).inject(0) do |sum, sale|
      sum + (sale.sold_for - sale.fees)
    end
    sales_minus_fees - self.rent
  end

end