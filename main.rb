#Regex
GRID = /^\d+\s\d+$/
START = /^\d+\s\d+\s[N|E|S|W]$/
MOVE = /^[L|R|M]+$/

# Constants
DIRECTIONS = %w[N E S W]
MOVEMENT = { 'N' => [0, 1], 'E' => [1, 0], 'S' => [0, -1], 'W' => [-1, 0] }

# Each input set(grid and rover details) is a scenario.
class Scenario
  attr_accessor :grid_x, :grid_y, :rovers

  def initialize
    self.rovers ||= []
  end

  def set_grid(grid)
    # First do a regex format check. Doing this later in the .valid? method could open up the app for unnecesery errors.
    raise ArgumentError, 'Invalid grid coordinates' unless grid =~ GRID

    # assign the grid values to the scenario variables
    self.grid_x, self.grid_y = grid.split(' ').map { |x| x.delete("\n").to_i }
  end

  def add_rover(i, start, movements)
    # First do a regex format check. Doing this later in the .valid? method could open up the app for unnecesery errors.
    raise ArgumentError, 'Invalid start coordinates' unless start =~ START
    raise ArgumentError, 'Invalid instructions given' unless movements =~ MOVE

    # Create the rover
    r = Rover.new(i, start, movements)
    # Store the rover to the scenario, validation would be run on the scenario.
    rovers << r
    r
  end

  def valid?
    # This valid check is to see the validity of the the entire scenario after we added the rovers.
    raise ArgumentError, 'No rovers given' unless rovers.any?

    # Ensure in boundary.
    # build a hash so we can grab all locations and run them against the
    r_hash = rovers.collect do |r|
      { id: r.id, coordinates: [r.start, r.movements].flatten.map do |c|
                                 c.split[0..1].join(' ')
                               end }
    end
    # run through all the calculated coordinates and
    out_bounds = begin
      r_hash.find do |r|
        r[:coordinates].find do |f|
          f.split.find do |x, y|
            !x.to_i.between?(0, grid_x) || !y.to_i.between?(0, grid_y)
          end
        end
      end
    rescue StandardError
      nil
    end
    raise ArgumentError, "Rover ##{out_bounds[:id]} would go out of bounds. Aborting" if out_bounds

    rovers.each_with_index do |r, i|
      prev_rovers = rovers[0...i]

      all_starts = prev_rovers.collect { |x| x.start.split[0..1].join(' ') }
      this_start = r.start.split[0..1].join(' ')
      raise ArgumentError, "Rover ##{r.id} cannot start on same location as Rover ##{all_starts.index(this_start)}" if all_starts.include?(this_start)

      all_ends = prev_rovers.collect { |x| x.movements.last.split[0..1].join(' ') }
      colission = all_ends & r.movements.map { |x| x.split[0..1].join(' ') }
      raise ArgumentError, "Rover ##{r.id} will collide with Rover ##{all_ends.index(colission.first)} at #{colission.first}" if colission.any?
    end
    true
  end

  def display
    objects = rovers
    objects_simple_end = objects.collect { |x| x.movements.last }.map { |o| o.split[0..1].join(' ') }
    output = '' # All output gets stored to this variable
    bottom_num = '   ' # Holds the x axis numbers
    horizonal_line = '' # Holds the horizontal line
    (0..grid_y).to_a.reverse.each do |y_i|
      horizonal_line = '  ' # Add padding, this is required for the table to aline with visible numbers
      container_row = "#{y_i} " #  Add the numbers for the y axis info
      (0..grid_x).to_a.each do |x_i|
        horizonal_line += '+--' # Build the horizonal line
        container_row += '|' # Build the vertical lines
        cur_location = [x_i, y_i].join(' ') # Build current coordinates
        # Add the spacing between vert lines, or add location info
        container_row += objects_simple_end.include?(cur_location) ? "##{objects_simple_end.index(cur_location)}" : '  '
      end
      output += horizonal_line + "+\n"
      output += container_row + "|\n"
      # Add the numbers for the x axis info that gets appennded last
    end
    output += horizonal_line + "+\n"
    output += bottom_num + (0..grid_x).to_a.join('  ') + "\n"
    output += rovers.map(&:to_s).join("\n") + "\n"
    output
  end
end

# This class is to build and run calculations on the rover
class Rover
  attr_accessor :id, :start, :instructions, :movements

  def initialize(id, start, instructions)
    @id = id
    @start = start
    @instructions = instructions
    @movements = begin
      calculate_movements
    rescue StandardError
      []
    end
  end

  def to_s
    "Rover ##{id}, Start location: #{start}, End location: #{movements.last}, Instruction set: #{instructions}"
  end

  def calculate_movements
    movements = []
    position = start.split
    instructions.split('').each do |i|
      case i
      when 'L'
        position[2] = DIRECTIONS[DIRECTIONS.index(position[2]) - 1]
      when 'R'
        position[2] = DIRECTIONS[DIRECTIONS.index(position[2]) + 1]
        # if there was no value from previous line we need to move to the beginning of the directions array again.
        position[2] ||= DIRECTIONS[0]
      when 'M'
        position[0], position[1] = [position[0..1].map(&:to_i), MOVEMENT[position[2]]].transpose.map(&:sum)
      end
      movements << position.join(' ')
    end
    movements
  end
end

def get_inputs
  puts "Enter the grid size for the scenario"
  grid = gets.chomp
  while !(grid =~ GRID)
      puts "Invalid grid coordinates given, Please enter coordinates again eg '6 6'  "
      grid = gets.chomp
  end

  i = 0
  rovers = []
  while true
    msg =  "Please enter the start coordinates for Rover ##{i}.";
    if i == 0 
        puts msg
    else
        puts msg + ' Alternatively press enter to stop adding Rovers'
    end

    start = gets.chomp rescue '' 
    break if start == '' && i > 0
    while !(start =~ START)
        puts start
        puts "Invalid start coordinates given for Rover ##{i}, Please enter coordinates again eg '1 2 N'"
        start = gets.chomp
    end

    puts "Please enter the movement instructions for Rover ##{i}.";
    move = gets.chomp
    while !(move =~ MOVE)
        puts "Invalid movement instructions given for Rover ##{i}, Please enter instructions again eg 'LRM'"
        move = gets.chomp
    end

    rovers << {id: i, start: start, move: move}
    i += 1
  end
  return grid, rovers
end


if $PROGRAM_NAME == __FILE__
  scen = Scenario.new
  begin
    grid, rovers = get_inputs()
    scen.set_grid(grid)

    rovers.each do |r|
      scen.add_rover(r[:id], r[:start], r[:move])
    end

    scen.valid?
    puts scen.display
  rescue ArgumentError => e
    # if any of the inputs cause an exception we would print the error message.
    puts(e)
  end
end