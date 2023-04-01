# This is a quick way of testing mars rover inputs
# Assumptions:
# 1. Cannot start on same location.
# 2. When entering another Rover check whether its path would collide with the end point of previously entered rovers
# 3. we assume inputs will always come from a file, and not manual input. 

# Constants
DIRECTIONS = ["N", "E", "S", "W"]
MOVEMENT = {"N" => [0, 1], "E" => [1, 0], "S" => [0, -1], "W" => [-1, 0]}

def run()
    scen = Scenario.new
    begin
        scen.get_grid()
        scen.get_rovers()
        scen.valid?()
        scen.display()
    rescue ArgumentError => e
        #if any of the inputs cause an exception we would print the error message.
        #It is up to the user to change the inputs and try again, this script is not about prompting for inputs
        puts(e)
    end
end

class Scenario 
    attr_accessor :grid_x, :grid_y, :rovers

    def get_grid()
        #grab the first line and remove from stack, this makes it easier to process the rovers two lines at a time.
        grid = gets.chomp
        # First do a regex format check. Doing this later in the .valid? method could open up the app for unnecesery errors.
        raise ArgumentError, 'Invalid grid coordinates' unless grid =~ /^\d+\s\d+$/

        # assign the grid values to the scenario variables
        self.grid_x, self.grid_y = grid.split(" ").map{|x| x.to_i}
    end

    def get_rovers()
        STDIN.each_slice(2).each_with_index do |lines, i|
            # Grab the two lines, but make sure to remove any newline characters as well to reduce chance of errors.
            start, instructions = lines.map{|x| x.delete("\n")}
            # First do a regex format check. Doing this later in the .valid? method could open up the app for unnecesery errors.
            raise ArgumentError, 'Invalid start coordinates' unless start =~ /^\d+\s\d+\s[N|E|S|W]$/
            raise ArgumentError, 'Invalid instructions given' unless instructions =~ /^[L|R|M]+$/
            # Create the rover
            r = Rover.new(i, start, instructions)
            # Store the rover to the scenario if it is valid, raise an exception and exit if it is not.
            rovers << r if r.valid?
        end
    end

    def valid?
        #This valid check is to see the validity of the the entire scenario after we added the rovers.

        # Ensure in bounds.
        # build a hash so we can grab all locations and run them against the 
        r_hash = Rover.all.collect{|r| {id: r.id, coordinates: [r.start, r.movements].flatten.map{|c| c.split[0..1].join(" ")}}}
        # run through all the calculated coordinates and
        out_bounds = r_hash.find{|r| r[:coordinates].find{|f| f.split.find{|x, y| !x.to_i.between?(0, grid_x) || !y.to_i.between?(0, grid_y) } }} rescue nil
        raise ArgumentError, "Rover ##{out_bounds[:id]} would go out of bounds. Aborting" if out_bounds
    end

    def display()
        objects = Rover.all
        # objects_simple_start = objects.collect{|x| x.start}.map{|o| o.split[0..1].join(" ")}
        objects_simple_end = objects.collect{|x| x.movements.last}.map{|o| o.split[0..1].join(" ")}
        output = "" # All output gets stored to this variable
        bottom_num = "   " # Holds the x axis numbers
        horizonal_line = "" # Holds the horizontal line, we declare this her so we can use it for the last line after the final loop
        (0..grid_y).to_a.reverse.each do |y_i|
            horizonal_line = "  " # Add padding, this is required for the table to aline with visible numbers
            container_row = "#{y_i} " #  Add the numbers for the y axis info
            (0..grid_x).to_a.each do |x_i|
                horizonal_line += "+--" # Build the horizonal line
                container_row += "|" # Build the vertical lines
                cur_location = [x_i, y_i].join(" ") # Build current coordinates
                container_row += objects_simple_end.include?(cur_location) ? "##{objects_simple_end.index(cur_location)}" : "  " #Add the spacing between vert lines, or add location info
            end
            output += horizonal_line + "+\n"
            output += container_row + "|\n"
            # Add the numbers for the x axis info that gets appennded last
        end
        output += horizonal_line + "+\n"
        output += bottom_num + (0..grid_x).to_a.join("  ") + "\n"
        # output += bottom_num + "\n"
        print(output)
        puts Rover.all.map(&:to_s)
    end
end

class Rover
    attr_accessor :id, :start, :instructions, :movements

    def initialize(id, start, instructions)
        @id = id
        @start = start
        @instructions = instructions
        @movements = calulate_movements(start, instructions) rescue []
    end

    def to_s
        s = "Rover ##{id}, Start location: #{start}, Instruction set: #{instructions}"
        s += self.movements.nil? ? "" : ", End location: #{self.movements.last}"
    end

    def valid?(scenario=nil)
        prev_rovers = Rover.all.select{|x| x.id != self.id}
        
        all_starts = prev_rovers.collect{|x| x.start.split[0..1].join(" ")}
        this_start = self.start.split[0..1].join(" ")
        raise ArgumentError, "Rover ##{self.id} cannot start on same location as Rover ##{all_starts.index(this_start)}  " if all_starts.include?(this_start)
        
        all_ends = prev_rovers.collect{|x| x.movements.last.split[0..1].join(" ")}
        colission = all_ends & self.movements_simple
        raise ArgumentError, "Rover ##{self.id} will collide with Rover ##{all_ends.index(colission.first)} at #{colission.first}" if colission.any?
    end

    def movements_simple
        self.movements.map{|x| x.split[0..1].join(" ")}
    end

    def self.all
        #ensure to sort by id to get data sequentially. Else the order will be lost as it is accessed through.
        ObjectSpace.each_object(self).to_a.sort_by(&:id)
    end

    def calulate_movements(start, instructions)
        movements = []
        position = start.split()
        instructions.split("").each do |i|
            case i
            when "L"
                position[2] = DIRECTIONS[DIRECTIONS.index(position[2]) - 1]
            when "R"
                position[2] = DIRECTIONS[DIRECTIONS.index(position[2]) + 1]
                position[2] ||= DIRECTIONS[0] # if there was no value from previous line we need to move to the beginning of the directions array again.
            when "M"
                position[0], position[1] = [position[0..1].map(&:to_i), MOVEMENT[position[2]] ].transpose.map(&:sum)
            end
            movements << position.join(" ")
        end
        movements
    end
end

run()