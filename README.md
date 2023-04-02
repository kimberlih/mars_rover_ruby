# Google Mars Rover Challenge(ruby)

This task was given for an technical interview. The challenge originates from Google and is a great way of showcasing basic programming understanding.

The challenge copied from Google:

## Mars Rover technical Challenge

The problem below requires some kind of input. You are free to implement any mechanism for feeding input into your solution (for example, using hard coded data within a unit test). You should provide sufficient evidence that your solution is complete by, as a minimum, indicating that it works correctly against the supplied test data.

We highly recommend using a unit testing framework such as JUnit or NUnit. Even if you have not used it before, it is simple to learn and incredibly useful.

The code you write should be of production quality, and most importantly, it should be code you are proud of.

## MARS ROVERS

A squad of robotic rovers are to be landed by NASA on a plateau on Mars.

This plateau, which is curiously rectangular, must be navigated by the rovers so that their on board cameras can get a complete view of the surrounding terrain to send back to Earth.

A rover's position is represented by a combination of an x and y co-ordinates and a letter representing one of the four cardinal compass points. The plateau is divided up into a grid to simplify navigation. An example position might be 0, 0, N, which means the rover is in the bottom left corner and facing North.

In order to control a rover, NASA sends a simple string of letters. The possible letters are 'L', 'R' and 'M'. 'L' and 'R' makes the rover spin 90 degrees left or right respectively, without moving from its current spot.

'M' means move forward one grid point, and maintain the same heading.

Assume that the square directly North from (x, y) is (x, y+1).

### Input:

The first line of input is the upper-right coordinates of the plateau, the lower-left coordinates are assumed to be 0,0.

The rest of the input is information pertaining to the rovers that have been deployed. Each rover has two lines of input. The first line gives the rover's position, and the second line is a series of instructions telling the rover how to explore the plateau.

The position is made up of two integers and a letter separated by spaces, corresponding to the x and y co-ordinates and the rover's orientation.

Each rover will be finished sequentially, which means that the second rover won't start to move until the first one has finished moving.

### Output:

The output for each rover should be its final co-ordinates and heading.

### Test Input:

```
5 5
1 2 N
LMLMLMLMM
3 3 E
MMRMMRMRRM
```

### Expected Output:

```
1 3 N
5 1 E
```

---
# Installation Instructions

### Option 1 - Ruby

If you have ruby installed you can run it as follows:

```
> ruby main.rb < inputs/valid_000
  +--+--+--+--+--+--+
5 |  |  |  |  |  |  |
  +--+--+--+--+--+--+
4 |  |  |  |  |  |  |
  +--+--+--+--+--+--+
3 |  |#0|  |  |  |  |
  +--+--+--+--+--+--+
2 |  |  |  |  |  |  |
  +--+--+--+--+--+--+
1 |  |  |  |  |  |#1|
  +--+--+--+--+--+--+
0 |  |  |  |  |  |  |
  +--+--+--+--+--+--+
   0  1  2  3  4  5
Rover #0, Start location: 1 2 N, End location: 1 3 N, Instruction set: LMLMLMLMM
Rover #1, Start location: 3 3 E, End location: 5 1 E, Instruction set: MMRMMRMRRM
```

There are multiple input files, some are `valid_` while others are `invalid`

#### Makefile

Make file will be provided to easily run commands with the make tool.

To setup the gems:

```
make install
```

To run the challenge input against the script
```
make run
```

To run the test suite
```
make test
```

### Option 2 - Docker - (Incomplete)

If you have docker installed you can run

```
> docker build -t ruby_msc .
> docker run -it ruby_msc
```

# Testing

The tests are written in rspec. You can run them as follows:

```
> bundle install
> bundle exec rake spec
...................

Finished in 0.00676 seconds (files took 0.0579 seconds to load)
19 examples, 0 failures
```

# Assumptions & rules made

1. Cannot start on same location.
2. When entering another Rover check whether at any point its path would collide with the end point of previously entered rovers
3. we assume inputs will always come from a file, and not manual input. So there are no promps, but you should be able to enter the data manually still
4. Rovers cannot go out of bounds.

# TODO

1. improve the display grid to work with dual or triple digit numbers without breaking the spacing/padding
2. Add telnet functionality