
#Change here!
@SAMPLES_DIR="/Users/artem/my-projects/algorave/samples/"
use_bpm 65

def my_live_loop(name)
  in_thread do
    with_fx :level, amp:0 do |level_control|
      set name.to_s.concat("_level"), level_control
      loop do
        yield
      end
    end
  end
end

def linear_slide(from, to, duration)
  ((0...duration).to_a.map {|x| x * (to - from) / duration + from}).ring
end

live_loop :chord_progression, delay: -1.0 / 32 do
  set :chord, chord(:f2, :madd11)
  sleep 4
  set :chord, chord(:c2, :madd11)
  sleep 4
end

my_live_loop :bd do
  with_fx :ixi_techno, cutoff_min: 70, cutoff_max: 120, phase: 64 * 2 do
    rate_m = [1, 1.5].choose
    rates = [rate_m, rate_m, -rate_m].ring
    if one_in(2)
      rates = rates.reverse
    end
    if one_in(2)
      rates = rates.mirror
    end
    8.times do
      sample :bd_haus, amp: 0.8 + rand(0.1)
      sleep 0.5
      3.times do
        sample :bd_pure,
          rate: rates.tick(:r), amp: rand(0.4) + 0.3
        sleep 0.25
        if one_in(4)
          sample :bd_pure, amp: rand(0.4), rate: [1, 1, -1].choose
        end
        sleep 0.25
      end
      
    end
  end
end

my_live_loop :bass do
  reverbs = linear_slide(0.0, 0.8, 6).mirror
  with_fx :reverb, room: 1.0 do |rev|
    control rev, room: reverbs.tick(:c)
    pattern = [rand_i(7), rand_i(7), rand_i(7), rand_i(7), rand_i(7)].ring
    amps = [0.4, 1].ring
    32.times do
      synth :supersaw, note: get[:chord][pattern.tick], amp: amps.tick(:v), release: 0.04 + rand(0.05), res: 0.4 + reverbs.tick(:c) / 2
      synth :supersaw, note: get[:chord][pattern.look] - 12, amp: amps.tick(:v) / 2.0, release: 0.02 + rand(0.05), res: 0.9 - reverbs.tick(:c) / 2
      sleep 0.25
    end
  end
end

def snare(division, amp)
  with_fx :whammy, mix: get[:sn_whammy_mix] do
    with_fx :wobble, phase: 8, mix: get[:sn_wobble_mix] do
      sounds = [:sn_zome, :sn_dolf].ring
      start = rand(0.1)
      4.times do
        division.times do
          sample sounds.tick(:sn), amp: amp, finish: start + 0.1, start: start, compress: 1, norm: 1
          sleep 2.0 / division
        end
      end
    end
  end
end

my_live_loop :snare2 do
  snare(2, 0.3)
end

my_live_loop :snare3 do
  snare(3, 0.2)
end

my_live_loop :snare5 do
  snare(5, 0.1)
end

my_live_loop :snare16 do
  snare(16, 0.1)
end

my_live_loop :synth do
  pattern = [rand_i(7), rand_i(7), rand_i(7), rand_i(7)].ring
  octave = [24, 12].ring.reflect
  with_fx :gverb, mix: 0.1, room: 5 do
    with_fx :echo, phase: 1.0 / 3, mix: 0.3 do
      with_fx :echo, phase: 0.75, mix: 0.8 do
        32.times do
          synth :pulse, pulse_width: 0.8, note: get[:chord][pattern.tick] + octave.tick(:o), amp: 0.05 + rand(0.05)
          sleep 0.5
        end
      end
    end
  end
end


my_live_loop :perc do
  
  amps = [0.15, 0.4].ring
  repeats_ring = [2, 3, 5].ring
  sounds = [:loop_amen, :loop_industrial].ring
  sound = sounds.tick(:s)
  32.times do
    sleep 0.25
    sample sound, finish: 0.01 + rand(0.01), amp: amps.tick() + rand(0.05)
    if one_in(4)
      repeats = repeats_ring.tick(:r)
      repeats.times do
        sample sound, finish: 0.005, amp: rand(0.1) + 0.01
        sleep 0.25 / repeats
      end
    else
      sleep 0.25
    end
  end
end

my_live_loop :glitch_train do
  with_fx :panslicer, wave: 3, phase: 4, phase_offset: rand(0.98) + 0.01 do
    with_fx :echo, phase: 1.0 / 12, decay: 3 do
      with_fx :krush, mix: 0.5 do
        synth :mod_dsaw, note: get[:chord].choose, release: 0.8, amp: 0.1, detune: 0.5
      end
      sleep 4
    end
  end
end

my_live_loop :bam do
  sample :bd_tek
  if one_in(8)
    division = [2, 3].choose
    division.times do
      sample :bd_tek, amp: 0.5, finish: 0.5
      sleep 0.5 / division
    end
  else
    sleep 0.5
  end
end

my_live_loop :algorave do
  with_fx :echo, mix: 0.15, decay: 1.0 do
    with_fx :slicer, pulse_width: 0.75, phase: 1.0 / [8, 12].choose(), mix: 1 do
      if one_in(3)
        sample @SAMPLES_DIR + "algorave.wav", start: 0.53, rate: 1.5,  rpitch: get[:chord][[0, 1].choose] - 12 * 3.5, amp: 0.4 +rand(0.2), pan: rand(1.6) - 0.8
        sleep 2.0
        sample @SAMPLES_DIR + "repetition.wav", start: 0.55, rate: 1.5, rpitch: get[:chord][[0, 1].choose]- 12 * 3.3, amp:  0.4 +rand(0.2), pan: rand(1.6) - 0.8
      else
        sample @SAMPLES_DIR + "repetition.wav", start: 0.55, rate: 1.5, rpitch: get[:chord][[0, 1].choose]- 12 * 3.3, amp:  0.4 +rand(0.2), pan: rand(1.6) - 0.8
      end
      if one_in(8)
        sleep 1
      else
        sleep 2
      end
    end
  end
end

my_live_loop :algorave2 do
  with_fx :lpf, cutoff: 110 do
    with_fx :reverb, room: 0.7, mix: 0.8 do
      sleep 0.5
      if one_in(32)
        sample @SAMPLES_DIR + "algorave.wav", start: 0.53, rate: 2,  rpitch: get[:chord][[0, 1].choose] - 12 * 4, amp: 0.5 +rand(0.2)
        sleep 2
      end
      if one_in(16)
        sample @SAMPLES_DIR + "repetition.wav", start: 0.55, rate: 2, rpitch: get[:chord][[0, 1].choose]- 12 * 4, amp:  0.5 +rand(0.2)
        sleep 2
      end
      sleep 1
    end
  end
end


def mix()
  set_volume! 1
  set :sn_wobble_mix, 0.0
  set :sn_whammy_mix, 0.0
  
  control get["bd_level"], amp: 1.0
  control get["snare2_level"], amp: 1.0
  control get["algorave_level"], amp: 0.5
  increase = linear_slide(0.0, 0.5, 33)
  32.times do
    control get["bass_level"], amp: increase.tick(:bass)
    control get["algorave_level"], amp: 0.5 -increase.look(:bass)
    sleep 1
  end
  sample :glitch_perc1
  control get["bass_level"], amp: 0.5
  control get["algorave_level"], amp: 0
  control get["perc_level"], amp: 1.0
  sleep 32
  sample :glitch_perc2
  control get["snare3_level"], amp: 1.0
  control get["snare5_level"], amp: 1.0
  sleep 32
  sample :glitch_perc3
  increase = linear_slide(0.05, 0.2, 33)
  increase2 = linear_slide(0.5, 0.75, 33)
  
  32.times do
    control get["synth_level"], amp: increase.tick(:synth)
    control get["bass_level"], amp: increase2.look(:synth)
    sleep 1
  end
  sample :glitch_perc4
  set :sn_whammy_mix, 0.15
  control get["snare16_level"], amp: 1.0
  sleep 32
  sample :glitch_perc5
  set :sn_wobble_mix, 0.5
  control get["glitch_train_level"], amp: 0.45
  decrease = linear_slide(0.07, 0.2, 33).reverse
  32.times do
    control get["synth_level"], amp: decrease.tick(:s2)
    sleep 1
  end
  sample :glitch_perc1
  control get["bam_level"], amp: 1.0
  sleep 64
  sample :glitch_perc4
  increase = linear_slide(0, 0.4, 33)
  increase2 = linear_slide(0.07, 0.3, 33)
  increase3 = linear_slide(0.75, 0.85, 33)
  32.times do
    control get["algorave_level"], amp: increase.tick(:ar)
    control get["algorave2_level"], amp: increase.look(:ar)
    control get["synth_level"], amp: increase2.look(:ar)
    control get["bass_level"], amp: increase3.look(:ar)
    sleep 1
  end
  sample :glitch_perc3
  set :sn_whammy_mix, 0.45
  set :sn_wobble_mix, 0.7
  control get["glitch_train_level"], amp: 0.7
  control get["synth_level"], amp: 0
  sleep 16
  sample :drum_cowbell, amp: 0.05, finish: 0.5
  control get["snare2_level"], amp: 0.0
  control get["snare3_level"], amp: 0.0
  control get["snare5_level"], amp: 0.0
  control get["snare16_level"], amp: 0.0
  control get["algorave2_level"], amp: 0
  control get["algorave_level"], amp: 0.2
  
  decrease = linear_slide(0.0, 1.0, 17).reverse
  decrease2 = linear_slide(0.1, 0.85, 17).reverse
  
  16.times do
    control get["glitch_train_level"], amp: decrease.tick(:ar2) * 0.7
    
    control get["bass_level"], amp: decrease2.look(:ar2)
    sleep 1
  end
  sample :drum_cowbell, amp: 0.05, finish: 0.5
  control get["snare2_level"], amp: 0.0
  control get["bd_level"], amp: 0.1
  decrease = linear_slide(0.02, 1.0, 33).reverse
  
  32.times do
    control get["algorave_level"], amp: decrease.tick(:ar3) * 0.2
    control get["bass_level"], amp: decrease.look(:ar3) * 0.1
    control get["bd_level"], amp: decrease.look(:ar3) * 0.1
    control get["perc_level"], amp: decrease.look(:ar3)
    control get["bam_level"], amp: decrease.look(:ar3)
    sleep 1
  end
  set_volume! 0
  set :sn_wobble_mix, 0.0
  set :sn_whammy_mix, 0.0
  
  
end

sleep 1
mix
