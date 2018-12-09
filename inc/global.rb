# global constants and methods
DOT = '•'
DASH = '—'

# ruby magic to enable something like currying for procs, e.g. :+.(3).(5) or map(&:some_method.(with_parameter))
# actually, ruby supports currying natively for procs, lambdas and methods. doesn't work with map though, because something like map(&method(:some_method).curry.(parameter)) does not work for instance methods of the object that map is going through, this only works for public methods. e.g. [1,2,3].map(&method(:add).(2)) if :add is accessible from outside. won't work with e.g. :+ from Fixnum
class Symbol
  def call(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end
end

class Array
	def chop(n = 1)
		take size - n
	end
end

# works with strings and arrays (any enumerable with a :size, :empty? and :chop method)
def levenshtein_distance(s, t)
	@memo ||= {}
	return t.size if s.empty?
	return s.size if t.empty?
	min = [ (@memo[[s.chop, t]] || (levenshtein_distance s.chop, t)) + 1,
	 (@memo[[s, t.chop]] || (levenshtein_distance s, t.chop)) + 1,
	 (@memo[[s.chop, t.chop]] || (levenshtein_distance s.chop, t.chop)) + (s[-1] == t[-1] ? 0 : 1)
	].min
	@memo[[s, t]] = min
end

class String
	def to_snake # CamelCase -> snake_case
		gsub(/(.)([A-Z])/,'\1_\2').downcase
	end

	def to_camel # snake_case -> CamelCase
		split('_').map(&:capitalize).join
	end

	def add_linebreaks(length = 100) # max characters per line, breaks at last space before #{length} characters. #{length} should not be shorter than a word, otherwise get weird effects
		return self if self.length < length
		at = self[0..length].rpartition(" ").first.length
		return self[0..at-1] + "\n" + self[at+1..-1].add_linebreaks(length)
	end
end
