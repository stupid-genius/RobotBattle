# Init section sets up robot and registers handlers
Init
{
    name("Stupid Genius")
    regcore(TestCore)
    #regdtcrobot(FoundRobot, 1)
	
	# have robot move to coord here
	xdest = 250
	ydest = 250
	gosub(driveToCoord)
	
	#toRBDegrees tests
	cartDegrees = 0
	printdeep("cartD", cartDegrees)
	gosub(toRBDegrees)
	printdeep("RBD", RBDegrees)
	
	cartDegrees = 90
	printdeep("cartD", cartDegrees)
	gosub(toRBDegrees)
	printdeep("RBD", RBDegrees)
	
	cartDegrees = 180
	printdeep("cartD", cartDegrees)
	gosub(toRBDegrees)
	printdeep("RBD", RBDegrees)
	
	cartDegrees = 270
	printdeep("cartD", cartDegrees)
	gosub(toRBDegrees)
	printdeep("RBD", RBDegrees)
	
	cartDegrees = 360
	printdeep("cartD", cartDegrees)
	gosub(toRBDegrees)
	printdeep("RBD", RBDegrees)
	
	#toCartDegrees tests
	RBDegrees = 0
	printdeep("RBD", RBDegrees)
	gosub(toCartDegrees)
	printdeep("cartD", cartDegrees)
	
	RBDegrees = 90
	printdeep("RBD", RBDegrees)
	gosub(toCartDegrees)
	printdeep("cartD", cartDegrees)
	
	RBDegrees = 180
	printdeep("RBD", RBDegrees)
	gosub(toCartDegrees)
	printdeep("cartD", cartDegrees)
	
	RBDegrees = 270
	printdeep("RBD", RBDegrees)
	gosub(toCartDegrees)
	printdeep("cartD", cartDegrees)
	
	RBDegrees = 360
	printdeep("RBD", RBDegrees)
	gosub(toCartDegrees)
	printdeep("cartD", cartDegrees)
}

TestCore
{
	
}
PatrolCore
{
	
}
SearchCore
{
    # if scan finds a robot, the event handler runs
    scan()
    radarright(5)
}

# scan detected a robot, shoot at it then check again
FoundRobot
{
    fire(1)
    scan()
}

driveToCoord
{
	gosub(angleToCoord)
	startAngle = _bodyaim
	gosub(minDegreesRight)
	bodyright(rightDegrees)
	gosub(distToCoord)
	ahead(distance)
}

# Useful subroutine that determines the minimum number of degrees 
# needed to reach 'destAngle' starting from 'startAngle'. Before being
# called, this section expects the following variables to be initialized
#   
#   startAngle - initial angle
#   destAngle - desired angle
#
# 'destAngle' and 'startAngle' can be any positive or negative value
#
# When complete, the section sets the 'rightDegrees' varable to the
# smallest number of degrees needed to reach 'destAngle' turning
# RIGHT. If the shortest distance is actually left, 'rightDegrees' will
# be negative.
#
minDegreesRight
{
    # Use the modulus operator (%) to ensure the result is from -360 to 360
    difference = (destAngle - startAngle) % 360
	printdeep("difference", difference)

    # Figure out how much would be needed to rotate right    
    rightDegrees = (difference + 360) % 360
    printdeep("rightDegrees", rightDegrees)
	
    # If this is more than 180, left rotation would be better
    # so set rightDegrees to a negative value.
    if( rightDegrees > 180 )
        rightDegrees = rightDegrees - 360
		printdeep("rightDegrees", rightDegrees)
    endif
}

toRBDegrees
{
	# cartDegrees created somewhere else
	RBDegrees = 90 - cartDegrees
	if(RBDegrees<0)
		abs(RBDegrees)
		RBDegrees = 360 - _result
	endif
}

toCartDegrees
{
	# RBDegrees created somewhere else
	cartDegrees = 90 - RBDegrees
	if(cartDegrees<0)
		abs(cartDegrees)
		cartDegrees = 360 - _result
	endif
}

angleToCoord
{
	abs(_ypos-ydest)
	ydist = _result
	abs(_xpos-xdest)
	xdist = _result
	
	if(xdist==0)
		if(ydest>_ypos)
			destAngle = 0
		elseif(ydest<_ypos)
			destAngle = 180
		endif
	elseif(ydist==0)
		if(xdest>_xpos)
			destAngle = 90
		elseif(xdest<_xpos)
			destAngle = 270
		endif
	else
		if(xdest>_xpos && ydest>_ypos)
			cartDegrees = atan(ydist/xdist)
			gosub(toRBDegrees)
			destAngle = RBDegrees
		elseif(xdest<_xpos && ydest>_ypos)
			cartDegrees = 180 - atan(ydist/xdist)
			gosub(toRBDegrees)
			destAngle = RBDegrees
		elseif(xdest<_xpos && ydest<_ypos)
			cartDegrees = 180 + atan(ydist/xdist)
			gosub(toRBDegrees)
			destAngle = RBDegrees
		elseif(xdest>_xpos && ydest<_ypos)
			cartDegrees = 360 - atan(ydist/xdist)
			gosub(toRBDegrees)
			destAngle = RBDegrees
		endif
	endif
}

distToCoord
{
	# xdest and ydest created somewere else.
	distance=((xdest-_xpos)^2+(ydest-_ypos)^2) ^ 0.5
}