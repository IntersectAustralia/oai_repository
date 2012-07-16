include OAI::Provider
class ARWrapperModel < OAI::Provider::Model

  def initialize(options={})
    @timestamp_field = options.delete(:timestamp_field) || 'updated_at'
    @limit = options.delete(:limit)
    @sets_map = options.delete(:sets)
    @oai_dc_mapping = {}

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
    record_end(:asc)
  end

  def latest
    record_end(:desc)
  end

  # selector can be id or :all
  def find(selector, options={})
    token = nil
    if options[:resumption_token]
      raise OAI::ResumptionTokenException.new unless @limit
      token = ResumptionToken.parse(options[:resumption_token])
    end

    from   = token ? token.from   : options[:from]
    to     = token ? token.until  : options[:until]
    last   = token ? token.last   : 0
    prefix = token ? token.prefix : options[:metadata_prefix]
    set    = token ? token.set    : options[:set]

    conditions = sql_conditions(:from => from, :until => to)
    record_rows = get_record_rows(get_models(set), conditions)

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
    # This is terribly intensive :-(
    records.each do |record|
      obj = Object.const_get(record["type"]).find(record["id"])
      return obj if obj.oai_dc_identifier.eql?(id)
    end
    raise OAI::IdException.new
  end

  def get_paged_records(record_rows, options)

    if record_rows.size < options[:last]
      raise OAI::ResumptionTokenException.new
    end

    list = get_record_objects(record_rows[options[:last], @limit])

    if list.size < @limit
      list
    else
      options[:last] += @limit
      PartialResult.new(list, ResumptionToken.new(options))
    end
  end

  def sql_conditions(opts)
    from = Time.parse(opts[:from].to_s).localtime
    to   = Time.parse(opts[:until].to_s).localtime.to_s
    return "#{timestamp_field} >= #{ActiveRecord::Base.sanitize(from)} AND #{timestamp_field} <= #{ActiveRecord::Base.sanitize(to)}"
  end

  def get_models(set)
    models =
      if set.nil?
        @sets_map.map{|s| s[:model]}
      else
        @sets_map.select{|s| s[:spec] == set}.map{|s| s[:model]}
      end

    if models.empty?
      raise OAI::NoMatchException.new
    end
    models
  end

  def get_record_rows(models, conditions)
    record_sql = models.map do |m|
      "select id, '#{m.name}' as type, #{timestamp_field} from #{m.table_name} where #{conditions}"
    end.join(" UNION ")

    sorted_list_sql = "select t.id as id, t.type as type, t.updated_at as updated_at from (#{record_sql}) t order by t.updated_at desc"
    records = ActiveRecord::Base.connection.execute(sorted_list_sql).to_a
  end

  def get_record_objects(records)
    records.map do |record|
      Object.const_get(record["type"]).find(record["id"])
    end
  end

  def record_end(order)
    record = nil
    @sets_map.each do |s|
      r = s[:model].first(:order => "#{@timestamp_field} #{order.to_s}")
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

