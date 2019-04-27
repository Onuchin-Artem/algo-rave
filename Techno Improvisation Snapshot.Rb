use_bpm 70
@SAMPLES_DIR="/Users/artem/my-projects/algorave/samples/"


live_loop :chord_progression, delay: -1.0 / 32 do
  chords = [chord(:a3, 'minor7', invert: 1),  chord(:d3 , 'm6', invert: 1)].ring
  ch = chords.tick
  ch = invert_chord(ch, [1,2].choose) if one_in 4
  set :chord, ch
  sleep 2
end

live_loop :arpegio do
  depth = [1, 2, 3, 4].ring.mirror.tick(:d)
  with_fx :slicer, phase: 8, wave: 0, pulse_width: 0.75 do
    with_fx :echo, phase: 0.5 + 0.125 / 2, decay: 4 do
      with_fx :echo, phase: 0.125 * 3, decay: 4 do
        32.times do
          synth :fm, note: get[:chord].choose + 12, divisor: 2, depth: depth, release: 0.1 + rand(0.3), amp: 0.5 + rand(0.1)
          sleep 0.125
        end
      end
    end
  end
end

live_loop :wawes do
  with_fx :wobble, phase: 32 do
    with_fx :gverb do
      with_fx :echo, phase: 0.125 / 2, decay: 8 do
        with_fx :panslicer, phase: 16, wave: 3, offset: rand(0.1) do
          with_fx :slicer, phase: 16, wave: 3, pulse_width:  0.125 do
            128.times do
              synth [:cnoise, :bnoise, :bnoise, :subpulse].ring.tick, note: [:a1,:e1, :c2, :a2].choose, amp: rand(0.1), release: 1.2
              sleep 0.25
            end
          end
        end
      end
    end
  end
end


live_loop :bass do
  with_fx :reverb do
    with_fx :ixi_techno, mix: 0.3 do
      64.times do
        i = tick
        synth :subpulse, release: 0.8, note: get[:chord][0] - 36 if i % 4 == 2
        synth :tb303, release: rand(0.04), note: get[:chord][0] - 36 if i % 4 == 2 or (i % 16 > 12)
        sleep 0.125
      end
    end
  end
end

live_loop :glitch1 do
  with_fx :slicer do
    sample :ambi_drone
    sleep 8
  end
end

live_loop :glitch2 do
  with_fx :echo, decay: 6, phase: 0.125 do
    sleep  0.125
    sample :bass_drop_c, rpitch: 9, finish: 0.15, start: 0.1, rate: [-1, 1].choose
    sleep 7.75 + 0.125
  end
end


live_loop :drum do
  8.times do
    i = tick
    sample :bd_tek, amp: 1, rate: 1 + rand(0.3), pan: (line -1, 1, steps: 16).tick(:p) if i % 2 == 0 and  i % 32 < 24
    sample :bd_tek, amp: rand(1.0) unless i % 16 < 8
    sample :bd_gas, amp: 2 if i % 2 == 0
    synth :dull_bell, note: :a5, amp: [1, 0.6].ring.tick(:b), release: 0.05 + rand(0.1) if i % 4== 2 or i % 4== 1 or (i % 16 > 10 and i % 3 ==0)
    synth :cnoise, note: :a3, amp: 2, release: rand(0.1) if i % 8== 6
    synth :bnoise, note: :a5, amp: 2, release: 0.1 if i % 8== 0
    sleep 0.125
  end
end

