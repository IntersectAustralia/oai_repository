class ARWrapperModel < OAI::Provider::Model

  def initialize(options={})
    @timestamp_field = options.delete(:timestamp_field) || 'updated_at'
    @limit = options.delete(:limit)
    @sets = options.delete(:sets)

    unless options.empty?
      raise ArgumentError.new(
        "Unsupported options [#{options.keys.join(', ')}]"
      )
    end

  end

  def map_oai_dc
    @oai_dc_mapping ||= begin
      dc = OAI::Provider::Metadata::DublinCore.instance
      dc.fields.map do |field|
        @oai_dc_mapping[field.to_sym] = "oai_dc_#{field}".to_sym
      end
      @oai_dc_mapping
    end
  end

  def sets
    @sets.map {|set_obj|
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
    list = @set_to_model.values.map{|model| 
      model.first(:order => "#{@timestamp_field} asc").send(@timestamp_field)
    }
    list.sort.first
  end

  def latest
    list = @set_to_model.values.map{|model| 
      model.first(:order => "#{@timestamp_field} desc").send(@timestamp_field)
    }
    list.sort.last
  end

  def find(selector, options={})
    #return next_set(options[:resumption_token]) if options[:resumption_token]
    set = options[:set]
    if !set.nil? and sets.select{|s| s.name == set}.empty?
      raise OAI::NoMatchException.new
    end

    models = set.nil? ? @set_to_model.values : [@set_to_model[set]]
    list = models.map do |model|

      conditions = sql_conditions(options)
      if :all == selector
        total = model.count(:id, :conditions => conditions)
        if @limit && total > @limit
          select_partial(ResumptionToken.new(options.merge({:last => 0})))
        else
          model.find(:all, :conditions => conditions)
        end
      else
        model.find(selector, :conditions => conditions)
      end

    end.flatten
  end

  private
  def sql_conditions(opts)
    sql = [ "#{timestamp_field} >= ? AND #{timestamp_field} <= ?" ]
    sql << Time.parse(opts[:from].to_s).localtime << Time.parse(opts[:until].to_s).localtime.to_s #-- OAI 2.0 hack - UTC fix from record_responce 

    return sql
  end

  def next_set
  end
end


