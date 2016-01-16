// BYOND versions prior to 510 don't have their own native json_encode/json_decode implementations
// Work around with a (modified) version of Nickr5's JSON library

#if DM_VERSION < 510

proc
	json_decode(json)
		var/static/nqv8_json_reader/_jsonr = new()
		return _jsonr.ReadObject(_jsonr.ScanJson(json))

	json_encode(list/L)
		var/static/nqv8_json_writer/_jsonw = new()
		return _jsonw.WriteObject(L)


nqv8_json_token
	var
		value
	New(v)
		src.value = v
	text
	number
	word
	symbol
	eof

nqv8_json_reader
	var
		list
			string		= list("'", "\"")
			symbols 	= list("{", "}", "\[", "]", ":", "\"", "'", ",")
			sequences 	= list("b" = 8, "t" = 9, "n" = 10, "f" = 12, "r" = 13)
			tokens
		json
		i = 1


	proc
		// scanner
		ScanJson(json)
			src.json = json
			. = new/list()
			src.i = 1
			while(src.i <= lentext(json))
				var/char = get_char()
				if(is_whitespace(char))
					i++
					continue
				if(string.Find(char))
					. += read_string(char)
				else if(symbols.Find(char))
					. += new/nqv8_json_token/symbol(char)
				else if(is_digit(char))
					. += read_number()
				else
					. += read_word()
				i++
			. += new/nqv8_json_token/eof()

		read_word()
			var/val = ""
			while(i <= lentext(json))
				var/char = get_char()
				if(is_whitespace(char) || symbols.Find(char))
					i-- // let scanner handle this character
					return new/nqv8_json_token/word(val)
				val += char
				i++

		read_string(delim)
			var
				escape 	= FALSE
				val		= ""
			while(++i <= lentext(json))
				var/char = get_char()
				if(escape)
					switch(char)
						if("\\", "'", "\"", "/", "u")
							val += char
						else
							// TODO: support octal, hex, unicode sequences
							ASSERT(sequences.Find(char))
							val += ascii2text(sequences[char])
				else
					if(char == delim)
						return new/nqv8_json_token/text(val)
					else if(char == "\\")
						escape = TRUE
					else
						val += char
			CRASH("Unterminated string.")

		read_number()
			var/val = ""
			var/char = get_char()
			while(is_digit(char) || char == "." || lowertext(char) == "e")
				val += char
				i++
				char = get_char()
			i-- // allow scanner to read the first non-number character
			return new/nqv8_json_token/number(text2num(val))

		check_char()
			ASSERT(args.Find(get_char()))

		get_char()
			return copytext(json, i, i+1)

		is_whitespace(char)
			return char == " " || char == "\t" || char == "\n" || text2ascii(char) == 13

		is_digit(char)
			var/c = text2ascii(char)
			return 48 <= c && c <= 57 || char == "+" || char == "-"


		// parser
		ReadObject(list/tokens)
			src.tokens = tokens
			. = new/list()
			i = 1
			read_token("{", /nqv8_json_token/symbol)
			while(i <= tokens.len)
				var/nqv8_json_token/K = get_token()
				check_type(/nqv8_json_token/word, /nqv8_json_token/text)
				next_token()
				read_token(":", /nqv8_json_token/symbol)

				.[K.value] = read_value()

				var/nqv8_json_token/S = get_token()
				check_type(/nqv8_json_token/symbol)
				switch(S.value)
					if(",")
						next_token()
						continue
					if("}")
						next_token()
						return
					else
						die()

		get_token()
			return tokens[i]

		next_token()
			return tokens[++i]

		read_token(val, type)
			var/nqv8_json_token/T = get_token()
			if(!(T.value == val && istype(T, type)))
				CRASH("Expected '[val]', found '[T.value]'.")
			next_token()
			return T

		check_type(...)
			var/nqv8_json_token/T = get_token()
			for(var/type in args)
				if(istype(T, type))
					return
			CRASH("Bad token type: [T.type].")

		check_value(...)
			var/nqv8_json_token/T = get_token()
			ASSERT(args.Find(T.value))

		read_key()
			var/char = get_char()
			if(char == "\"" || char == "'")
				return read_string(char)

		read_value()
			var/nqv8_json_token/T = get_token()
			switch(T.type)
				if(/nqv8_json_token/text, /nqv8_json_token/number)
					next_token()
					return T.value
				if(/nqv8_json_token/word)
					next_token()
					switch(T.value)
						if("true")
							return TRUE
						if("false")
							return FALSE
						if("null")
							return null
				if(/nqv8_json_token/symbol)
					switch(T.value)
						if("\[")
							return read_array()
						if("{")
							return ReadObject(tokens.Copy(i))
			die()

		read_array()
			read_token("\[", /nqv8_json_token/symbol)
			. = new/list()
			var/list/L = .
			while(i <= tokens.len)
				// Avoid using Add() or += in case a list is returned.
				L.len++
				L[L.len] = read_value()
				var/nqv8_json_token/T = get_token()
				check_type(/nqv8_json_token/symbol)
				switch(T.value)
					if(",")
						next_token()
						continue
					if("]")
						next_token()
						return
					else
						die()
						next_token()
				CRASH("Unterminated array.")


		die(nqv8_json_token/T)
			if(!T) T = get_token()
			CRASH("Unexpected token: [T.value].")

nqv8_json_writer
	proc
		WriteObject(list/L)
			. = "{"
			var/i = 1
			for(var/k in L)
				var/val = L[k]
				. += {"\"[k]\":[write(val)]"}
				if(i++ < L.len)
					. += ","
			.+= "}"

		write_array(list/L)
			. = "\["
			for(var/i = 1 to L.len)
				. += write(L[i])
				if(i < L.len)
					. += ","
			. += "]"

		write(val)
			if(isnum(val))
				return num2text(val, 100)
			else if(isnull(val))
				return "null"
			else if(istype(val, /list))
				if(is_associative(val))
					return WriteObject(val)
				else
					return write_array(val)
			else
				. += write_string("[val]")

		write_string(txt)
			var/static/list/json_escape = list("\\", "\"", "'", "\n")
			for(var/targ in json_escape)
				var/start = 1
				while(start <= lentext(txt))
					var/i = findtext(txt, targ, start)
					if(!i)
						break
					if(targ == "\n")
						txt = copytext(txt, 1, i) + "\\n" + copytext(txt, i+1)
					else
						txt = copytext(txt, 1, i) + "\\" + copytext(txt, i)
					start = i + 2
			return {""[txt]""}

		is_associative(list/L)
			for(var/key in L)
				if(!isnum(key) && !isnull(L[key]))
					return TRUE

#endif
