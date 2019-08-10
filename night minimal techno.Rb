live_loop :kick do
  8.times do |i|
    sample :bd_mehackit if i % 2 == 0
    synth :sine, note: :a1, release: rand(0.1) + 0.1
    sample :bd_boom if i %4== 0
    sample :bd_tek if i % 4 == 0
    
    sleep 0.25
  end
end

live_loop :kick2 do
  sync "/live_loop/kick"
  with_fx :echo, decay: 0.25, phase: 0.125, mix: line(0, 0.5, steps: 64).mirror.tick do
    7.times do |i|
      # synth :cnoise, note: :a0, release: 0.02, decay: 0.01 if i == 3 or i == 5 or i > 2
      sample :elec_chime, rate: 2.3 + rand(0.1), hpf: 90 + rand_i(20), finish: 0.1 if i ==6
      sleep 0.25
    end
  end
end

live_loop :kick3 do
  sync "/live_loop/kick"
  with_fx :reverb, mix: 0.6 do
    5.times do |i|
      synth :fm, note: [:a2].ring.tick, release: 0.1, depth: 4 + line(1, 5, steps: 128).mirror.look
      
      sleep 1.0/3
    end
  end
end


live_loop :kick89 do
  sync "/live_loop/kick"
  with_fx :bpf, centre: line(50, 120, steps: 32).tick do
    7.times do
      synth :chipnoise, release: 0.05, decay: 0.01
      sleep 0.25 / 3
      synth :chipnoise, release: 0.05, decay: 0.01
      sleep 0.5 / 3
    end
    synth :chipnoise, release: 0.1, decay: 0.01
    
  end
  
end

live_loop :kick98 do
  sync "/live_loop/kick"
  with_fx :gverb, mix: 0.7 do
    sleep 0.2
    synth :sine, note: [:b3, :gs3, :cs4, :ds4].ring.tick, release: 0.1,  amp: 0.5 + rand(0.1)
  end
end

live_loop :kick7 do
  sync "/live_loop/kick"
  synth :bnoise, release: 0.1
  sleep 0.5
  synth :bnoise, release: 0.1
  sleep 0.75
  synth :bnoise, release: 0.1
  
end

live_loop :kick4 do
  sync "/live_loop/kick"
  e = tick(:effect)
  with_fx :ring_mod, mix: [0.0, 0.1, 0.3, 0.5, 0.8, 0.7, 0.5, 0.1, 0.0].ring.mirror[e] do
    with_fx :flanger, mix: [0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.3, 0.5, 0.8].ring.mirror[e] do
      
      31.times do |i|
        # synth :tb303, note: [ :gs2].ring[i], amp: 0.4, release: 0.03, pulse_width: line(0.01, 0.99, steps: 16).mirror.tick if i % 8 ==7 or i % 6 ==0 or i % 16 > 14
        
        sleep 1.0/16
      end
    end
  end
end


live_loop :kick22 do
  sync "/live_loop/kick"
  with_fx :ixi_techno, mix: 0.5, phase: 2 do
    synth :bnoise, release: 0.02,res: 0.7
    
    with_fx :bpf, centre: 100 do
      
      15.times do
        sleep 0.125
        synth :bnoise, release: 0.02,res: 0.7
        
      end
    end
  end
end

