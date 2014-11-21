class NoteEntry < ActiveRecord::Base
  belongs_to :supplier
  has_many :entry_subarticles
end
