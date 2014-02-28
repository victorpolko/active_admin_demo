class User < ActiveRecord::Base
  has_one  :head, dependent: :destroy

  scope :fresh, -> { where(state: 0) }
  scope :dead,  -> { where(state: 1) }

  validates :name, :email, presence: true

  attr_accessor :iq
end
