use_bpm 92
set :kick_whammy, 0.6
set :kick_ixi, 0.5
set :boom_haf_wait, 1.0

def my_live_loop(name)
  in_thread do
    with_fx :level, amp: 0 do |level_control|
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
  sleep 1
end

def kickit(reverse = false, avg_amp = 1.0)
  sample :bd_808, amp: avg_amp, rate: reverse ? -1 : 1
  sample :bd_808, amp: 0.15 * avg_amp, rpitch: + 24, finish: 0.1
  sample :bd_808, amp: 0.5 * avg_amp, rpitch: + 12, rate: reverse ? -1 : 1
  sample :bd_808, amp: avg_amp, rpitch: -12
end

my_live_loop :kick do
  with_fx :ixi_techno, mix: get[:kick_ixi], cutoff_min: 80, cutoff_max: 110, phase: 16, phase_offset: 0.5 do
    with_fx :whammy, mix: get[:kick_whammy] do
      with_fx :reverb, room: 0.6, mix: 0.4 do
        with_fx :compressor, mix: 0.5 do
          with_fx :tanh, mix: 0.1 + rand(0.05) do
            16.times do
              if tick(:count) % 8 == 0
                repeat = [2, 3, 4].ring.tick(:repeat)
                repeat.times do
                  kickit(reverse = one_in(2), avg_amp = 0.5)
                  sleep 0.5 / repeat
                end
              else
                kickit(reverse = 1, avg_amp = 1)
                sleep 0.5
              end
            end
          end
        end
      end
    end
  end
end

my_live_loop :kick3 do
  with_fx :ixi_techno, mix: get[:kick_ixi], cutoff_min: 90, cutoff_max: 120, phase: 16, phase_offset: 0.0 do
    with_fx :reverb, mix: 0.1, room: 0.1 do
      32.times do
        sample :bd_tek, amp: [0.5, 1].ring.tick + rand(0.05), rpitch: -12 unless tick(:w) % 4 == 2
        sleep 1.0 / 4.0
      end
    end
  end
end

my_live_loop :kick2 do
  with_fx :ixi_techno, mix: get[:kick_ixi], cutoff_min: 90, cutoff_max: 120, phase: 16, phase_offset: 0.0 do
    with_fx :reverb, mix: 0.1, room: 0.1  do
      24.times do
        sample :bd_tek, amp: [0.4, 0.8].ring.tick + rand(0.05), rpitch: -10 if tick(:w) % 3 == 2
        sleep 1.0 / 3.0
      end
    end
    
  end
end

my_live_loop :glitch do
  sleep 2
  sample :glitch_perc4, rate: [0.2, 0.1].choose, finish: 1, start: 0.2
  sleep 2
end

def pop()
end

my_live_loop :pop do
  repeat = tick(:p) % 4 ==3  ? 12 : 6
  repeat.times do
    sample :elec_pop, rate: [1, 1, -2].ring().tick(:r), finish: 0.5, amp: 0.1 + rand(0.2), pan: rand(2) -1 if tick() % 3 < 2
    sleep 2.0 / repeat
  end
end
my_live_loop :pop2 do
  repeat  = tick(:p) % 3 == 2  ?  14 : 7
  repeat.times do
    sample :elec_pop, rate: [1.3, -2.4].ring().tick(:r), finish: 0.5, amp: 0.1 + rand(0.2), pan: rand(0.2) -0.1 if tick() % 7 > 3
    sleep 2.0 / repeat
  end
end

my_live_loop :rim do
  sleep 0.25
  sample :drum_cowbell, finish: 0.03, rate: linear_slide(0.05, 0.06, 8).mirror.tick(:tick)
  sample :drum_roll, finish: 0.02
  sleep 0.75
end

my_live_loop :rim2 do
  sleep 0.5
  sample :elec_bong, finish: 0.5
  sleep 1.5
end

my_live_loop :boom do
  with_fx :echo , decay: 1, phase: 0.25 do
    4.times do
      sleep get[:boom_haf_wait]
      sample :sn_zome, finish: 0.1, amp: 1
      sleep get[:boom_haf_wait]
    end
  end
end

live_loop :chord_progression, delay: -1.0 / 32 do
  set :chord, [chord(:a0, :minor7), chord(:C0, :m9)].ring.tick.reflect
  sleep 4
end

my_live_loop :pad do
  with_fx :gverb , mix: 1 do
    16.times do
      synth :blade, note: get[:chord].map {|x| x + 36}, release: 0.8, attack: 0.05, amp: 0.2, vibrato_depth: 0.5 if tick() % 8 == 0
      synth :blade, note: get[:chord].map {|x| x + 24}, release: 0.8, attack: 0.05, amp: 0.1 + rand(0.2), vibrato_depth: 0.5
      sleep 0.5
    end
  end
end

my_live_loop :bass1 do
  i = tick()
  synth :chipbass,  note: get[:chord][i], release: 0.4, amp: i % 4 == 0 ? 0.7 : 0.3 unless i % 8 == 4
  synth :tb303,  note: get[:chord][i], release: 0.3, amp: i % 4 == 0 ? 0.2 : 0.1 unless i % 8 == 4
  sleep 0.5
end

my_live_loop :bass2 do
  sleep 2.0 / 3
  synth :chipbass, note: get[:chord].reverse.tick, release: 0.4, amp: 0.2
  synth :tb303, note: get[:chord].reverse.look, release: 0.3, amp: 0.1
  
  sleep 4.0 / 3
end


def turnoff_sounds()
  sounds = ["rim_level", "rim2_level", "kick3_level", "kick2_level", "kick_level", "pop_level", "pop2_level", "boom_level"]
end


def mix()
  set_volume! 1
  control get["pad_level"], amp: 0.5
  sleep 17
  control get["bass1_level"], amp: 0.5
  control get["bass2_level"], amp: 0.4
  sleep 16
  control get["kick_level"], amp: 0.2
  control get["kick3_level"], amp: 0.4
  control get["kick2_level"], amp: 0.4
  control get["pop_level"], amp: 0.4
  control get["pop2_level"], amp: 0.4
  control get["rim_level"], amp: 0.4
  control get["rim2_level"], amp: 0.4
  control get["boom_level"], amp: 0.5
  sleep 32
  control get["glitch_level"], amp: 2.0
  set :boom_haf_wait, 0.5
  control get["pop_level"], amp: 0.8
  control get["pop2_level"], amp: 0.8
  control get["kick_level"], amp: 1.0
  sample :glitch_robot1, rate: 2, finish: 0.8
  set :kick_whammy, 1.0
  set :kick_ixi, 1.0
  sleep 31.75
  set_volume! 0.1
  sleep 0.25
  set_volume! 1.0
  sample :glitch_robot1, rate: 2.2, finish: 0.8
  set :boom_haf_wait, 1.0
  set :kick_whammy, 0.0
  set :kick_ixi, 0.1
  control get["rim_level"], amp: 0.6
  control get["rim2_level"], amp: 0.6
  sleep 32
  control get["rim_level"], amp: 0.2
  control get["rim2_level"], amp: 0.2
  control get["kick3_level"], amp: 0.8
  control get["kick2_level"], amp: 0.8
  sleep 32
  set :kick_ixi, 0.5
  control get["pop_level"], amp: 1.0
  control get["pop2_level"], amp: 1.0
  sleep 31.75
  set_volume! 0.1
  sleep 0.25
  set_volume! 1.0
  sample :glitch_robot1, rate: 1.8, finish: 0.8
  set :kick_ixi, 0.05
  set :kick_whammy, 0.5
  control get["kick3_level"], amp: 0.3
  control get["kick2_level"], amp: 0.3
  control get["boom_level"], amp: 1.0
  control get["rim_level"], amp: 0.8
  control get["rim2_level"], amp: 0.8
  set :boom_haf_wait, 0.5
  sleep 16
  set :boom_haf_wait, 1.0
  sleep 12
  set :boom_haf_wait, 0.5
  sleep 4
  control get["rim_level"], amp: 0.1
  control get["rim2_level"], amp: 0.1
  control get["kick3_level"], amp: 0.8
  control get["kick2_level"], amp: 0.1
  control get["pop_level"], amp: 0.1
  control get["pop2_level"], amp: 0.1
  control get["boom_level"], amp: 0.1
  sleep 17
  set_volume! 0
end

sleep 6.92
mix



