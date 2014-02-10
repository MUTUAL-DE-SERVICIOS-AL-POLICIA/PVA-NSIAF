module VersionLog
  def register_log(event)
    data = {
      item_type: self.class.name,
      item_id: self.id,
      whodunnit: PaperTrail.whodunnit,
      event: event
    }
    PaperTrail::Version.create! merge_metadata(data)
  end
end
