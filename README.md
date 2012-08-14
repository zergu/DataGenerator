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
	        description: { type: text, min_sentences: 2, max_sentences: 5 }

Supported field types: generic
------------------------------

*	**fixed**

	Required: **value**  
	Simply set this field to *value*.

*	**number**

	Optional: **min** (default: 1)  
	Optional: **max** (default: 999)  
	Random number from *min* — *max* range.

*	**serial**

	Optional: **start** (default: 1)  
	Generates successive numbers.

*	**date**

	Optional: **min** (default: '1950-01-01')  
	Optional: **max** (default: '2009-12-31')  
	Random date from *min* — *max* range.

*	**datetime**

	Optional: **min** (default: '1950-01-01 00:00:00')  
	Optional: **max** (default: '2009-12-31 23:59:59')  
	Random datetime from *min* — *max* range.

*	**entity**

	Required: **from**  
	Loads a random value from dictionary specified in *from* attribute. Check dictionaries
	in *data/* dir.

*	**text**

	Optional: **min_sentences** (default: 1)  
	Optional: **max_sentences** (default: 20)  
	Generates pseudo-text with random number of sentences from famous *Lorem Ipsum*.

*	**word**

	Generates random word (4-14 letters). Small letters only, consonants and vowels alternately.

*	**duplicate**

	Required: **field**  
	Copies value from already generated field. This by itself does not seem very useful, but
	remember you can combine it with some prefixes and suffixes.

*	**distributed**

	Required: **values** (Array of Arrays)  
	Randomizes fixed values using their weights. Example values can look like this:  
	`[ ['ruby', 0.2], ['php', 0.4], ['python', 0.25], ['c++', 0.14], ['java', 0.01] ]`
	Meaning that you have 20% chance to get 'ruby' value, 40% for 'php' and so on. This
	does not guarantee that exaclty 20% of values will be 'ruby' because they are
	randoized independantly. Keep in mind that weights have to sum up to 1.

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

	Generates random phone number matching pattern XXX-XXX-XXX, where X = 0..9.

*	**email**

	Generates random email matching pattern X@X.TLD, where X = where X is random string (3…10 chars)
	and TLD is one of few top-level domains.

*	**postal_code**
	
	Optional: **country_code**
	Random postal code matching XXXXX, where X = 0..9.  
	Supported country codes:  
	* PL: XX-XXX

Global parameters available for all field types
-----------------------------------------------

*	**null_density** - number from 0..1 range indicating how often NULL should be returned instead of generated
	value. If not defined all values will be generated. Example:  
	`phone_number: { type: phone_number, null_density: 0.25 }`
	means that about 75% of all records will have random phone number generated.

*	**prefix** and **suffix** - use another value generator to add append or prepend to current value. Prefixes
	and suffixes can be nested and work only with values castable to string. Example: `street: { type: entity, from: names_de,
	suffix: { type: fixed, value: 'straße ', suffix: { type: number, max: 99 } } }`

Imagining the future
--------------------

* Writing also to CSV.
* Support for auto-increment fields and SQL COPY format.
* More specific generators.
* Much more dictionaries.
* Constant code refactorization (to improve my Ruby skills).
* Code unit tested.
* All issues closed.

Found DataGenerator useful? Please consider donation.
-----------------------------------------------------

[![PayPal - Donate](https://www.paypal.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=5PA9R5DP35T92&lc=PL&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted)
