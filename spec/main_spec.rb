require 'spec_helper'
require_relative '../main'

VALID_OUTPUT = <<~TEXT
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
  Rover #0, Start location: 1 2 N, Instruction set: LMLMLMLMM, End location: 1 3 N
  Rover #1, Start location: 3 3 E, Instruction set: MMRMMRMRRM, End location: 5 1 E
TEXT

describe Scenario do
  before :each do
    @scenario = Scenario.new
  end

  describe 'parse_grid' do
    it 'should throw an exception when no arguements given.' do
      expect { @scenario.parse_grid }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
    end

    it 'should throw an exception when invalid arguements given.' do
      grid = 'invalid'
      expect { @scenario.parse_grid(grid) }.to raise_error(ArgumentError, 'Invalid grid coordinates')
    end

    it 'should return an array with two integers when valid grid given.' do
      grid = '55 55'
      expect(@scenario.parse_grid(grid)).to eq([55, 55])
    end

    it 'should return an array with two integers when valid grid give that contains large numbers.' do
      grid = '54444445 5555555'
      expect(@scenario.parse_grid(grid)).to eq([54_444_445, 5_555_555])
    end
  end

  describe '.add_rover' do
    it 'should throw an exception when no arguements given.' do
      expect { @scenario.add_rover }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 2)')
    end

    it 'should throw an exception when invalid start cooirdinates given.' do
      lines = ['1 W N', 'LMLM']
      index = 0
      expect { @scenario.add_rover(lines, index) }.to raise_error(ArgumentError, 'Invalid start coordinates')
    end

    it 'should throw an exception when invalid start cooirdinates given.' do
      lines = ['1 5 X', 'LMLM']
      index = 0
      expect { @scenario.add_rover(lines, index) }.to raise_error(ArgumentError, 'Invalid start coordinates')
    end

    it 'should throw an exception when invalid instructions given.' do
      lines = ['1 1 N', 'LMXLM']
      index = 0
      expect { @scenario.add_rover(lines, index) }.to raise_error(ArgumentError, 'Invalid instructions given')
    end

    it 'should return an array with two integers when valid grid given.' do
      lines = ['1 1 N', 'LMLM']
      index = 0
      expect(@scenario.add_rover(lines, index)).to be_a(Rover)
    end
  end

  describe '.valid?' do
    it 'should throw an exception when no rovers are added to the Scenario' do
      @scenario.parse_grid('5 5')
      expect { @scenario.valid? }.to raise_error(ArgumentError, 'No rovers given')
    end

    it 'should throw an exception when rovers go out of bounds' do
      @scenario.parse_grid('2 2')
      @scenario.add_rover(['1 1 N', 'MMM'], 0)
      expect { @scenario.valid? }.to raise_error(ArgumentError, 'Rover #0 would go out of bounds. Aborting')
    end

    it 'should return true when the scnario is valid' do
      @scenario = Scenario.new
      @scenario.parse_grid('3 3')
      @scenario.add_rover(['1 1 N', 'M'], 0)
      expect(@scenario.valid?).to eq(true)
    end
  end

  describe '.get_display' do
    it 'should return a string output that draws a graph in the terminal' do
      @scenario.parse_grid('5 5')
      @scenario.add_rover(['1 2 N', 'LMLMLMLMM'], 0)
      @scenario.add_rover(['3 3 E', 'MMRMMRMRRM'], 1)
      expect(@scenario.display).to eq(VALID_OUTPUT)
    end
  end
end

describe Rover do
  before :each do
    @rover = Rover.new(0, '1 1 N', 'MMM')
  end

  describe 'initilize' do
    it 'it should throw an ArgumentError if no arguments are given' do
      expect { Rover.new }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 3)')
    end

    it 'it should NOT throw an ArgumentError if any inputs given' do
      expect(Rover.new('x', 'y', 'z')).to be_a(Rover)
    end
  end

  describe 'to_s' do
    it 'should return a human readable string of the rovers input and end location' do
      expect(@rover.to_s).to eq('Rover #0, Start location: 1 1 N, Instruction set: MMM, End location: 1 4 N')
    end
  end

  describe 'valid?' do
    # TODO: rework
    # it 'it should throw an ArgumentError if two rovers start at the same location' do
    #   expect { Rover.new }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 3)")
    # end

    # TODO: rework
    # it 'it should throw an ArgumentError if two rovers will collide after previous rovers moved' do
    #   expect { Rover.new }.to raise_error(ArgumentError, "wrong number of arguments (given 0, expected 3)")
    # end
  end

  describe '.calculate_movements' do
    it 'calculates the every movement step and saves to movements' do
      expect(@rover.calculate_movements).to eq(['1 2 N', '1 3 N', '1 4 N'])
    end
  end
end
