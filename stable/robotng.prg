# Init section sets up robot and registers handlers
# To do:
# implement ToArenaCoord() and ToTankCoord()
# rename xdest/ydest in support of above: xA, yA, xT, yT
# refactor all using above
# refactor toRB/CartDegrees to use destAngle as volitile storage for values

Init
{
    name("Stupid Genius")
	lockall(true)
    
	regcore(SectorScanCore)
    regdtcrobot(FoundRobotMine, 3)
	regdtcmine(FoundRobotMine, 2)
	regdtccookie(FoundCookie, 1)
	
	xdest = 18
	ydest = 18
	gosub(driveToCoord)
	
	xdest = 18
	ydest = 180
	RGB = "body"
	gosub(aimAtCoord)
	lockall(false)
	
	sectStart = 0
	sectEnd = 90
	offset=1
	incThresh=8
	gosub(calcIncrement)
}

#Cores

SectorScanCore
{
	while(offset<(increment/2)+1)
		scan()
		while(_radaraim< (sectEnd-increment)+1)
			radarright(increment)
			scan()
		endw
		destAngle=sectEnd-offset
		startAngle=_radaraim
		gosub(minDegreesRight)
		radarright(rightDegrees)
		scan()
		while(_radaraim >sectStart+increment-1)
			radarleft(increment)
			scan()
		endw
		destAngle=sectStart+offset
		startAngle=_radaraim
		gosub(minDegreesRight)
		radarright(rightDegrees)
		offset=offset+1
	endw
	offset=1
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

#Event Handlers

# scan detected a robot, shoot at it then check again
FoundRobotMine
{
	RBDegrees = _radaraim
	gosub(toCartDegrees)
	destAngle = cartDegrees
	distance = _scandistfc
	gosub(findCoord)
	RGB = "gun"
	gosub(aimAtCoord)
	fire(1)
	printdeep("radaraim", _radaraim)
    #scan()
}

FoundCookie
{
	distance = _scandist+1
	RBDegrees = _radaraim
	gosub(toCartdegrees)
	destAngle = cartDegrees
	gosub(findCoord)
	gosub(driveToCoord)
	xdest = 18
	ydest = 18
	gosub(driveToCoord)
}

#Physical Action

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

#Internal Calculations

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

calcIncrement
{
	abs(sectStart-sectEnd)
	increment = _result/incThresh
}