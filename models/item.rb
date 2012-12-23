class Item

  Categories = [
    "clothes",
    "kitchen",
    "paper",
    "jewelery",
    "accesories",
    "furniture",
    "decor",
    "holiday"
  ]

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination

  field :name, type: String
  field :description, type: String

  field :category, type: String
  
  field :sold, type: Boolean, default: false
  
  field :item_id, type: String

  field :in_store, type: Date
  
  field :bought_at, type: String
  field :bought_on, type: Date
  field :bought_for, type: Float

  field :priced_for, type: Float

  field :sold_on, type: Date
  field :sold_for, type: Float

  scope :sold_before, ->(date) {where(:created_at.lte => date)}
  scope :sold_after, ->(date) {where(:created_at.gte => date)}
  
  scope :sold_in_month, ->(year, month) {
    puts ''
    puts year.inspect
    puts month.inspect
    puts ''
    time = Date.new(year, month)
    where(sold: true, :sold_on.gte => time.beginning_of_month, :sold_on.lte => time.end_of_month)
  }
  
  scope :sold_this_month, ->() {
    where(sold: true, :sold_on.gte => Date.today.beginning_of_month, :sold_on.lte => Date.today.end_of_month)
  }

  belongs_to :store

  # profit (in dollars) before alleys cut
  def gross_profit
    sell_price = self.sold_for || self.priced_for
    sell_price - self.bought_for
  end
  
  # profit (in dollars) after the alleys cut
  def net_profit
    sell_price = self.sold_for || self.priced_for
    sell_price - self.bought_for - self.fees
  end

  # Fees (in dollars) that the alley has taken out of this item
  def fees
    sell_price = self.sold_for || self.priced_for
    (sell_price * self.store.commission) + (sell_price * self.store.credit_card_fee)
  end

  # How much the item has been marked up for (as a percent)
  def markup
    # ((self.bought_for.to_f / self.priced_for.to_f) * 100).to_i
    self.priced_for.to_f / self.bought_for.to_f
  end

  # How much the item has been marked down for (in dollars)
  def markdown
    sell_price = self.sold_for || 0
    self.priced_for - sell_price
  end

end