class MetaDataObject
	attr_accessor :set_name, :attrs, :fields

	def initialize
		self.fields = []
	end

	def field_names
		field_names = []
		fields.each { |field|
			field_names << field.keys[0]
		}

		return field_names
	end
end

