def quicksort(array)
  if (array.empty?)
    return array
  end
  note = array[0]
  do_play(note)
  return quicksort(array.select {|x| x < note}) +
    [note]+
    quicksort(array.select {|x| x > note})
end

def do_play(number)
  amp = ((tick(:amp) % 4 == 0) ? 0.4 : 0.2) + rand(0.1)
  if (get[:chord][number] > 40)
    amp = amp / 4
  end
  synth :fm, note: get[:chord][number], amp: amp, release: 0.2 + rand(0.1), depth: 5, pan: 0.2 - rand(0.4)
  sleep 0.125
end

live_loop :quicksort, delay: -1.0 / 32 do
  with_fx :level, amp: amp do
    with_fx :nrlpf, res: 0.1  do
      set :chord, [chord(:a2, :minor7, num_octaves: 4), chord(:C2, :m9, num_octaves: 4)].ring.tick
      array = (1..64).to_a.shuffle
      array = quicksort(array)
      print array
    end
  end
end
