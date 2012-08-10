DataGenerator
=============

Generates ready for insertion SQL file with various (calculated or randomized) data.

How to use it?
--------------

1. Download source code.
2. Open `config.yml` and adjust it to your own needs.
3. Run `ruby generate.rb`.
4. Insert generated SQL file into your database. :-)

Known issues
------------

As of early August 2012 project is in very early stage so expect all kind of problems. Sorry.

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

*	**date**

	Random date.

*	**entity**

	Required: **from**  
	Loads a random value from dictionary specified in *from* attribute. Check dictionaries
	in *data/* dir.

*	**lorem**

	Optional: min_sentences (default: 1)  
	Optional: max_sentences (default: 20)  
	Generates pseudo-text with random number of sentences from famous *Lorem Ipsum*.

*	**distributed**

	Required: values (Array of Arrays)  
	Randomizes fixed values using their weights. Example values can look like this:  
	`[ ['ruby', 0.2], ['php', 0.4], ['python', 0.25], ['c++', 0.14], ['java', 0.01] ]`
	Meaning that you have 20% chance to get 'ruby' value, 40% for PHP and so on. This
	does not guarantee that exaclty 20% of values will be 'ruby' because they are
	randoized independanty. Keep in mind that weights have to sum up to 1.

*	**code**

	Required: **code**  
	Value is generated with specified Ruby code.

Supported field types: specific
-------------------------------

*	**pesel**

	Optional: Array **fields_as_args**  
	Method arguments: date = nil, sex = nil  
	Generates Polish person's identification number using specific algorithm. Can be random
	but should depend on someone's birth date and sex cause they're required for proper calculations.
	Attribute *fields_as_args* allows using values generated for other fields but they should be placed
	before current field.

*	**phone_number**

	Optional: **null_density** (0..1)
	Generates random phone number matching pattern XXX-XXX-XXX, where X = 0..9.

*	**pl_postal_code**

	Random polish postal code matching XX-XXX, where X = 0..9.

Imagining the future
--------------------

* Writing also to CSV.
* Support for auto-increment fields and SQL COPY format.
* More specific generators.
* Much more dictionaries.
* Constant code refactorization (to improve my Ruby skills).
* Code unit tested.
* All issues closed.

