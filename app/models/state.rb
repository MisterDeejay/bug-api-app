class State < ApplicationRecord
  belongs_to :bug, touch: true

  validates_presence_of :device, :os, :memory, :storage
end
