require 'active_hash'
require 'oath/ironclad/adapters/brute_force'

class User < ActiveHash::Base
  include ActiveModel::Validations

  # attr_accessor :lock_expires_at, :failed_logins_count
  field :locked_at
  field :failed_logins_count
  attr_accessor :email, :password_digest, :password
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
