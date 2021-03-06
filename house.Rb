live_loop :kick do
  with_fx :reverb, mix: 0.2 do
    with_fx :lpf do
      8.times do |i|
        synth :fm, note: [:a1, :b1, :a1, :c2].ring.tick(), divisor: 3, release: 0.1, amp: 0.7, depth:  line(2, 5, steps: 32).mirror.look()  if i % 2 == 0
        synth :fm, note: :a2, amp: 0.4 if i %8 == 3
        sleep 0.25
      end
    end
  end
end

live_loop :hh do
  sync "/live_loop/kick"
  with_fx :echo, phase: 0.125, decay: 0.25, mix: 0.2 do
    with_fx :hpf, cutoff: line(100, 110).mirror.look do
      7.times do |i|
        sleep 0.25
        synth :bnoise, release: 0.08, amp: 0.3 + rand(0.1) if i %2 == 0 and i % 5 != 2
      end
    end
  end
end

live_loop :kick2 do
  sync "/live_loop/kick"
  with_fx :bpf, centre: 90, mix: 0.95 do
    5.times do
      sample :bd_tek
      sleep 1.0 / 3
    end
  end
end

live_loop :bass1 do
  sync "/live_loop/kick"
  synth :fm, note: :c2
  sleep 1.0 / 3
  synth :fm, note: :g2, amp: 0.6, depth: 1
end

live_loop :blade do
  sync "/live_loop/kick"
  i = tick
  mix1 = ([0.3] * 4 + line(0.3, 0.7, steps: 8) + [0.7] * 4).ring.mirror
  mix2 = ([0.8] * 4 + line(0.8, 0.2, steps: 8) + [0.2] * 4).ring.mirror
  with_fx :wobble, mix: 0.5 do
    with_fx :whammy, mix: mix1[i] do
      with_fx :flanger, mix: mix2[i] do
        sleep 0.9
        synth :blade, note: [:c3, :a2].ring[i], amp: 0.1, attack: 0.25, cutoff: line(80, 120, steps: 8).mirror[i], vibrato_depth: 0.5 + rand(0.2), pan: rand(0.5) - 0.25
      end
    end
  end
end

live_loop :pad do
  sync "/live_loop/kick"
  with_fx :gverb, mix: 0.3 do
    synth :dark_ambience, note: [:g4, :d4, :c4,:d4].ring.tick, release: 2, attack: 0.25, amp: 0.25
    sleep 1
  end
end

live_loop :keys do
  with_fx :reverb do
    with_fx :echo, decay: 8, phase: 1, mix: 0.2 do
      with_fx :bpf, centre: line(80, 110, steps: 32).mirror.tick(:a), mix: 0.9 do
        
        sync "/live_loop/kick"
        divisor = [1, 2, 3].ring.tick(:q)
        5.times do
          2.times do
            synth :fm, note: [:b4, :b4,  :g4,  :d4, :g5].ring.tick, depth: 2, amp: [0.1, 0.05].ring.look, divisor: divisor
            sleep 0.25
          end
        end
      end
    end
  end
end

live_loop :keys2 do
  
  with_fx :reverb do
    with_fx :echo, decay: 8, phase: 1, mix: 0.3 do
      with_fx :bpf, centre: line(80, 110, steps: 32).mirror.tick(:a), mix: 0.9 do
        
        sync "/live_loop/kick"
        divisor = [3, 2, 1, 3].ring.tick(:q)
        4.times do
          sleep 2.0 / 3
          synth :fm, note: [:b4,  :a4, :e4, :g5].ring.tick, depth: 2, amp: 0.07, divisor: divisor
        end
      end
    end
  end
end


