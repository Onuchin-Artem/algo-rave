use_bpm 63
@SAMPLES_DIR="/Users/artem/my-projects/algorave/samples/"
def wait_once(event)
  while get[event].nil?
    sleep 0.25
  end
  return get[event]
end

def reset_event(event)
  set event, nil
  sleep 0.1
end
set :chord, chord(:a2, :minor, num_octaves: 4)
set :invert, 0
reset_event(:quick)
reset_event(:rules)

def quicksort(array)
  if (array.empty?)
    return array
  end
  note = array.choose
  do_play(note)
  return quicksort(array.select {|x| x < note}) +
    [note] +
    quicksort(array.select {|x| x > note})
end

def do_play(number)
  amp = ((tick(:amp) % 4 == 0) ? 0.4 : 0.2) + rand(0.1)
  if (get[:chord][number] > 40)
    amp = amp / 4
  end
  synth :fm, note: get[:chord][number], amp: amp, release: 0.4 + rand(0.8), depth: 5, pan: 0.7 - rand(0.4)
  sleep 0.25
end

live_loop :quicksort, delay: -1.0 / 32 do
  amp = wait_once :quick
  with_fx :level, amp: amp do
    with_fx :nrlpf, res: 0.1  do
      ch = [chord(:a2, :minor7, num_octaves: 4), chord(:C2, :m9, num_octaves: 4)].ring.tick
      ch = chord_invert ch, get[:invert]
      set :chord, ch
      array = ((0...ch.count).to_a).shuffle
      array = quicksort(array)
      print array
    end
  end
end

live_loop :pad do
  with_fx :reverb, room: 1 do
    synth :hollow, note: get[:chord], amp: 3, attack: 0.5, release: 2
    sleep 1.0
  end
end

live_loop :drum do
  i = tick
  sample :bd_boom, amp: [2, 0.8].ring.tick(:bass), rate: 2 if i % 4 == 0
  sample :bd_klub, amp: [2, 0.8].ring.look(:bass), rate: 2 if i % 4 == 0
  synth  :fm, amp: [1, 0.6].ring.look(:bass), note: get[:chord][rand_i(2)], release: 0.5 if i % 4 == 0
  sample :sn_zome, amp: [0.9, 0.5].ring.tick(:sn1), rate: 0.8, finish: 0.2 if i % 16 == 9
  sample :sn_generic, amp: [2, 0.8].ring.tick(:sn2), rate: 2 + rand(0.1), pan: rand(0.2) - 0.1 if i % 8 == 4
  sample :elec_cymbal, rate: 2, amp: [0.4, 0.8].ring.tick(:cymb), finish: 0.1 if i % 2 == 1
  sleep 0.125 + 0.02 * [0, 0, +1, -1, 0, 0, -1, +1].ring.tick(:time)
end

live_loop :phrase do
  pan = get[:pan, 0]
  wait_once :rules
  with_fx :echo, phase: 1, decay: 4, mix: 0.3 do
    sample @SAMPLES_DIR + "quicksort.wav", start: 0.25, rate: 1.2, rpitch: -2, amp: 4,pan: pan
    sleep 4
  end
  pan = 0.7 - rand(1.4)
  set :pan, pan
  with_fx :ixi_techno, phase: 8, cutoff_min: 80 do
    64.times do
      start = 0.25 + rand(0.2)
      sample @SAMPLES_DIR + "quicksort.wav", start: start, finish: start + 0.05 + rand(0.05),  rate: [1.3, -1.2].choose, rpitch: -2, amp: rand(2) + 1, pan: pan
      sleep 0.0625 + [0.015, -0.015].ring().tick(:ra)
    end
  end
end

set_volume! 2

sleep 4
set :quick, 0.3
sleep 8
set :quick, 0.5
sleep 8
set :quick, 0.7
sleep 8
set :quick, 0.8
sleep 32
set :rules, 1.0
set :invert, 1
sleep 32
set :invert, 2
32.times do
  set_volume! (line 2.0, 0.0, steps: 33).ring.tick(:m)
  sleep 1
end

set_volume! 0
