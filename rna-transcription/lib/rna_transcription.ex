defmodule RnaTranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RnaTranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def to_rna([]) do
    []
  end

  def to_rna([h | t]) do
    to_rna_one([h]) ++ to_rna(t)
  end

  @spec to_rna_one([char]) :: char
  def to_rna_one(dna) do
    case dna do
      'G' -> 'C'
      'C' -> 'G'
      'T' -> 'A'
      'A' -> 'U'
    end
  end

end
