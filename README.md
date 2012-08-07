DataGenerator
=============

Generates ready for insertion SQL file with various (calculated or randomized) data.

How to use it?
--------------

1. Download source code
2. Open `config.yml` and adjust it to your own needs
3. Run `ruby generate.rb`

Example config file (YAML)
--------------------------

	format: sql
	sets:
	    patients:
	        _attributes: { count: 200 }
	        application_id: { type: fixed, value: 3 }
	        name1: { type: entity, from: first_names_pl }
	        lastname1: { type: entity, from: last_names_pl }
	        birthday_at: { type: date, min: 1900-01-01, max: 2006-12-31 }
	        pesel: { type: pesel, fields_as_args: [birthday_at] }
	        country: { type: entity, from: countries_pl }
	        gender_id: { type: number, min: 1, max: 2 }
	        active: { type: fixed, value: true }
	        created_at: { type: code, code: 'DateTime.now()' }
	    visits:
	        _attributes: { count: 350 }
	        patient_id: { type: number, min: 2, max: 5 }
	        description: { type: lorem, min_sentences: 2, max_sentences: 5 }

Supported field types: generic
------------------------------

*	**fixed**

	Required: **value**  
	Simply set this field to *value*.

*	**number**

	Optional: **min** (default: 1)  
	Optional: **max** (default: 999)  
	Random number from *min* — *max* range.

*	entity

	Required: **from**  
	Loads a random value from dictionary specified in *from* attribute. Check dictionaries
	in *data/* dir.

*	code

	Required: **code**  
	Value is generated with specified Ruby code.

Supported field types: specific
-------------------------------

*	**pesel**

	Optional: **fields_as_args**  
	Method arguments: date = nil, sex = nil  
	Generates Polish person's identification number using specific algorithm. Can be random
	but should depend on someone's birth date because it's used in calculations. Attribute
	*fields_as_args* allows using values generated for other fields but they should be placed
	before current field.
