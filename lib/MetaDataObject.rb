class MetaDataObject
	attr_accessor :set_name, :attrs, :fields, :index_map

	def initialize
		self.fields = []
		self.index_map = {}
	end

	def field_names
		field_names = []
		fields.each { |field|
			field_names << field.keys[0]
		}

		return field_names
	end
end

