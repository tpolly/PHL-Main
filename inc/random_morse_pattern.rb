class RandomMorsePattern
	MORSE_CODE = {
		a: [0,1],
		b: [1,0,0,0],
		c: [1,0,1,0],
		d: [1,0,0],
		e: [0],
		f: [0,0,1,0],
		g: [1,1,0],
		h: [0,0,0,0],
		i: [0,0],
		j: [0,1,1,1],
		k: [1,0,1],
		l: [0,1,0,0],
		m: [1,1],
		n: [1,0],
		o: [1,1,1],
		p: [0,1,1,0],
		q: [1,1,0,1],
		r: [0,1,0],
		s: [0,0,0],
		t: [1],
		u: [0,0,1],
		v: [0,0,0,1],
		w: [0,1,1],
		x: [1,0,0,1],
		y: [1,0,1,1],
		z: [1,1,0,0]
	}

	# morse patterns ordered by length and number of 1-0 or 0-1 transitions as crude measure of complexity. Probably not completely accurate: [1,0,1,0] is probably easier to remember than [0,0,1,0]
	PATTERNS_BY_LENGTH_COMPLEXITY = {
		1 => { 
			0 => [[0], [1]]
		},
		2 => {
			0 => [[0, 0], [1, 1]],
			1 => [[0, 1], [1, 0]],
		},
		3 => {
			0 => [[0, 0, 0], [1, 1, 1]],
			1 => [[1, 0, 0], [1, 1, 0], [0, 0, 1], [0, 1, 1]],
			2 => [[1, 0, 1], [0, 1, 0]],
		},
		4 => {
			0 => [[0, 0, 0, 0]],
			1 => [[1, 0, 0, 0], [0, 1, 1, 1], [0, 0, 0, 1], [1, 1, 0, 0]],
			2 => [[0, 0, 1, 0], [0, 1, 0, 0], [0, 1, 1, 0], [1, 1, 0, 1], [1, 0, 0, 1], [1, 0, 1, 1]],
			3 => [[1, 0, 1, 0]],
		}
	}

	PATTERN_LENGTH = 10

	def initialize(pattern = nil)
		if pattern.nil?
			patterns = []
			# 1 one-length pattern
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[1][0].shuffle.take(1) 

			# 2 two-length patterns
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[2][0].shuffle.take(1) 
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[2][1].shuffle.take(1)

			# 3 three-length patterns
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[3][0].shuffle.take(1)
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[3][1].shuffle.take(1)
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[3][2].shuffle.take(1)
			
			# 4 four-length patterns
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[4][1].shuffle.take(2) 
			patterns += PATTERNS_BY_LENGTH_COMPLEXITY[4][2].shuffle.take(2)

			@pattern = ([*0..(PATTERN_LENGTH - 1)].shuffle.zip(patterns.shuffle)).sort.to_h
		else
			@pattern = pattern
		end

		leftovers = MORSE_CODE.values - @pattern.values

		@leftover_patterns_by_length = {}
		1.upto 4 do |i| 
			@leftover_patterns_by_length[i] = leftovers.select {|p| p.length == i}
		end
	end

	def keys
		return @pattern.keys
	end

	def get_random_invalid # has the same length distribution as the main pattern (but not complexity)
		length = Random.rand 1..10
		case length
		when 1
			return @leftover_patterns_by_length[1].first # there is only one
		when 2..3
			return @leftover_patterns_by_length[2].shuffle.first
		when 4..6
			return @leftover_patterns_by_length[3].shuffle.first
		else # 7..10
			return @leftover_patterns_by_length[4].shuffle.first
		end
	end

	def as_hash
		return @pattern
	end

	def get(i)
		return @pattern[i]
	end
end
