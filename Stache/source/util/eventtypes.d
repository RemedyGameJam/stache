module stache.util.eventtypes;

public import stache.util.event;
public import fuji.types;
public import stache.i.entity;

alias EventTemplate!() VoidEvent;
alias EventTemplate!(MFRect) MFRectEvent;
alias EventTemplate!(IEntity[string]) IEntityMapEvent;