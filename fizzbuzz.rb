# no libraries, no methods, classes, objects, 
# control structures, assigments, arrays, strings, numbers, booleans

# refering to variables, creating lambdas, calling lambdas
# const abbreviation

# Plumbing
-> x { x + 2 }.call(1)

# Arguments
-> x, y { x + y }.call(1, 2)

# lets use only one argument blocks
-> x {
	-> y {
		x + y
	}
}[3][4]

# Equality
proc1 = -> n { n * 2 }
proc2 = -> x { proc1.call(x) }

# fizz buzz
# Write a program that prints 1 to 100. But for multiple of 3, print fizz for multiple of 5 print Buzz 
# and for multiple of 3 and 5 print fizzbuzz

# numbers
ZERO = -> p { -> x { x } }
ONE = -> p { -> x { p[x] } }
TWO = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE = -> p { -> x {  p[p[p[p[p[x]]]]]  } }
FITTEEN = -> p { -> x {  p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]  } }
HUNDRED = -> p { -> x {  p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]  } }

# this tehnique is named Churn coding from Alonzo Churn

def to_integer(proc)
	proc[-> n { n + 1 }][0]
end

def create_number(integer)
	number = [].tap do |number|
		integer.times do
			number << 'p['
		end
		number << 'x'
		integer.times do
			number << ']'
		end
	end
	"-> p { -> x {  #{number.join}  } }"
end

# Booleans
# not a liveless piece of data, but a lambda
TRUE = -> x { -> y { x } }
FALSE = -> x { -> y { y } }

def to_boolean(proc)
	proc[true][false]
end

IF = -> b { b }

IF[TRUE]['cool']['not cool']
IF[FALSE]['cool']['not cool']

# Predicates
# take advantage of the fact that 0 does not call the passed proc

IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }

to_boolean(IS_ZERO[ZERO])
to_boolean(IS_ZERO[TWO])

# Pairs

PAIR = -> x { -> y { -> f { f[x][y] } } }
LEFT = -> p { p[-> x { -> y { x } } ] } # we call the pair with a proc that will return either left
RIGHT = -> p { p[-> x { -> y { y } } ] }

my_pair = PAIR[FITTEEN][TWO]
to_integer(LEFT[my_pair])
to_integer(RIGHT[my_pair])

# numeric operations

INCREMENT = -> n { -> p { -> x { p[n[p][x]] } } } # call p n times on x and then call p once more on the result, n + 1
to_integer(INCREMENT[TWO])

SLIDE = -> p { PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]] }
DECREMENT = -> n { LEFT[n[SLIDE][PAIR[ZERO][ZERO]]] } # n time slide a pair form zero, zero
to_integer(DECREMENT[FITTEEN])

ADD = -> m { -> n { n[INCREMENT][m] } } # increment m, n times
SUBSTRACT = -> m { -> n { n[DECREMENT][m] } }
MULTIPLY = -> m { -> n { n[ADD[m]][ZERO] } }
POWER = -> m { -> n { n[MULTIPLY[m]][ONE] } }

to_integer(ADD[TWO][THREE])
to_integer(SUBSTRACT[FITTEEN][THREE])
to_integer(MULTIPLY[TWO][THREE])
to_integer(POWER[THREE][TWO])

# def mod(m, n)
# 	if n <= m
# 		mod(m - n, n)
# 	else
# 		m
# 	end
# end

# def less_or_equal
# 	m - n <= 0
# end

IS_LESS_OR_EQUAL = -> m { -> n { IS_ZERO[SUBSTRACT[m][n]] } }

to_boolean(IS_LESS_OR_EQUAL[TWO][THREE])
to_boolean(IS_LESS_OR_EQUAL[THREE][TWO])

MOD = -> m { -> n {
		IF[IS_LESS_OR_EQUAL[n][m]][
			-> x {
				MOD[SUBSTRACT[m][n]][n][x]
 			}
		][
			m
		]
	}
}

# solve the recursivity via Y combinator, it will call the proc itself with the proc as the first argument
Y = -> f { -> x { f[x[x]] }[-> x { f[x[x]] }] }
Z = -> f { -> x { f[-> y { x[x][y] }] }[-> x { f[-> y { x[x][y] }] }] }

MOD = Z[-> f { -> m { -> n {
		IF[IS_LESS_OR_EQUAL[n][m]][
			-> x {
				f[SUBSTRACT[m][n]][n][x]
 			}
		][
			m
		]
	}
} }]

to_integer(MOD[THREE][TWO])
to_integer(MOD[FITTEEN][THREE])

# lists
EMPTY = PAIR[TRUE][TRUE]
UNSHIFT = -> l { -> x {
		PAIR[FALSE][PAIR[x][l]]
	} 
}
IS_EMPTY = LEFT
FIRST = -> l { LEFT[RIGHT[l]] }
REST = -> l { RIGHT[RIGHT[l]] }

my_list = UNSHIFT[
	UNSHIFT[
		UNSHIFT[EMPTY][THREE]
	][TWO]
][ONE]

to_integer(FIRST[my_list])
to_integer(FIRST[REST[my_list]])
to_integer(FIRST[REST[REST[my_list]]])
to_boolean(IS_EMPTY[my_list])
to_boolean(IS_EMPTY[EMPTY])

def to_array(proc)
	array = []

	until to_boolean(IS_EMPTY[proc])
		array << FIRST[proc]
		proc = REST[proc]
	end

	array
end

to_array(my_list).map { |p| to_integer(p) }

RANGE = 
	Z[-> f {
		-> m { -> n {
			IF[IS_LESS_OR_EQUAL[m][n]][
				-> x {
					UNSHIFT[f[INCREMENT[m]][n]][m][x]
				}
			][
				EMPTY
			]
			}}
	}
	]

my_range = RANGE[ONE][THREE]
to_array(my_range).map { |p| to_integer(p) }

FOLD = 
	Z[-> f {
		-> l { -> x { -> g {
			IF[IS_EMPTY[l]][
				x
			][
				-> y {
					g[f[REST[l]][x][g]][FIRST[l]][y]
				}
			]
			}}}
	}
	]

to_integer(FOLD[RANGE[ONE][THREE]][ZERO][ADD])

MAP = -> k { -> f {
		FOLD[k][EMPTY][
			-> l { -> x { UNSHIFT[l][f[x]] } }
		]
	}}

my_list = MAP[RANGE[ONE][THREE]][INCREMENT]
to_array(my_list).map { |p| to_integer(p) }

solution = MAP[RANGE[ONE][FITTEEN]][-> n {
	IF[IS_ZERO[MOD[n][FITTEEN]]][
		p 'fizzbuzz'
	][IF[IS_ZERO[MOD[n][THREE]]][
		p 'fizz'
	][IF[IS_ZERO[MOD[n][FIVE]]][
		p 'buzz'
	][
		n.to_s
	]]]
	}]

# def max(m, n)
# 	if m > n
# 		m
# 	else
# 		n
# 	end
# end

MAX = -> m { -> n {
	IF[IS_LESS_OR_EQUAL[m][n]][
		n
	][
		m
	]
	}}

p to_integer(MAX[HUNDRED][THREE])