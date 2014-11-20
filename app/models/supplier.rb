class Supplier < ActiveRecord::Base
  has_many :note_entries
end
