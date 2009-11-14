Init
{
	name("target")
	regcldmissile(Move, 1)
}

Move
{
	if(_xpos<_arenawidth-17)
		ahead(33)
	elseif(_ypos>_arenaheight-18)
		bodyright(90)
		ahead(33)
	else
		ahead(33)
	endif
}