use_bpm 68
set :pad_cutoff, 40; set :bass_speed, 4; set :keys_detune, 0.2

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
  chords = [ chord(:b2, :minor7, num_octaves: 2, invert: 1),
             chord(:A2, :major7,  num_octaves: 2),
             chord(:F2 + 1, :minor7,  num_octaves: 2),
             one_in(3) ? chord(:E2, :major7,  num_octaves: 2): chord(:G2, :major7,  num_octaves: 2)].ring
  set :chord, chords.tick(:l)
  sleep 4
end

my_live_loop :pad do
  amps=[0.5, 0.2, 0.4, 0.1].ring
  with_fx :ixi_techno, cutoff_min: get[:pad_cutoff], mix: 0.9, phase: 16 do
    with_fx :reverb, mix: 0.6 do
      with_fx :echo, mix: 0.7, decay: 4 do
        synth :blade, attack: 0.15, decay: 0.2, release: 1, note: get[:chord].choose, amp: amps.tick + rand(0.1), pan: 0.1
        synth :sine, attack: 0.05, decay: 0.2, release: 0.5, note: get[:chord].choose, amp: amps.tick / 2 + rand(0.1), pan: -0.1
        sleep 0.25
      end
    end
  end
end

my_live_loop :keys do
  pattern = (Array.new(6) { |i| rand_i 10}).ring
  4.times do
    sleep 1
    with_fx :echo, phase: 0.25, decay: 4 do
      pan = rand(1.4) - 0.7
      12.times do
        synth :dsaw, note: get[:chord][pattern.tick] + 12, release: 0.1, amp: 0.4 + rand(0.1), detune: get[:keys_detune], pan: pan
        sleep 1.0 / 12
      end
    end
    sleep 2
  end
end

my_live_loop :bass do
  pattern = [0, 1, 2, 3].ring
  patern = pattern.shuffle if one_in(3)
  patern = pattern.reverse if one_in(2)
  patern = pattern.mirror if one_in(3)
  cycle = 7
  skips = (Array.new(3) { |i| rand_i cycle})
  32.times do
    i = tick
    note = get[:chord][pattern.look]
    if i % 4 == 2 or not skips.include? i % cycle and not one_in(32)
      synth :fm, depth: 3, release: 0.5, amp: i % 8 == 2 ? 2 : 1, note: [note, note-12]
    end
    sleep 1.0 / get[:bass_speed]
  end
end

my_live_loop :kick do
  sample :bd_fat, amp: 1, rate: one_in(16) ? -1 : 1
  sleep 0.5
end

my_live_loop :bells do
  cutoffs = linear_slide(50, 90, 512)
  with_fx :compressor do
    with_fx :hpf, cutoff: cutoffs.tick(:c) do
      i = tick
      sample :elec_pop, rate: 1 + rand(0.06), amp: 0.3 + rand(0.5), start: rand(0.05), finish: 0.1 + rand(0.1), finish: 0.4, pan: rand(0.2) - 0.1 if (i % 4 == 2 or i % 5 == 2)
      sleep 0.125
    end
  end
end

my_live_loop :main_drums do
  with_fx :compressor, mix: 0.1 do
    i = tick
    sample :drum_snare_soft, finish: 0.3 + rand(0.4), amp: 0.4 + rand(0.2), rate: one_in(2) ? 0.9 : 0.7 if (i % 8 == 4 and not i % 19 == 8)
    sample :bd_tek, amp: 0.4, finish: 0.5, rate: one_in(4) ? -1 : 0.9 if (i % 2 == 1 and i % 3 == 1)
    sample :bd_fat, amp: 0.8 if (i % 33 > 17 and i % 33 < 22)
    sleep 0.125
  end
end


my_live_loop :glitch do
  with_fx :echo do
    sample [:glitch_perc3, :glitch_perc2].choose, rate: 0.08, rpitch: [45, 50].choose()
    sleep 2
    sample [:glitch_perc3, :glitch_perc2].choose, amp: 0.5, rate: 0.05, rpitch: [45, 50].choose()
    sleep 2
  end
  sleep 4
end

my_live_loop :beep do
  sleep 0.5
  sample :elec_chime, finish: 0.1, amp: 0.8
  sleep 0.5
end

my_live_loop :beep2 do
  sleep 0.25
  sample :elec_chime, finish: 0.1, amp: 0.4, rate: 1.5
  sleep one_in(8) ? 0.125 : 0.25
end


my_live_loop :scratch do
  with_fx :wobble, cutoff_min: 80, phase: 32, mix: get[:scratch_mix, 0.8] do
    16.times do
      pan = rand(0.4) + 0.1
      with_fx :panslicer, phase: 8, wave: 3, invert_wave: one_in(2), pan_min: -pan, pan_max: pan do
        with_fx :whammy , mix: 0.1 do
          sleep 4
          rates = linear_slide(1, 1.4, 33)
          rates = rates.reverse if one_in 2
          with_fx :reverb do
            32.times do
              i = tick
              unless one_in 2
                start = rand(0.2)
                sample :glitch_robot1, finish: start + 0.05, start: start, rate: [1, -2].choose unless i % 5 == 2 or i % 9 == 3
              else
                start = rand(0.1) + 0.2
                sample :glitch_robot2, finish: start + 0.05, amp: 0.5 + rand(0.1), start: start, rate: [0.4, -0.5].choose unless i % 7 == 4 or i % 11 == 5
              end
              sample :elec_wood, finish: 0.1, amp: 0.7 + rand(0.2), rate: rates.look  unless i % 13 == 5 or i % 17 == 9
              sleep 4.0 / 32
            end
          end
        end
      end
    end
  end
end

my_live_loop :solo do
  pattern = (Array.new(8) { |i| rand_i 12}).ring
  with_fx :echo, phase: 5.0 / 8, decay: 2, mix: 0.8 do
    with_fx :echo, phase:  2.0 / 3, decay: 3, mix: 0.8 do
      16.times do
        octaves = [0, 12, 24, 12].ring
        synth :blade, note: get[:chord][pattern.tick()] + octaves.look, release: 0.05 + rand(0.1), vibrato_rate: 20, vibrato_depth: 0.5, amp: 0.7 + rand(0.2), pan: rand(0.1) - 0.05
        sleep 0.25
      end
    end
  end
end

def mix()
  set_volume! 1
  control get["kick_level"], amp: 0.5
  control get["bass_level"], amp: 0.1
  control get["pad_level"], amp: 0.05
  sleep 32
  set :bass_speed, 8
  increase = linear_slide(0, 1.0, 33)
  32.times do
    control get["main_drums_level"], amp: 0.1 + increase.tick(:p1) * 0.4
    control get["kick_level"], amp: 0.5  + increase.look(:p1) * 0.4
    sleep 1
  end
  set :bass_speed, 4
  32.times do
    control get["bells_level"], amp: 0.1 + increase.tick(:p2) * 0.2
    control get["bass_level"], amp: 0.1  + increase.look(:p2) * 0.4
    sleep 1
  end
  set :bass_speed, 8
  32.times do
    control get["keys_level"], amp: increase.tick(:p3) * 0.2
    sleep 1
  end
  32.times do
    control get["pan"], amp: 0.05 + increase.tick(:p3) * 0.35
    sleep 1
  end
  32.times do
    control get["glitch_level"], amp: increase.tick(:p4) * 0.2
    set :pad_cutoff, 40 + increase.look(:p4) * 20
    sleep 1
  end
  set :bass_speed, 4
  32.times do
    control get["pan"], amp: 0.4 + increase.tick(:p5) * 0.4
    set :pad_cutoff, 60 + increase.look(:p5) * 15
    control get["bells_level"], amp: 0.3 - increase.look(:p5) * 0.2
    sleep 1
  end
  32.times do
    set :pad_cutoff, 75 + increase.tick(:p6) * 35
    control get["keys_level"], amp: 0.1 + increase.look(:p6) * 0.2
    set :keys_detune, 0.2 + increase.look(:p6) * 0.15
    sleep 1
  end
  32.times do
    set :pad_cutoff, 110 - increase.tick(:p7) * 30
    control get["scratch_level"], amp: increase.look(:p7) * 0.3
    set :keys_detune, 0.35 - increase.look(:p7) * 0.3
    control get["glitch_level"], amp: 0.2 + increase.look(:p7) * 0.2
    sleep 1
  end
  set :scratch_mix, 0.4
  set :keys_detune, 0.2
  32.times do
    control get["main_drums_level"], amp: 0.5 - increase.tick(:p8) * 0.25
    control get["beep_level"], amp: increase.look(:p8) * 0.1
    control get["beep2_level"], amp: increase.look(:p8)* 0.1
    control get["bells_level"], amp: 0.1 + increase.look(:p1) * 0.1
    set :pad_cutoff, 80 - increase.look(:p8) * 10
    sleep 1
  end
  set :bass_speed, 8
  sleep 32
  set :bass_speed, 4
  32.times do
    set :pad_cutoff, 70 - increase.tick(:p9) * 15
    control get["scratch_level"], amp: 0.3 - increase.look(:p9) * 0.3
    control get["solo_level"], amp: increase.look(:p9) * 0.1
    sleep 1
  end
  32.times do
    control get["glitch_level"], amp: 0.4 - increase.tick(:p10) * 0.3
    control get["solo_level"], amp: 0.1 + increase.look(:p10) * 0.2
    control get["pan"], amp: 0.8 + increase.look(:p10) * 0.2
    control get["main_drums_level"], amp: 0.25 + increase.tick(:p10) * 0.2
  end
  sleep 32
  control get["main_drums_level"], amp: 0.5
  control get["beep_level"], amp: 0.03
  control get["beep2_level"], amp: 0.03
  control get["bells_level"], amp: 0.1
  control get["keys_level"], amp: 0.05
  set :bass_speed, 8
  sleep 32
  set :bass_speed, 4
  set :scratch_mix, 0.9
  control get["glitch_level"], amp: 0.5
  control get["scratch_level"], amp: 0.2
  increase = linear_slide(0, 1.0, 65)
  64.times do
    set_volume! 1.0 - 0.9 * increase.tick(:p11)
    sleep 1
  end
  set_volume! 0
end

sleep 7.92
mix
