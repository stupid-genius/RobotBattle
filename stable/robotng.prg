# Init section sets up robot and registers handlers
Init
{
    name("Stupid Genius")
    regcore(SectorScanCore)
    #regdtcrobot(FoundRobot, 1)
	
	# have robot move to coord here
	xdest = 0
	ydest = 0
	gosub(driveToCoord)
	destAngle = 45
	distance = 275
	gosub(findCoord)
	gosub(driveToCoord)
}

SectorScanCore
{
	
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
	RGB = "body"
	gosub(aimAtCoord)
	gosub(distToCoord)
	ahead(distance)
}

aimAtCoord
{
	if(RGB == "radar")
		startAngle = _radaraim
		gosub(angleToCoord)
		gosub(minDegreesRight)
		radarright(rightDegrees)
	elseif(RGB == "gun")
		startAngle = _gunaim
		gosub(angleToCoord)
		gosub(minDegreesRight)
		gunright(rightDegrees)
	elseif(RGB == "body")
		startAngle = _bodyaim
		gosub(angleToCoord)
		gosub(minDegreesRight)
		bodyright(rightDegrees)
	endif
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

    # Figure out how much would be needed to rotate right    
    rightDegrees = (difference + 360) % 360
	
    # If this is more than 180, left rotation would be better
    # so set rightDegrees to a negative value.
    if( rightDegrees > 180 )
        rightDegrees = rightDegrees - 360
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

findCoord
{
	# destAngle must be in cartesian degrees
	xdest=_xpos+distance*cos(destAngle)
	ydest=_ypos+distance*sin(destAngle)
}

distToCoord
{
	# xdest and ydest created somewere else.
	distance=((xdest-_xpos)^2+(ydest-_ypos)^2) ^ 0.5
}