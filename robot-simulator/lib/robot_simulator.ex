defmodule RobotSimulator do
  defmodule Robot do
    defstruct direction: :north, position: {0, 0}
  end

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: Robot
  def create(direction \\ :north, position \\ {0, 0})

  def create(direction, _)
      when direction not in [:north, :east, :south, :west] do
    {:error, "invalid direction"}
  end

  def create(direction, {x, y} = position) when is_number(x) and is_number(y) do
    %Robot{direction: direction, position: position}
  end

  def create(_, _) do
    {:error, "invalid position"}
  end

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: Robot, instructions :: String.t()) :: Robot
  def simulate(robot, ""), do: robot

  def simulate(robot, instructions) do
    {instruction, next_instructions} = String.split_at(instructions, 1)

    case process_instruction(robot, instruction) do
      {:ok, new_robot} -> simulate(new_robot, next_instructions)
      error -> error
    end
  end

  defp process_instruction(robot, "A"), do: {:ok, advance(robot)}
  defp process_instruction(robot, "L"), do: {:ok, turn_left(robot)}
  defp process_instruction(robot, "R"), do: {:ok, turn_right(robot)}
  defp process_instruction(_, _), do: {:error, "invalid instruction"}

  defp advance(%Robot{position: {x, y}} = robot) do
    new_position =
      case robot.direction do
        :east -> {x + 1, y}
        :west -> {x - 1, y}
        :north -> {x, y + 1}
        :south -> {x, y - 1}
      end

    %{robot | position: new_position}
  end

  defp turn_left(robot) do
    new_direction =
      case robot.direction do
        :north -> :west
        :south -> :east
        :east -> :north
        :west -> :south
      end

    %{robot | direction: new_direction}
  end

  defp turn_right(robot) do
    new_direction =
      case robot.direction do
        :north -> :east
        :south -> :west
        :east -> :south
        :west -> :north
      end

    %{robot | direction: new_direction}
  end

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: Robot) :: atom
  def direction(robot) do
    robot.direction
  end

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: Robot) :: {integer, integer}
  def position(robot) do
    robot.position
  end
end
