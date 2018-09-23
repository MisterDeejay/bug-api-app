class BaseCreator
  attr_accessor :record, :errors
  def initialize(klass, params)
    @klass = klass
    @params = params || {}
  end

  def run
    @record = @klass.constantize.new
    yield if block_given?
    record.update_attributes!(@params)
    record
  end
end
