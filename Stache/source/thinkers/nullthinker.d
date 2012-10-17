module stache.thinkers.nullthinker;

public import stache.i.thinker;

class NullThinker : IThinker
{
	bool OnAssign(ISheeple sheeple) { return false; }
	void OnThink() { }

	@property bool Valid() { return false; }
}

