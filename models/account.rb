class Account

  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :first_name, type: String  
  field :last_name, type: String
  field :email, type: String
  field :password, type: String
  
  has_many :stores

  validates_uniqueness_of :email, message:{type:"conflict", message:"email is already taken"}
  validates_format_of :email, with: /\S+@\S+\.\S+/, message: {type:"invalid_input", message:"email is invalid"}
  validates_presence_of :password, message: {type:"required", message:"password is required"}

  before_create :hash_password

  def display_name
    if self.first_name && self.last_name
      "#{self.first_name} #{self.last_name}"
    else
      self.first_name || self.last_name || self.email || self._id
    end
  end

  def update_password password
    hash_password(password)
  end

  def authenticates? password
    db_password = BCrypt::Password.new(self.password)
    db_password == password
  end
  
  protected

  def hash_password password = nil
    password ||= self.password
    unless password.blank?
      self.password = BCrypt::Password.create(password)
    end
  end

end