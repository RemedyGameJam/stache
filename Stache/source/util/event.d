module stache.util.event;

struct EventTemplate( T... )
{
	alias void delegate( T ) Delegate;

	// C# style operators
	void opCall( T args )
	{
		foreach( s; m_subscribers )
			s( args );
	}

	void opAssign( string op )( Delegate eventHandler ) if( op == "+=" )	{ subscribe(eventHandler); }
	void opAssign( string op )( Delegate eventHandler ) if( op == "-=" )	{ unsubscribe(eventHandler); }

	@property bool isEmpty() { return m_subscribers.length == 0; }

	@property size_t numSubscribers() { return m_subscribers.length; }

	@property const(Delegate[]) subscribers() { return m_subscribers; }

	void subscribe( Delegate eventHandler ) { m_subscribers ~= eventHandler; }
	void unsubscribe( Delegate eventHandler )
	{
		// not so simple...?
	}

	Delegate getDelegate() { return &this.opCall; } 

private:
	Delegate[] m_subscribers;
}


struct EventInfo
{
	const void* pSender;
	const void* pUserData;
}

alias EventTemplate!( void*, const EventInfo* ) Event;
