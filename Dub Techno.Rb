use_bpm 72


live_loop :chord_progression, delay: -1.0 / 32 do
  i = tick
  ch = chord(:d4, 'minor')
  ch = chord(:d4, 'm6') if i % 16 == 15
  ch = invert_chord(ch, 1) if i % 8 == 4
  set :chord, ch
  sleep 2
end

live_loop :drone do
  with_fx :ring_mod, mix: rand(0.6) do
    sample :ambi_drone, rate: 1.34 + rand(0.01), finish: 0.1, pan: 1 - rand(2)
    sleep 2
  end
end

live_loop :keys do
  i = tick
  if i % 32 > 23
    release = line(0.2, 0.7, steps: 23).mirror.tick(:l)
    cutoff = line(90, 120, steps: 19).mirror.tick(:c)
    res = line(0.01, 0.95, steps: 17).mirror.tick(:r)
    with_fx :slicer do
      with_fx :rhpf, res: res, cutoff: 70 + rand_i(10) do
        synth :beep, note: get[:chord], amp: 10, cutoff: cutoff, release: release, decay: 0.1, sustain_level: 0.1 if i % 4 == 0
        synth :tech_saws, note: get[:chord], amp: 10, cutoff: cutoff, release: release, decay: 0.1, sustain_level: 0.1  if i % 4 == 0
        
        synth :beep, note: get[:chord], amp: 2, cutoff: cutoff +3, release: release + 0.05, decay: 0.1, sustain_level: 0.1 if i % 4 == 3
        synth :tech_saws, note: get[:chord], amp: 2, cutoff: cutoff +3, release: release + 0.05, decay: 0.1, sustain_level: 0.1 if i % 4 == 3
      end
    end
  end
  sleep 0.125
end

live_loop :bass do
  cutoff = (line 70, 110, steps: 8).mirror.tick(:c)
  with_fx :ixi_techno, cutoff_min: cutoff, phase: 16 do
    (16 * 8).times do
      i = tick
      synth :fm, depth: 3, note: get[:chord][1] -12, release: 0.1 if i % 8 == 0
      synth :fm, depth: 4, note: get[:chord][0] -12, release: 0.1, amp: 0.5 if i % 4 == 2
      synth :fm, depth: 6, note: get[:chord][3] -24, release: 0.1, amp: 0.4 if i % 7 == 3
      sleep 0.125
    end
  end
end

live_loop :drums2 do
  with_fx :panslicer, pan_min: -0.4, pan_max: 0.4, phase: 32, wave: 3 do
    (32 * 8).times do
      sample :elec_wood, amp: [0.25, 0.1, 0.1, 0.1].ring.tick, finish: 0.05 + rand(0.1)
      sleep 0.125
    end
  end
end



live_loop :drums do
  mix = (Array.new(6, 0) + line(0.2, 1.0, steps: 5).to_a + Array.new(6, 1)).ring.mirror
  print mix
  with_fx :reverb, mix: 0.2 do
    with_fx :bitcrusher, mix: mix.tick(:m)  do
      16.times do
        i = tick
        synth :bnoise , release: 0.1,  amp: 3 if i%32 == 0
        synth :beep, note: :d0, amp: 7, release: 0.15 if i % 4 == 0
        synth :pulse, note: :d0, amp: 0.7, release: 0.1 if i % 8 == 0
        sample :bd_tek if i % 16 ==4
        sample :bd_tek, rate: 0.9, amp: 0.1, finish: 0.3 if i % 16 ==5
        sample :bd_tek, rate: 0.8, amp: 0.05, finish: 0.3  if i % 16 ==6
        sample :bd_tek, rate: 0.7, amp: 0.05, finish: 0.3  if i % 16 ==7
        sample :elec_filt_snare, rate: -1.5, amp: 0.7 if i%32 == 8
        synth :cnoise , release: 0.1,  amp: 5 if i%32 == 16
        sample :elec_chime, finish: 0.1, rate: 2, amp: 0.2 if i % 4 == 2
        sample :elec_chime, finish: 0.05, rate: 2, amp: 0.1 if i % 8 == 3
        sleep 0.125
      end
    end
  end
end
