include OAI::Provider
class ARWrapperModel < OAI::Provider::Model

  def initialize(options={})
    @timestamp_field = options.delete(:timestamp_field) || 'updated_at'
    @limit = options.delete(:limit)
    @models = options.delete(:models)
    @sets_map = options.delete(:sets) || []
    @oai_dc_mapping = {}

    if @models.nil? or @models.empty?
      raise "models configuration value is required and must be non-empty"
    end

    unless options.empty?
      raise ArgumentError.new(
        "Unsupported options [#{options.keys.join(', ')}]"
      )
    end

  end

  def map_oai_dc
    if @oai_dc_mapping.empty?
      dc = OAI::Provider::Metadata::DublinCore.instance
      dc.fields.map do |field|
        @oai_dc_mapping[field.to_sym] = "oai_dc_#{field}".to_sym
      end
    end
    @oai_dc_mapping
  end

  def sets
    @sets_map.map {|set_obj|
      OAI::Set.new(
        {
          name: set_obj[:name],
          spec: set_obj[:spec],
          description: set_obj[:description]
        }
      )
    }
  end

  def earliest
    first_record_date(:asc)
  end

  def latest
    first_record_date(:desc)
  end

  # selector can be id or :all
  def find(selector, options={})
    token = nil
    if options[:resumption_token]
      raise OAI::ResumptionTokenException.new unless @limit
      token = ResumptionToken.parse(options[:resumption_token])
    end

    from   = token ? token.from.utc  : options[:from]
    to     = token ? token.until.utc : options[:until]
    last   = token ? token.last   : 0
    set    = token ? token.set    : options[:set]
    prefix = token ? token.prefix : options[:metadata_prefix]

    record_rows = get_record_rows(set, :from => from, :until => to)

    return get_specific_record(record_rows, selector) if selector != :all

    if @limit and record_rows.size > @limit
      get_paged_records(record_rows, :from => from, :until => to, :set => set, :last => last, :metadata_prefix => prefix)
    else
      get_record_objects(record_rows)
    end
  end

  private

  def get_specific_record(records, id)
    # TODO: optimise somehow
    # This scans all records :-(
    records.each do |record|
      obj = Object.const_get(record["type"]).find(record["id"])
      return obj if obj.oai_dc_identifier.eql?(id)
    end
    raise OAI::IdException.new
  end

  def get_paged_records(record_rows, options)

    last = options[:last]
    if record_rows.size < last
      raise OAI::ResumptionTokenException.new
    end

    list = get_record_objects(record_rows[last, @limit])

    last += @limit
    if last >= record_rows.size
      list
    else
      options[:last] = last
      PartialResult.new(list, ResumptionToken.new(options))
    end
  end

  def get_record_rows(set, options={})
    union = []

    from = options[:from]
    # DateTime has microsecond precision, but we're parsing in dates with only
    # second precision. In this case the microsecond value defaults to zero.
    # Since some (most) of the records at the boundaries of a range will have
    # non-zero microseconds (where the timestamp database field type has this 
    # level of resolution), the range needs to be adjusted to cover this.
    #
    # E.g. if the range is 2012-01-01 12:00:00 to 2012-01-01 12:30:00 inclusive
    # a record with timestamp 2012-01-01 12:30:00.000001 is probably expected
    # to fall in the range.
    #
    # To do this we extend the upper bound by one second and then make this
    # upper bound exclusive.
    to   = options[:until] + 1.second

    record_sql = @models.map do |m|
      if m.respond_to? (:published)
        res = m.select("id, '#{m.name}' as type, #{timestamp_field}").where("#{timestamp_field} >= ? and #{timestamp_field} < ?", from.to_s(:db), to.to_s(:db)){|p| p if p.published}
      else
        res = m.select("id, '#{m.name}' as type, #{timestamp_field}").where("#{timestamp_field} >= ? and #{timestamp_field} < ?", from.to_s(:db), to.to_s(:db))
      end

      if !(res.empty? or set.nil?)
        res.select!{|record| record.sets.map(&:spec).include?(set)}
      end
      union += res unless res.empty?
    end

    raise OAI::NoMatchException.new if union.empty?

    union.sort! {|a,b| b.updated_at <=> a.updated_at}
  end

  def get_record_objects(records)
    records.map do |record|
      Object.const_get(record["type"]).find(record["id"])
    end
  end

  def first_record_date(order)
    record = nil
    @models.each do |model|
      r = model.first(:order => "#{@timestamp_field} #{order.to_s}")
      next if r.nil?

      if record.nil?
        record = r
      elsif order == :asc and r.send(@timestamp_field) < record.send(@timestamp_field)
        record = r
      elsif order == :desc and r.send(@timestamp_field) > record.send(@timestamp_field)
        record = r
      end
    end

    raise OAI::NoMatchException if record.nil?

    record.send(@timestamp_field)
  end

end

