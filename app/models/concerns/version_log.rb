module VersionLog
  extend ActiveSupport::Concern

  module ClassMethods
    def register_log(event)
      data = {
        item_type: self.name,
        item_id: nil,
        whodunnit: PaperTrail.whodunnit,
        event: event
      }
      PaperTrail::Version.create! self.new.set_merge_metadata(data)
    end
  end

  def register_log(event)
    data = {
      item_type: self.class.name,
      item_id: self.id,
      whodunnit: PaperTrail.whodunnit,
      event: event
    }
    PaperTrail::Version.create! merge_metadata(data)
  end

  def set_merge_metadata(data)
    merge_metadata(data)
  end
end
