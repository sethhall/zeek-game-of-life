##! Conway's Game of Life implemented in the Zeek programming language.
##!
##! Author: Seth Hall <seth@corelight.com>

redef exit_only_after_terminate = T;

module ConwaysGameOfLife;

export {
	## The character to use for the animal.  The default
	## is the UTF-8 encoding of "pile of poo" (💩).
	const lifeform = "\xf0\x9f\x92\xa9" &redef;

	## The character to use for the background land.  The 
	## default is a UTF-8 encoded plant codepoint (🌱).
	const background = "\xf0\x9f\x8c\xb1" &redef;

	## The X dimension of the gameboard.  This must match
	## dimensions of the provided gameboard layout.
	const gameboard_x = 36 &redef;

	## The Y dimension of the gameboard.  This must match
	## dimensions of the provided gameboard layout.
	const gameboard_y = 27 &redef;

	## The default gameboard is one of the more interesting
	## perpetually running scenarios.  If you don't provide
	## the correct dimensions for this gameboard, the game
	## will not work correctly because it can't be laid out.
	const gameboard: vector of bool = vector(
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,T,F,T,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,T,T,F,F,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,T,T,
		F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,T,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,T,T,
		T,T,F,F,F,F,F,F,F,F,T,F,F,F,F,F,T,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		T,T,F,F,F,F,F,F,F,F,T,F,F,F,T,F,T,T,F,F,F,F,T,F,T,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,T,F,F,F,F,F,T,F,F,F,F,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,T,F,F,F,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,T,T,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,
		F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F,F) &redef;

	## The length of time between each generation.
	const generation_life = .001sec &redef;
}

type Field: record {
	field:      vector of bool &default=gameboard;
	generation: count          &default=0;
	x:          count          &default=gameboard_x;
	y:          count          &default=gameboard_y;
};

const iter3=set(-1,0,1);

global stdout = open("/dev/stdout") &raw_output;

function draw_field(f: Field)
	{
	# Reset the cursor to the zero position but don't clear
	# the screen.  Clearing the screen gives a tearing effect.
	print stdout, "\x1b[0;0H";

	print fmt("==== Generation: %d ====", f$generation);

	local i = 0;
	while ( i < f$y )
		{
		local j = 0;
		local field_line="";
		while ( j < f$x )
			{
			local cell = f$x*i+j;
			print stdout, (f$field[cell]) ? lifeform : background;
			if ( ++j == f$x )
				break;
			}

		print stdout, "\n";
		if ( ++i == f$y )
			break;
		}
	}

function count_alive(f: Field, i: count, j: count): count
	{
	local ret=0;

	for ( a in iter3 )
		{
		local x: int = i+a;
		for ( b in iter3 )
			{
			local y: int = j+b;
			if ( x==i && y==j )
				next;
			if ( y < f$y && x < f$x &&
			     x >= 0 && y >= 0)
				{
				ret += f$field[f$x*y+x] ? 1:0;
				}
			}
		}
	return ret;
	}

function evolve(f: Field): Field
	{
	local i = 0;
	local alive = 0;
	local tmp_field = copy(f$field);
	while ( i < f$x )
		{
		local j = 0;
		while ( j < f$y )
			{
			alive = count_alive(f, i, j);
			local cell = f$x*j+i;
			local cs = f$field[cell];
			if ( cs )
				{
				if ( (alive > 3) || ( alive < 2 ) )
					tmp_field[cell] = F;
				else
					tmp_field[cell] = T;
				} 
			else 
				{
				if ( alive == 3 )
					tmp_field[cell] = T;
				else
					tmp_field[cell] = F;
				}
			++j;
			if ( j == f$y )
				break;
			}
		++i;
		if ( i == f$x )
			break;
		}
	f$field = tmp_field;
	return f;
	}

event loop_event(f: Field)
	{
	draw_field(f);
	++f$generation;
	if ( !any_set(f$field) )
		print "Extinction!";
	else
		schedule generation_life { loop_event(evolve(f)) };
	}

function run(f: Field)
	{
	if ( f$x*f$y != |f$field| )
		{
		Reporter::warning("Your 'Game of Life' field is not laid out correctly.");
		
		# If the provided dimensions were incorrect, we'll
		# just fill out the rest of the gameboard with false.
		local offset = |f$field|;
		resize(f$field, f$x*f$y);
		while ( offset < f$x*f$y )
			{
			f$field[offset] = F;
			++offset;
			}
		}

	event loop_event(f);
	}

event zeek_init() &priority=-20
	{
	# Clear the screen.
	print stdout, "\x1bc";

	# Run the game!
	ConwaysGameOfLife::run(Field());
	}
