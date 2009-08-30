# Init section sets up robot and registers handlers
Init
{
    name("Stupid Genius")
    regcore(TestCore)
    #regdtcrobot(FoundRobot, 1)
	# have robot move to coord here
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
MinDegreesRight
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