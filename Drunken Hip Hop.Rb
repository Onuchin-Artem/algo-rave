use_bpm 40
@SAMPLES_DIR="/Users/artem/my-projects/algorave/samples/"

@shift = 0.0625

set :errors, [0, 0, +1, 0,-1, 0, -1, +1].ring

def play_drunk()
  if tick(:yo) % 64 * 2 == 0
    print "shuffle"
    set :errors, get[:errors].shuffle
  end
  i = tick
  sleep @shift if i % 64 == 0
  yield i
  sleep 0.125 + 0.03125 * get[:errors].tick(:time)
end

live_loop :shift do
  synth :tb303, note: [:a0, :c1].choose, release: 0.1, amp: 2.0 unless one_in 4
  sleep @shift
  sleep 8
end

chords = [chord(:a2, '9sus4', invert: 1),  chord(:e2 , 'minor7', invert: 1)].ring


live_loop :chord_progression, delay: -1.0 / 32 do
  chords1 = [
    [:c3, :f3, :a3, :c4, :e4].ring,
    [ :c3, :d3, :g3, :b3, :g4].ring,
    [ :a2, :e3, :a3, :c4, :e4].ring,
    [ :c3, :d3, :a3, :c4, :fs4].ring,
    [ :b2, :e3, :g3, :b3, :g4].ring
  ]
  chords2 = chords1.clone
  chords2[3] = [:g2, :c3, :d3, :g3, :ds4, :a4]
  chords = (chords1 + chords2).ring
  sleep @shift
  4.times do
    ch = chords.tick()
    ch = invert_chord(ch, 2) if one_in 4
    set :chord, ch
    sleep look() % 5 > 2 ? 1 : 2
  end
end

live_loop :pad do
  time = tick(:a)
  with_fx :lpf, cutoff: 120 do
    with_fx :hpf, cutoff: line(80, 110, steps: 8).mirror.tick(:c) do
      with_fx :reverb, room: 1 do
        with_fx :vowel, mix: 1.0, voice: 1 do
          16.times do
            play_drunk do |i|
              if time % 8 != 3  and i% 8 < 3 and i % 16 > 7
                synth :dtri, note: get[:chord].choose + 24, atack: 0.2, attack_level: 0.5, release: 1.0, amp: 1.0 +rand(0.5), detune: 0.3
              end
            end
          end
        end
      end
    end
  end
end


live_loop :piano do
  with_fx :ixi_techno, phase: 4, mix: 1, phase_offset: 0.0 do
    16.times do
      arpegio = [4, 3, 2, 0].ring
      play_drunk do |i|
        if i % 4 == 0 and (i + 7) * 11 % 3 > 0
          synth :pretty_bell, note: get[:chord][[4, 3].ring.tick(:n1)], release: 0.3, amp: 0.5 + rand(0.3)
        end
        if i % 8 > 3
          synth :dtri, note: get[:chord][arpegio.tick(:a)], release: 1.2,detune: 0.2, decay: 0.2, sustain: 0.2, sustain_level: 0.2, amp: rand(0.4)
          synth :beep, note: get[:chord][arpegio.tick(:a)] - 12, release: 1, attack: 0.5, env_curve: 7
        end
      end
    end
  end
end

live_loop :bass do
  arpegio = [0, 2, 4, 1, 3].ring
  with_fx :reverb, mix: 0.1 do
    with_fx :echo, mix: 0.2 do
      16.times do
        play_drunk do |i|
          note = arpegio.tick(:a)
          synth :fm, amp: [0.5, 0.8].ring.tick(:bass1), note: get[:chord][note] -24, depth: 4, divisor: 1 if i % 4 == 0
          synth :fm, amp: [0.5, 0.8].ring.tick(:bass2), note: get[:chord][note]  -24, depth: 4, divisor: 1 if i % 4 == 1 and (i + 7) * 11 % 3 == 2
          synth :fm, amp: [0.5, 0.8].ring.tick(:bass3), note: get[:chord][note]  -24, depth: 4, divisor: 1 if i % 32 > 28
        end
      end
    end
  end
end

live_loop :drum do
  play_drunk do |i|
    sample :bd_boom, amp: [2, 0.8].ring.tick(:bass1), rate: 1.5 if i % 4 == 0
    sample :bd_pure, amp: [2, 0.8].ring.tick(:bass2), rate: 1.6 if i % 4 == 1 and (i+ 7) * 11 % 3 == 2
    sample :bd_boom, amp: [2, 0.8].ring.tick(:bass3), rate: 1.7 if i % 32 > 28
    synth :cnoise, note: :c5 + rand_i(7), release: 0.1 if i % 8 == 4
    synth :cnoise, note: :c1 + rand_i(7), release: 0.05 if i % 16 == 2
    synth :pnoise, note: :a2 + rand_i(7), release: 0.05 if i % 16 > 8  and i % 8 < [ 2,3,4].choose
    sample :mehackit_phone1, finish: 0.05 + rand(0.04), rpitch: [-5, -3].ring.tick(:amb)  if i % 32 > 16  and i % 8 == 6
    sample :elec_cymbal, rate: 2, amp: [0.4, 0.8].ring.tick(:cymb), finish: 0.1 if i % 2 == 1 or one_in(4)
  end
end


live_loop :drum2 do
  sleep @shift
  8.times  do
    pan = 0.7 - rand(1.45)
    with_fx :lpf do
      with_fx :level, amp: 0.1 + rand(0.2) do
        64.times do
          synth [:bnoise, :cnoise, :blade].choose, note: rand_i(10), release: 0.01, pan: pan + rand(0.1)
          sleep 0.125 / 8.0
        end
      end
    end
  end
end
