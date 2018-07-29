require 'active_hash'
require 'oath/lockdown/adapters/lockable'

class User < ActiveHash::Base
  include ActiveModel::Validations

  # attr_accessor :lock_expires_at, :failed_logins_count
  field :locked_at
  field :failed_logins_count
  attr_accessor :email, :password_digest, :password
  attr_accessor :remember_token, :remember_token_created_at
  attr_accessor :current_sign_in_at, :current_sign_in_ip, :last_sign_in_at, :last_sign_in_ip, :sign_in_count
  # field :current_sign_in_at
  # field :current_sign_in_ip
  # field :last_sign_in_at
  # field :last_sign_in_ip
  # field :sign_in_count
  validates :email, presence: true

  def self.find_by(params)
    where(params).first
  end

  def update_attribute(name, value)
    name = name.to_s
    send("#{name}=", value)
    save
  end

  # VERY hamstrung glue method to satisfy tests
  def update_attributes(attributes)
    attributes.each do |attribute, value|
      update_attribute attribute, value
    end
  end
end
